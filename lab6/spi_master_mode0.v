module spi_master_mode0 #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer SPI_HZ = 5_000_000,
    parameter integer BITS   = 16,
    parameter integer CPHA   = 0   // 0: sample rising / shift falling; 1: shift rising / sample falling
)(
    input  wire            clk,
    input  wire            rst_n,
    input  wire            start,
    input  wire [BITS-1:0] tx_data,
    input  wire            miso,
    output reg             mosi,
    output reg             sclk,
    output reg             cs_n,
    output reg             busy,
    output reg             done,
    output reg [BITS-1:0]  rx_data
);

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

    // half-period divider
    localparam integer DIV = ((CLK_HZ/(2*SPI_HZ)) < 1) ? 1 : (CLK_HZ/(2*SPI_HZ));
    localparam integer DIV_W = clog2(DIV);

    reg [DIV_W-1:0] div_cnt;

    reg [BITS-1:0] tx_shift;
    reg [BITS-1:0] rx_shift;
    reg [clog2(BITS)-1:0] bit_idx; // 0..BITS-1

    reg finish_pending;

    wire tick = (div_cnt == DIV-1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt        <= {DIV_W{1'b0}};
            tx_shift       <= {BITS{1'b0}};
            rx_shift       <= {BITS{1'b0}};
            rx_data        <= {BITS{1'b0}};
            bit_idx        <= {clog2(BITS){1'b0}};
            finish_pending <= 1'b0;

            mosi <= 1'b0;
            sclk <= 1'b0;   // CPOL=0
            cs_n <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;

            // divider
            if (busy) begin
                if (tick) div_cnt <= {DIV_W{1'b0}};
                else      div_cnt <= div_cnt + 1'b1;
            end else begin
                div_cnt <= {DIV_W{1'b0}};
            end

            // start transaction
            if (start && !busy) begin
                busy          <= 1'b1;
                cs_n          <= 1'b0;
                sclk          <= 1'b0;
                tx_shift      <= tx_data;
                rx_shift      <= {BITS{1'b0}};
                bit_idx       <= BITS-1;
                finish_pending<= 1'b0;

                // put MSB early (ok for both CPHA variants)
                mosi <= tx_data[BITS-1];
            end

            if (busy && tick) begin
                // toggle clock
                if (sclk == 1'b0) begin
                    // rising edge
                    sclk <= 1'b1;

                    if (CPHA == 1) begin
                        // shift/update MOSI on rising
                        mosi <= tx_shift[bit_idx];
                    end else begin
                        // sample MISO on rising
                        rx_shift[bit_idx] <= miso;

                        if (bit_idx == 0) begin
                            finish_pending <= 1'b1;
                        end else begin
                            bit_idx <= bit_idx - 1'b1;
                        end
                    end
                end else begin
                    // falling edge
                    sclk <= 1'b0;

                    if (CPHA == 1) begin
                        // sample on falling
                        rx_shift[bit_idx] <= miso;

                        if (bit_idx == 0) begin
                            finish_pending <= 1'b1;
                        end else begin
                            bit_idx <= bit_idx - 1'b1;
                        end
                    end else begin
                        // shift/update MOSI on falling (bit_idx already decremented on rising)
                        mosi <= tx_shift[bit_idx];
                    end

                    // finish only when clock returned low
                    if (finish_pending) begin
                        busy          <= 1'b0;
                        cs_n          <= 1'b1;
                        done          <= 1'b1;
                        rx_data       <= rx_shift;
                        finish_pending<= 1'b0;
                        mosi          <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
