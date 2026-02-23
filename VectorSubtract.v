`timescale 1ns/1ps 
module VectorSubtract(
    input  [15:0] exp,
    input  [1:0]  pres,
    input         vec,
    output reg signed [31:0] sf
);

always @(*) begin
    sf = 32'sd0;

    case (pres)

    2'b00: begin
        if (vec) begin
            sf = {
                ($signed({4'b0, exp[15:12]}) - 8'sd7),
                ($signed({4'b0, exp[11:8] }) - 8'sd7),
                ($signed({4'b0, exp[7:4]  }) - 8'sd7),
                ($signed({4'b0, exp[3:0]  }) - 8'sd7)
            };
        end
        else begin
            sf = {24'sd0,
                  ($signed({4'b0, exp[3:0]}) - 8'sd7)};
        end
    end

    2'b01: begin
        if (vec) begin
            sf = {
                ($signed({11'b0, exp[9:5]}) - 16'sd15),
                ($signed({11'b0, exp[4:0]}) - 16'sd15)
            };
        end
        else begin
            sf = {16'sd0,
                  ($signed({11'b0, exp[4:0]}) - 16'sd15)};
        end
    end

    default: begin
        sf = $signed({24'b0, exp[7:0]}) - 32'sd127;
    end

    endcase
end

endmodule