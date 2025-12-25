module lab6_top #(
    // ---- clocks / rates ----
    parameter integer CLK_HZ      = 50_000_000,
    parameter integer SPI_HZ      = 5_000_000,
    parameter integer BAUD        = 115200,
    parameter integer SAMPLE_HZ   = 10_000,
    parameter integer UART_DECIM  = 10,

    // ---- DAC frame control bits ----
    parameter [3:0] DAC_CTRL = 4'b0011,

    // ---- ADC data align ----
    parameter integer ADC_MSB_SHIFT = 4,

    // ---- SPI phase: 0=sample on rising, 1=sample on falling ----
    // Для TPC112S1 нужно, чтобы данные считывались на falling edge SCLK:contentReference[oaicite:1]{index=1}
    parameter integer DAC_CPHA = 1,
    // Для ADC обычно подходит CPHA=0 (если будут “сдвиги” — поменяй на 1)
    parameter integer ADC_CPHA = 0
)(
    input  wire clk,
    input  wire rst_n,

    // DAC (TPC112S1)
    output wire dac_sync_n,
    output wire dac_sclk,
    output wire dac_din,

    // ADC (ADC122S101)
    output wire adc_cs_n,
    output wire adc_sclk,
    output wire adc_din,
    input  wire adc_dout,

    // UART
    output wire uart_tx
);

    // -----------------------------
    // helper clog2 (Verilog-2005 safe)
    // -----------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            if (value <= 1) begin
                clog2 = 1;
            end else begin
                value = value - 1;
                for (i = 0; value > 0; i = i + 1)
                    value = value >> 1;
                clog2 = i;
            end
        end
    endfunction

    // ============================================================
    // DDS (твоя Gowin IP)
    // ============================================================
    wire [26:0] phase_out_o;
    wire [11:0] sine_o;
    wire [11:0] cosine_o;
    wire        data_valid_o;

    DDS_II_Top dds_u (
        .clk_i        (clk),
        .rst_n_i      (rst_n),
        .phase_out_o  (phase_out_o),
        .cosine_o     (cosine_o),
        .sine_o       (sine_o),
        .data_valid_o (data_valid_o)
    );

    // ============================================================
    // sample tick generator
    // ============================================================
    localparam integer SAMPLE_DIV = ((CLK_HZ / SAMPLE_HZ) < 1) ? 1 : (CLK_HZ / SAMPLE_HZ);
    localparam integer SAMPLE_CNT_W = clog2(SAMPLE_DIV);

    reg [SAMPLE_CNT_W-1:0] sample_cnt;
    reg sample_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt  <= {SAMPLE_CNT_W{1'b0}};
            sample_tick <= 1'b0;
        end else begin
            sample_tick <= 1'b0;
            if (sample_cnt == SAMPLE_DIV-1) begin
                sample_cnt  <= {SAMPLE_CNT_W{1'b0}};
                sample_tick <= 1'b1;
            end else begin
                sample_cnt <= sample_cnt + 1'b1;
            end
        end
    end

    // ============================================================
    // SPI masters
    // ============================================================
    reg        spi_dac_start;
    wire       spi_dac_busy, spi_dac_done;
    reg [15:0] spi_dac_tx;

    spi_master_mode0 #(
        .CLK_HZ (CLK_HZ),
        .SPI_HZ (SPI_HZ),
        .BITS   (16),
        .CPHA   (DAC_CPHA)
    ) spi_dac (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (spi_dac_start),
        .tx_data (spi_dac_tx),
        .miso    (1'b0),
        .mosi    (dac_din),
        .sclk    (dac_sclk),
        .cs_n    (dac_sync_n),
        .busy    (spi_dac_busy),
        .done    (spi_dac_done),
        .rx_data ()
    );

    reg        spi_adc_start;
    wire       spi_adc_busy, spi_adc_done;
    reg [15:0] spi_adc_tx;
    wire [15:0] spi_adc_rx;

    spi_master_mode0 #(
        .CLK_HZ (CLK_HZ),
        .SPI_HZ (SPI_HZ),
        .BITS   (16),
        .CPHA   (ADC_CPHA)
    ) spi_adc (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (spi_adc_start),
        .tx_data (spi_adc_tx),
        .miso    (adc_dout),
        .mosi    (adc_din),
        .sclk    (adc_sclk),
        .cs_n    (adc_cs_n),
        .busy    (spi_adc_busy),
        .done    (spi_adc_done),
        .rx_data (spi_adc_rx)
    );

    // ============================================================
    // UART + HEX sender
    // ============================================================
    wire uart_ready;
    reg  uart_valid;
    reg  [7:0] uart_data;

    uart_tx_8n1 #(
        .CLK_HZ (CLK_HZ),
        .BAUD   (BAUD)
    ) uart0 (
        .clk   (clk),
        .rst_n (rst_n),
        .data  (uart_data),
        .valid (uart_valid),
        .ready (uart_ready),
        .tx    (uart_tx)
    );

    reg        hex_start;
    wire       hex_busy;
    reg [11:0] hex_value;

    uart_send_hex12_line sender (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (hex_start),
        .value12    (hex_value),
        .busy       (hex_busy),
        .uart_ready (uart_ready),
        .uart_valid (uart_valid),
        .uart_data  (uart_data)
    );

    // ============================================================
    // Main FSM
    // ============================================================
    localparam [2:0] S_IDLE   = 3'd0;
    localparam [2:0] S_DAC    = 3'd1;
    localparam [2:0] S_SETTLE = 3'd2;
    localparam [2:0] S_ADC    = 3'd3;
    localparam [2:0] S_LATCH  = 3'd4;

    reg [2:0] state;

    localparam integer SETTLE_CYCLES = 10;
    localparam integer SETTLE_W = clog2(SETTLE_CYCLES+1);
    reg [SETTLE_W-1:0] settle_cnt;

    localparam integer DECIM_W = clog2(UART_DECIM);
    reg [DECIM_W-1:0] decim_cnt;

    reg [11:0] dac_code;
    reg [11:0] adc_code;

    wire [11:0] adc_aligned;
    assign adc_aligned = (spi_adc_rx >> ADC_MSB_SHIFT); // обрезка до 12 бит сама

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= S_IDLE;

            spi_dac_start  <= 1'b0;
            spi_adc_start  <= 1'b0;
            spi_dac_tx     <= 16'h0000;
            spi_adc_tx     <= 16'h0000;

            settle_cnt     <= {SETTLE_W{1'b0}};
            decim_cnt      <= {DECIM_W{1'b0}};

            hex_start      <= 1'b0;
            hex_value      <= 12'd0;

            dac_code       <= 12'd0;
            adc_code       <= 12'd0;
        end else begin
            spi_dac_start <= 1'b0;
            spi_adc_start <= 1'b0;
            hex_start     <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (sample_tick && !spi_dac_busy && !spi_adc_busy) begin
                        // DDS выдаёт 12 бит; предполагаем 0..4095 (offset-binary)
                        dac_code   <= sine_o;
                        spi_dac_tx <= {DAC_CTRL, sine_o};
                        spi_dac_start <= 1'b1;
                        state <= S_DAC;
                    end
                end

                S_DAC: begin
                    if (spi_dac_done) begin
                        settle_cnt <= SETTLE_CYCLES;
                        state <= (SETTLE_CYCLES == 0) ? S_ADC : S_SETTLE;
                    end
                end

                S_SETTLE: begin
                    if (settle_cnt == 0) begin
                        state <= S_ADC;
                    end else begin
                        settle_cnt <= settle_cnt - 1'b1;
                    end
                end

                S_ADC: begin
                    if (!spi_adc_busy) begin
                        spi_adc_tx    <= 16'h0000;
                        spi_adc_start <= 1'b1;
                        state <= S_LATCH;
                    end
                end

                S_LATCH: begin
                    if (spi_adc_done) begin
                        adc_code <= adc_aligned;

                        // UART DECIM
                        if (UART_DECIM <= 1) begin
                            if (!hex_busy) begin
                                hex_value <= adc_aligned;
                                hex_start <= 1'b1;
                            end
                        end else begin
                            if (decim_cnt == UART_DECIM-1) begin
                                decim_cnt <= {DECIM_W{1'b0}};
                                if (!hex_busy) begin
                                    hex_value <= adc_aligned;
                                    hex_start <= 1'b1;
                                end
                            end else begin
                                decim_cnt <= decim_cnt + 1'b1;
                            end
                        end

                        state <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
