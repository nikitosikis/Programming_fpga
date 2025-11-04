`timescale 1ns / 1ps

module comb_part3_tb;
    reg [3:0] a, b, c, d, e;
    wire [3:0] q;

    comb_part3 dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .q(q)
    );

    function automatic [3:0] expected(input [3:0] sel,
                                      input [3:0] va,
                                      input [3:0] vb,
                                      input [3:0] vd,
                                      input [3:0] ve);
        case (sel)
            4'h0: expected = vb;
            4'h1: expected = ve;
            4'h2: expected = va;
            4'h3: expected = vd;
            default: expected = 4'hf;
        endcase
    endfunction

    integer i;

    task check_set;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                c = i[3:0];
                #5;
                if (q !== expected(c, a, b, d, e)) begin
                    $display("Mismatch at time %0t: c=%0h -> q=%0h expected=%0h (a=%0h b=%0h d=%0h e=%0h)",
                             $time, c, q, expected(c, a, b, d, e), a, b, d, e);
                    $fatal;
                end
            end
        end
    endtask

    initial begin
        $dumpfile("comb_part3_wave_tb.vcd");
        $dumpvars(0, comb_part3_tb);

        a = 4'ha; b = 4'hb; d = 4'hd; e = 4'he;
        check_set();

        #20;
        a = 4'h1; b = 4'h2; d = 4'h3; e = 4'h4;
        check_set();

        #20;
        a = 4'h5; b = 4'h6; d = 4'h7; e = 4'h8;
        check_set();

        #10 $finish;
    end
endmodule
