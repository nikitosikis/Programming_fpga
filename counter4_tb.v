`timescale 1ns/1ps

module counter4_tb;
    reg clk = 0;
    reg reset = 1;
    reg data = 0;
    reg ack = 0;
    wire counting;
    wire done;

    top_fsm dut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .ack(ack),
        .counting(counting),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter4_tb.vcd");
        $dumpvars(0, counter4_tb);
    end

    task send_bit(input bit bitval);
        begin
            data = bitval;
            @(posedge clk);
        end
    endtask

    always @(posedge clk) begin
        if ($test$plusargs("trace")) begin
            $display("%0t state=%0d shift_cnt=%0d delay=%0d delay_reg=%0d q=%0d counting=%b done=%b data=%b",
                     $time, dut.state, dut.shift_counter, dut.delay, dut.delay_reg, dut.shift_reg.q, counting, done, data);
        end
    end

    initial begin
        $display("Starting counter4_tb");

        // release reset
        repeat (2) @(posedge clk);
        reset <= 0;

        // Single sequence per truth table example: delay value 1
        kick_pattern();
        run_sequence(4'b0001, 4'd1, 2000);

        $display("counter4_tb passed");
        $finish;
    end

    task kick_pattern;
        begin
            // pattern 1101 to raise start_shifting
            send_bit(1'b1);
            send_bit(1'b1);
            send_bit(1'b0);
            send_bit(1'b1);
        end
    endtask

    task run_sequence(input [3:0] bits, input [3:0] expected_delay, input integer max_cycles);
        integer i;
        integer cycles;
        begin
            // prime first bit before SHIFT to avoid stale data
            data = bits[3];
            wait (dut.state == 2'd1);
            @(posedge clk); // first shift

            // remaining 3 bits
            for (i = 2; i >= 0; i = i - 1) begin
                data = bits[i];
                @(posedge clk);
            end

            // wait for counting state
            wait (dut.state == 2'd2);
            if (dut.delay_reg !== expected_delay) $fatal(1, "delay_reg mismatch, got %0d expected %0d", dut.delay_reg, expected_delay);

            // wait for done with a bound
            cycles = 0;
            while (done !== 1'b1 && cycles < max_cycles) begin
                @(posedge clk);
                cycles = cycles + 1;
            end
            if (done !== 1'b1) $fatal(1, "FSM did not assert done for delay %0d", expected_delay);

            // acknowledge and return to idle
            ack <= 1'b1;
            @(posedge clk);
            ack <= 1'b0;
            @(posedge clk);
        end
    endtask
endmodule
