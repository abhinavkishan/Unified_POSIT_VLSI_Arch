`timescale 1ns / 1ps

module FieldExtract (
    input  logic [31:0] V,
    input  logic [1:0]  pres,
    output logic [15:0] exp,
    output logic [31:0] fraction
);

always_comb begin
    exp      = '0;
    fraction = '0;

    unique case (pres)

    2'b00: begin
        exp = { V[30:27], V[22:19], V[14:11], V[6:3] };

        fraction = {
            5'b0001, V[26:24],
            5'b0001, V[18:16],
            5'b0001, V[10:8],
            5'b0001, V[2:0]
        };
    end

    2'b01: begin
        exp = { 6'd0, V[30:26], V[14:10] };

        fraction = {
            6'b00001, V[25:16],
            6'b00001, V[9:0]
        };
    end

    default: begin
        exp = { 8'd0, V[30:23] };

        fraction = { 1'b1, V[22:0] };
    end

    endcase
end

endmodule