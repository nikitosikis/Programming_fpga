`timescale 1ns/1ps

module uart_send_hex12_line_tb;

    reg clk = 0;
    always #10 clk = ~clk; // 50 MHz условно

    reg rst_n = 0;

    reg start = 0;
    reg [11:0] value12 = 12'h000;
    wire busy;

    reg  uart_ready = 1'b1;
    wire uart_valid;
    wire [7:0] uart_data;

    uart_send_hex12_line dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .value12(value12),
        .busy(busy),
        .uart_ready(uart_ready),
        .uart_valid(uart_valid),
        .uart_data(uart_data)
    );

    reg [7:0] captured [0:3];
    integer idx;

    initial begin
        $display("HEX sender TB start");
        repeat(5) @(posedge clk);
        rst_n = 1;

        value12 = 12'hABC;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        idx = 0;
        while (idx < 4) begin
            @(posedge clk);
            if (uart_valid) begin
                captured[idx] = uart_data;
                idx = idx + 1;
            end
        end

        // Ожидаем: "ABC\n"
        if (captured[0] !== "A" ||
            captured[1] !== "B" ||
            captured[2] !== "C" ||
            captured[3] !== 8'h0A) begin
            $display("FAIL: got=%c%c%c %h", captured[0],captured[1],captured[2],captured[3]);
            $stop;
        end

        $display("PASS: uart_send_hex12_line");
        $finish;
    end

endmodule
