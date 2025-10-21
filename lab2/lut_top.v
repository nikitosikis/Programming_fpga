// Simple 3-input LUT programmed serially via S over 8 cycles when enable=1
module lut_top (
    input  wire clk,
    input  wire enable,
    input  wire S,
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Z
);
    reg [2:0] cnt;
    reg [7:0] lut;

    always @(posedge clk) begin
        if (enable) begin
            // shift in serial config bit S into LUT LSB-first
            lut <= {lut[6:0], S};
            cnt <= cnt + 3'd1;
        end else begin
            cnt <= 3'd0; // idle
        end
    end

    wire [2:0] addr = {A,B,C};
    assign Z = lut[addr];
endmodule
