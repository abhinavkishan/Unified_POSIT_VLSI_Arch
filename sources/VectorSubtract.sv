`timescale 1ns / 1ps

module VectorSubtract (
    input  logic [15:0] exp,
    input  logic [1:0]  pres,
    output logic [31:0] shamt
);

always_comb begin
    shamt = '0;

    unique case (pres)

    2'b00: begin
            shamt = {
                ($signed({4'b0, exp[15:12]}) - 8'sd7),
                ($signed({4'b0, exp[11:8] }) - 8'sd7),
                ($signed({4'b0, exp[7:4]  }) - 8'sd7),
                ($signed({4'b0, exp[3:0]  }) - 8'sd7)
            };
        
        
    end

    2'b01: begin
       
            shamt = {
                ($signed({11'b0, exp[9:5]}) - 16'sd15),
                ($signed({11'b0, exp[4:0]}) - 16'sd15)
            };
       
    end

    default: begin
        shamt = $signed({24'b0, exp[7:0]}) - 32'sd127;
    end

    endcase
end

endmodule