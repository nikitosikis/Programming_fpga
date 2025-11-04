`timescale 1ns / 1ps

module timer_part2_tb;
    reg clk;
    reg shift_ena;
    reg count_ena;
    reg data;
    wire [3:0] q;

    timer_part2 dut (
        .clk(clk),
        .shift_ena(shift_ena),
        .count_ena(count_ena),
        .data(data),
        .q(q)
    );

    reg [3:0] expected;
    integer i;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic shift_in(input [3:0] value);
        reg [3:0] next_expected;
        begin
            shift_ena = 1'b1;
            for (i = 3; i >= 0; i = i - 1) begin
                data = (value >> i) & 1'b1;
                next_expected = {expected[2:0], data};
                @(posedge clk);
                #1;
                if (q !== next_expected) begin
                    $display("Shift mismatch at time %0t: data=%0b q=%0h expected=%0h",
                             $time, data, q, next_expected);
                    $fatal;
                end
                expected = next_expected;
            end
            shift_ena = 1'b0;
            data = 1'b0;
        end
    endtask

    task automatic count_down(input integer steps);
        reg [3:0] next_expected;
        integer k;
        begin
            for (k = 0; k < steps; k = k + 1) begin
                count_ena = 1'b1;
                next_expected = expected - 4'd1;
                @(posedge clk);
                #1;
                if (q !== next_expected) begin
                    $display("Count mismatch at time %0t: q=%0h expected=%0h",
                             $time, q, next_expected);
                    $fatal;
                end
                expected = next_expected;
                count_ena = 1'b0;
                @(negedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("timer_part2_wave_tb.vcd");
        $dumpvars(0, timer_part2_tb);

        shift_ena = 0;
        count_ena = 0;
        data = 0;
        expected = 4'd0;

        repeat (2) @(posedge clk);

        shift_in(4'h9);
        repeat (2) @(posedge clk);

        count_down(5);
        repeat (2) @(posedge clk);

        shift_in(4'h4);
        repeat (2) @(posedge clk);

        count_down(3);

        #20 $finish;
    end
endmodule
