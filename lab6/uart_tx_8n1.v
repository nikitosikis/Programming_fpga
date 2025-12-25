module uart_tx_8n1 #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD   = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data,
    input  wire       valid,
    output wire       ready,
    output reg        tx
);

    function integer clog2;
        input integer value;
        integer i;
        begin
            if (value <= 1) begin
                clog2 = 1;
            end else begin
                value = value - 1;
                for (i = 0; value > 0; i = i + 1)
                    value = value >> 1;
                clog2 = i;
            end
        end
    endfunction

    localparam integer BIT_DIV = (CLK_HZ / BAUD);
    localparam integer BIT_W   = clog2(BIT_DIV);

    reg [BIT_W-1:0] bit_cnt;
    reg [3:0]       bit_pos;
    reg [9:0]       shreg;
    reg             busy;

    assign ready = ~busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx      <= 1'b1;
            busy    <= 1'b0;
            bit_cnt <= {BIT_W{1'b0}};
            bit_pos <= 4'd0;
            shreg   <= 10'h3FF;
        end else begin
            if (!busy) begin
                tx <= 1'b1;
                bit_cnt <= {BIT_W{1'b0}};
                bit_pos <= 4'd0;

                if (valid) begin
                    // shreg[0]=start(0), then data LSB-first, then stop(1)
                    shreg <= {1'b1, data, 1'b0};
                    tx    <= 1'b0; // start immediately
                    busy  <= 1'b1;
                end
            end else begin
                if (bit_cnt == BIT_DIV-1) begin
                    bit_cnt <= {BIT_W{1'b0}};

                    // shift right, insert 1 at MSB
                    shreg <= {1'b1, shreg[9:1]};
                    tx    <= shreg[1]; // next bit (old shreg[1] becomes new shreg[0])

                    if (bit_pos == 4'd9) begin
                        busy <= 1'b0;
                        tx   <= 1'b1;
                    end else begin
                        bit_pos <= bit_pos + 1'b1;
                    end
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end
    end

endmodule
