`timescale 1ns/1ps

module uart_tx_8n1_tb;

    localparam integer CLK_HZ = 10_000_000;
    localparam integer BAUD   = 1_000_000;   // чтобы быстро
    localparam integer BIT_DIV = (CLK_HZ/BAUD);

    reg clk = 0;
    always #50 clk = ~clk; // 10 MHz

    reg rst_n = 0;

    reg  [7:0] data = 8'h00;
    reg        valid = 0;
    wire       ready;
    wire       tx;

    uart_tx_8n1 #(
        .CLK_HZ(CLK_HZ),
        .BAUD(BAUD)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(data),
        .valid(valid),
        .ready(ready),
        .tx(tx)
    );

    task send_byte(input [7:0] b);
    begin
        wait(ready);
        @(posedge clk);
        data  <= b;
        valid <= 1'b1;
        @(posedge clk);
        valid <= 1'b0;
    end
    endtask

    task recv_byte(output [7:0] b);
        integer k;
        reg [7:0] tmp;
    begin
        tmp = 8'h00;

        // ждём старт-бит
        @(negedge tx);

        // до середины первого data-бита: 1.5 бит-тайма
        repeat (BIT_DIV + BIT_DIV/2) @(posedge clk);

        // 8 бит LSB-first
        for (k=0; k<8; k=k+1) begin
            tmp[k] = tx;
            repeat (BIT_DIV) @(posedge clk);
        end

        // стоп-бит (можно проверить, что tx==1)
        if (tx !== 1'b1) begin
            $display("FAIL: stop bit not 1");
            $stop;
        end

        b = tmp;
    end
    endtask

    reg [7:0] r;

    initial begin
        $display("UART TX TB start");
        repeat(5) @(posedge clk);
        rst_n = 1;

        send_byte(8'h55);
        recv_byte(r);
        if (r !== 8'h55) begin
            $display("FAIL: got=%h exp=%h", r, 8'h55);
            $stop;
        end

        send_byte(8'hA6);
        recv_byte(r);
        if (r !== 8'hA6) begin
            $display("FAIL: got=%h exp=%h", r, 8'hA6);
            $stop;
        end

        $display("PASS: uart_tx_8n1");
        $finish;
    end

endmodule
