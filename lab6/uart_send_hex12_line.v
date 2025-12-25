module uart_send_hex12_line(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [11:0] value12,
    output reg         busy,

    input  wire        uart_ready,
    output reg         uart_valid,
    output reg  [7:0]  uart_data
);

    function [7:0] nib2ascii;
        input [3:0] n;
        begin
            if (n < 4'd10) nib2ascii = 8'd48 + n;       // '0'..'9'
            else           nib2ascii = 8'd55 + n;       // 'A'..'F'
        end
    endfunction

    localparam [2:0] IDLE=3'd0, H3=3'd1, H2=3'd2, H1=3'd3, H0=3'd4, NL=3'd5;

    reg [2:0] st;
    reg [11:0] lat;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st         <= IDLE;
            busy       <= 1'b0;
            uart_valid <= 1'b0;
            uart_data  <= 8'h00;
            lat        <= 12'd0;
        end else begin
            uart_valid <= 1'b0;

            case (st)
                IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        lat  <= value12;
                        busy <= 1'b1;
                        st   <= H3;
                    end
                end

                H3: if (uart_ready) begin uart_data <= nib2ascii(4'h0);        uart_valid <= 1'b1; st <= H2; end
                H2: if (uart_ready) begin uart_data <= nib2ascii(lat[11:8]);   uart_valid <= 1'b1; st <= H1; end
                H1: if (uart_ready) begin uart_data <= nib2ascii(lat[7:4]);    uart_valid <= 1'b1; st <= H0; end
                H0: if (uart_ready) begin uart_data <= nib2ascii(lat[3:0]);    uart_valid <= 1'b1; st <= NL; end
                NL: if (uart_ready) begin uart_data <= 8'h0A;                  uart_valid <= 1'b1; st <= IDLE; end

                default: st <= IDLE;
            endcase
        end
    end

endmodule
