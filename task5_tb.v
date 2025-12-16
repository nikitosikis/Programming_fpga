`timescale 1ns / 1ps

module task5_tb; 
    reg clk = 1;
    always #5 clk = !clk;

    reg a = 1;
    wire [2:0] q;

    task5 taska (
        .clk(clk),
        .a(a),
        .q(q)
    );

    initial begin
        $dumpfile("wave.vcd");
		$dumpvars(0, task5_tb);
        #40
        a <= 0;

        #115
        a <= 1;

        #25
        a <= 0;

        #50
        $finish;
    end

    initial begin
		$monitor("t=%-4d: clk = %d, a = %d, q = %d", $time, clk, a, q);
	end
endmodule