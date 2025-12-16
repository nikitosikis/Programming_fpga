`timescale 1ns / 1ps

module task6_tb;

    reg clk = 1;
    reg a, b;
    wire q, state;
	always #5 clk <= ~clk;
    task6 taska (
        .clk(clk),
        .a(a),
        .b(b),
        .state(state),
        .q(q)
    );
    initial begin
        $dumpfile("wave.vcd");
		$dumpvars(0, task6_tb);
        
        a = 0;
        b = 0;
        #40    
        a <= 0;
        b <= 1;
        #10     
        a <= 1;
        b <= 0;
        #10     
        a <= 1;
        b <= 1;
        #10     
        a <= 0;
        b <= 0;
        #10     
        a <= 1;
        b <= 1;
        #30     
        a <= 1;
        b <= 0;
        #10     
        a <= 0;
        b <= 1;
        #10     
        a <= 0;
        b <= 0;
        #30
        $finish;
    end

    initial begin
		$monitor("t<=%-4d: clk <= %d, a <= %d, b <= %d, q <= %d, state <= %d", $time, clk, a, b, q, state);
	end

endmodule