`timescale 1ns / 1ps

module task4_tb;

    reg clk=0;
    reg a, p, q;
	always #30 clk = !clk;
    task4 taska (
        .clk(clk),
        .a(a),
        .p(p),
        .q(q)
    );
    initial begin
        $dumpfile("wave.vcd");
		$dumpvars(0, task4_tb);
        
        a <= 0;
        #75
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #30
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #10
        a <= 1;
        #10
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #5
        a <= 1;
        #5
        a <= 0;
        #10
        a <= 1;
        #10
        a <= 0;
        #10
        a <= 1;
        #5


        $finish;
    end

    initial begin
		$monitor("t=%-4d: clk = %d, a = %d, p = %d, q = %d", $time, clk, a, p, q);
	end

endmodule