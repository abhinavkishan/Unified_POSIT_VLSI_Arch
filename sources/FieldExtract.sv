`timescale 1ns / 1ps

module FieldExtract (
    input  logic [31:0] V,
    input  logic [1:0]  pres,
    input  logic        vec,
    output logic [15:0] exp,
    output logic [31:0] fraction
);

always_comb begin
    exp      = '0;
    fraction = '0;

    unique case ({vec, pres})

    3'b100: begin
        exp = { V[30:27], V[22:19], V[14:11], V[6:3] };
        fraction = {
            5'd0, V[26:24],
            5'd0, V[18:16],
            5'd0, V[10:8],
            5'd0, V[2:0]
        };
    end

    3'b101: begin
        exp = { 6'd0, V[30:26], V[14:10] };
        fraction = {
            6'd0, V[25:16],
            6'd0, V[9:0]
        };
    end

    3'b110: begin
        exp = { 8'd0, V[30:23] };
        fraction = { 9'd0, V[22:0] };
    end

    3'b000: begin
        exp = { 12'd0, V[30:27] };
        fraction = {
            24'd0,
            5'd0, V[26:24]
        };
    end

    3'b001: begin
        exp = { 11'd0, V[30:26] };
        fraction = {
            16'd0,
            6'd0, V[25:16]
        };
    end

    default: begin
        exp = { 8'd0, V[30:23] };
        fraction = { 9'd0, V[22:0] };
    end

    endcase
end

endmodule