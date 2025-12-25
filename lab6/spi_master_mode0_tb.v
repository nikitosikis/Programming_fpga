`timescale 1ns/1ps

module spi_master_mode0_tb;

    // Ускоряем симуляцию
    localparam integer CLK_HZ = 10_000_000;
    localparam integer SPI_HZ = 1_000_000;
    localparam integer BITS   = 16;

    reg clk = 0;
    always #50 clk = ~clk; // 10 MHz

    reg rst_n = 0;

    reg start = 0;
    reg [BITS-1:0] tx_data = 0;
    wire mosi, sclk, cs_n;
    reg  miso = 0;
    wire busy, done;
    wire [BITS-1:0] rx_data;

    spi_master_mode0 #(
        .CLK_HZ(CLK_HZ),
        .SPI_HZ(SPI_HZ),
        .BITS  (BITS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .cs_n(cs_n),
        .busy(busy),
        .done(done),
        .rx_data(rx_data)
    );

    // --------- Модель SPI slave ----------
    reg [BITS-1:0] slave_shift_out;
    reg [BITS-1:0] slave_captured_mosi;
    integer i;

    // На CS falling: загружаем слово на выдачу и готовим первый бит на MISO
    always @(negedge cs_n) begin
        slave_shift_out = 16'h3C5A; // то, что master должен прочитать
        slave_captured_mosi = {BITS{1'b0}};
        miso = slave_shift_out[BITS-1]; // выставили MSB до первого rising
    end

    // Master сэмплит MISO на RISING, значит slave обновляет MISO на FALLING
    always @(negedge sclk) begin
        if (!cs_n) begin
            slave_shift_out = {slave_shift_out[BITS-2:0], 1'b0};
            miso = slave_shift_out[BITS-1];
        end
    end

    // MOSI удобно сэмплить на RISING (в mode0 MOSI стабилен к rising)
    always @(posedge sclk) begin
        if (!cs_n) begin
            // сдвигаем влево и пишем новый бит в LSB? Нет: собираем MSB-first
            slave_captured_mosi = {slave_captured_mosi[BITS-2:0], mosi};
        end
    end

    // --------- Тест ----------
    initial begin
        $display("SPI TB start");
        // reset
        repeat (5) @(posedge clk);
        rst_n = 1;

        // старт транзакции
        @(posedge clk);
        tx_data = 16'hA5C3;
        start = 1;
        @(posedge clk);
        start = 0;

        // ждать завершения
        wait(done);
        @(posedge clk);

        // Проверка rx
        if (rx_data !== 16'h3C5A) begin
            $display("FAIL: rx_data=%h expected=%h", rx_data, 16'h3C5A);
            $stop;
        end

        // slave_captured_mosi собирался как поток битов; при MSB-first он станет равен tx_data
        if (slave_captured_mosi !== tx_data) begin
            $display("FAIL: MOSI captured=%h expected=%h", slave_captured_mosi, tx_data);
            $stop;
        end

        $display("PASS: spi_master_mode0");
        $finish;
    end

endmodule
