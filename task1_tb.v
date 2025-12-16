`timescale 1ns / 1ps

module task1_tb;

    reg a, b, c, d;
    wire q;
    task1 taska (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .q(q)
    );

    initial begin
        integer i;
        $dumpfile("wave.vcd");
		$dumpvars(0, task1_tb);
        a <= 0;
        b <= 0;
        c <= 0;
        d <= 0;

        for (i = 1; i <= 15; i = i + 1) begin
            #5 {a,b,c,d} <= i[3:0];
        end

        #5 {a,b,c,d} <= 4'b0000;
        #5 {a,b,c,d} <= 4'b0001;
        
        $finish;
    end

    initial begin
		$monitor("t=%-4d: a = %d, b = %d, c = %d, d = %d, q = %d", $time, a, b, c, d, q);
	end

endmodule
