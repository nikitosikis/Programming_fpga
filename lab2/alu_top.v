module alu_top (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [4:0]  op_i,
    output reg  [31:0] result_o,
    output reg         flag_o
);
    wire [4:0] shamt = b_i[4:0];
    wire signed [31:0] a_s = a_i;
    wire signed [31:0] b_s = b_i;

    always @* begin
        result_o = 32'b0;
        flag_o   = 1'b0;
        case (op_i)
            5'b00000: begin // ADD
                result_o = a_i + b_i;
            end
            5'b01000: begin // SUB
                result_o = a_i - b_i;
            end
            5'b00001: begin // SLL
                result_o = a_i << shamt;
            end
            5'b00010: begin // SLTS (signed less-than)
                flag_o = (a_s < b_s);
            end
            5'b00011: begin // SLTU (unsigned less-than)
                flag_o = (a_i < b_i);
            end
            5'b00100: begin // XOR
                result_o = a_i ^ b_i;
            end
            5'b00101: begin // SRL
                result_o = a_i >> shamt;
            end
            5'b01101: begin // SRA
                result_o = a_s >>> shamt;
            end
            5'b00110: begin // OR
                result_o = a_i | b_i;
            end
            5'b00111: begin // AND
                result_o = a_i & b_i;
            end
            5'b11000: begin // EQ
                flag_o = (a_i == b_i);
            end
            5'b11001: begin // NE
                flag_o = (a_i != b_i);
            end
            5'b11100: begin // LTS (signed)
                flag_o = (a_s < b_s);
            end
            5'b11101: begin // GES (signed >=)
                flag_o = (a_s >= b_s);
            end
            5'b11110: begin // LTU (unsigned)
                flag_o = (a_i < b_i);
            end
            5'b11111: begin // GEU (unsigned >=)
                flag_o = (a_i >= b_i);
            end
            default: begin
                result_o = 32'b0;
                flag_o   = 1'b0;
            end
        endcase
    end
endmodule
