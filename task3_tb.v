`timescale 1ns / 1ps

module task3_tb;

    reg [3:0] a, b, c, d, e;
    wire [3:0] q;
    task3 taska (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .q(q)
    );

    initial begin
        integer i;
        $dumpfile("wave.vcd");
		$dumpvars(0, task3_tb);

        a <= 4'ha;
        b <= 4'hb;
        c <= 0;
        d <= 4'hd;
        e <= 4'he;

        for (i = 0; i < 16; i = i + 1) begin
            #5
            c <= c + 1;
        end


        a <= 4'h1;
        b <= 4'h2;
        c <= 0;
        d <= 4'h3;
        e <= 4'h4;

        for (i = 0; i < 8; i = i + 1) begin
            #5
            c <= c + 1;
        end


        a <= 4'h5;
        b <= 4'h6;
        c <= 0;
        d <= 4'h7;
        e <= 4'h8;

        for (i = 0; i < 8; i = i + 1) begin
            #5
            c <= c + 1;
        end
        $finish;
    end

    initial begin
		$monitor("t=%-4d: a = %d, b = %d, c = %d, d = %d, q = %d", $time, a, b, c, d, q);
	end

endmodule
