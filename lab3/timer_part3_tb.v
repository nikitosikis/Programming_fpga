`timescale 1ns / 1ps

module timer_part3_tb;
    reg clk;
    reg reset;
    reg data;
    wire start_shifting;

    timer_part3 dut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .start_shifting(start_shifting)
    );

    reg [3:0] history;
    integer pulse_count;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic drive_bit(input reg value);
        reg [3:0] next_history;
        reg       expected;
        begin
            data = value;
            @(posedge clk);
            next_history = {history[2:0], value};
            if (reset) begin
                history = 4'b0000;
                expected = 1'b0;
            end else begin
                expected = (next_history == 4'b1101);
                history = next_history;
            end
            #1;
            if (start_shifting !== expected) begin
                $display("Mismatch at time %0t: data=%0b expected pulse=%0b got=%0b history=%0b",
                         $time, value, expected, start_shifting, next_history);
                $fatal;
            end
            if (start_shifting) begin
                pulse_count = pulse_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("timer_part3_wave_tb.vcd");
        $dumpvars(0, timer_part3_tb);

        history = 4'b0000;
        pulse_count = 0;

        reset = 1'b1;
        data = 1'b0;

        repeat (3) @(posedge clk);
        reset = 1'b0;

        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);

        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b0);
        drive_bit(1'b1);

        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        history = 4'b0000;

        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);

        if (pulse_count !== 3) begin
            $display("Unexpected number of pulses: %0d", pulse_count);
            $fatal;
        end

        #20;
        $display("timer_part3_tb completed successfully");
        $finish;
    end
endmodule
