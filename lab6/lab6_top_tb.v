`timescale 1ns/1ps

module lab6_top_tb;

    // Быстрые параметры симуляции
    localparam integer CLK_HZ     = 10_000_000;
    localparam integer SPI_HZ     = 1_000_000;
    localparam integer BAUD       = 1_000_000;
    localparam integer SAMPLE_HZ  = 2000;
    localparam integer UART_DECIM = 1;
    localparam integer ADC_SHIFT  = 4;

    reg clk = 0;
    always #50 clk = ~clk; // 10 MHz

    reg rst_n = 0;

    // DUT IO
    wire dac_sync_n, dac_sclk, dac_din;
    wire adc_cs_n,   adc_sclk, adc_din;
    reg  adc_dout = 1'b0;
    wire uart_tx;

    lab6_top #(
        .CLK_HZ(CLK_HZ),
        .SPI_HZ(SPI_HZ),
        .BAUD(BAUD),
        .SAMPLE_HZ(SAMPLE_HZ),
        .UART_DECIM(UART_DECIM),
        .ADC_MSB_SHIFT(ADC_SHIFT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .dac_sync_n(dac_sync_n),
        .dac_sclk(dac_sclk),
        .dac_din(dac_din),

        .adc_cs_n(adc_cs_n),
        .adc_sclk(adc_sclk),
        .adc_din(adc_din),
        .adc_dout(adc_dout),

        .uart_tx(uart_tx)
    );

    // -------------------------------
    // Модель DAC: принимает 16 бит MOSI на rising, хранит last_dac_code
    // -------------------------------
    reg [15:0] dac_shift_in;
    integer dac_bitcnt;
    reg [11:0] last_dac_code;

    always @(negedge dac_sync_n) begin
        dac_shift_in = 16'h0000;
        dac_bitcnt   = 0;
    end

    always @(posedge dac_sclk) begin
        if (!dac_sync_n) begin
            dac_shift_in = {dac_shift_in[14:0], dac_din};
            dac_bitcnt   = dac_bitcnt + 1;
        end
    end

    always @(posedge dac_sync_n) begin
        if (dac_bitcnt == 16) begin
            last_dac_code <= dac_shift_in[11:0];
        end
    end

    // -------------------------------
    // Модель ADC: отдаёт {code,4'b0000} по MISO
    // master читает MISO на rising => ADC обновляет adc_dout на falling
    // -------------------------------
    reg [15:0] adc_shift_out;

    always @(negedge adc_cs_n) begin
        adc_shift_out = {last_dac_code, 4'b0000};
        adc_dout = adc_shift_out[15];
    end

    always @(negedge adc_sclk) begin
        if (!adc_cs_n) begin
            adc_shift_out = {adc_shift_out[14:0], 1'b0};
            adc_dout = adc_shift_out[15];
        end
    end

    // -------------------------------
    // UART RX (ASCII линия: 3 hex + '\n')
    // -------------------------------
    localparam integer BIT_DIV = (CLK_HZ/BAUD);

    function [3:0] ascii2nib(input [7:0] c);
        begin
            if (c >= "0" && c <= "9") ascii2nib = c - "0";
            else if (c >= "A" && c <= "F") ascii2nib = c - "A" + 4'd10;
            else ascii2nib = 4'h0;
        end
    endfunction

    task uart_rx_byte(output [7:0] b);
        integer k;
        reg [7:0] tmp;
    begin
        tmp = 8'h00;
        @(negedge uart_tx);
        repeat (BIT_DIV + BIT_DIV/2) @(posedge clk);
        for (k=0; k<8; k=k+1) begin
            tmp[k] = uart_tx;
            repeat (BIT_DIV) @(posedge clk);
        end
        // стоп
        if (uart_tx !== 1'b1) begin
            $display("FAIL: UART stop bit not 1");
            $stop;
        end
        b = tmp;
    end
    endtask

    task uart_rx_line3hex(output [11:0] v);
        reg [7:0] c0,c1,c2,c3;
    begin
        uart_rx_byte(c0);
        uart_rx_byte(c1);
        uart_rx_byte(c2);
        uart_rx_byte(c3); // '\n'

        if (c3 !== 8'h0A) begin
            $display("FAIL: expected NL, got %h", c3);
            $stop;
        end

        v = {ascii2nib(c0), ascii2nib(c1), ascii2nib(c2)};
    end
    endtask

    integer n;
    reg [11:0] got;

    initial begin
        $display("LAB6 TOP TB start");
        repeat(10) @(posedge clk);
        rst_n = 1;

        // прочитаем несколько строк и проверим, что это то же самое, что last_dac_code
        for (n=0; n<20; n=n+1) begin
            uart_rx_line3hex(got);

            if (got !== last_dac_code) begin
                $display("FAIL: got=%h expected(last_dac_code)=%h", got, last_dac_code);
                $stop;
            end else begin
                $display("OK line %0d: %h", n, got);
            end
        end

        $display("PASS: lab6_top integration");
        $finish;
    end

endmodule


// ============================================================
// Stub DDS_II_Top (чтобы top компилился без реального IP)
// ============================================================
module DDS_II_Top(
    input  wire       clk_i,
    input  wire       rst_n_i,
    output reg [26:0] phase_out_o,
    output reg [11:0] cosine_o,
    output reg [11:0] sine_o,
    output reg        data_valid_o
);
    // Псевдо-синус: просто бегущий код (главное, что меняется)
    reg [11:0] cnt;

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            cnt          <= 12'h800;
            sine_o       <= 12'h800;
            cosine_o     <= 12'h800;
            phase_out_o  <= 27'd0;
            data_valid_o <= 1'b0;
        end else begin
            cnt          <= cnt + 12'd7;
            sine_o       <= cnt;
            cosine_o     <= ~cnt;
            phase_out_o  <= phase_out_o + 27'd1;
            data_valid_o <= 1'b1; // новый отсчёт каждый такт
        end
    end
endmodule
