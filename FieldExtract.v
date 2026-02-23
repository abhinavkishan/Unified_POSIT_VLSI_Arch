`timescale 1ns / 1ps

module FieldExtract(
    input  [31:0] V,
    input  [1:0]  pres,   // 00=8bit, 01=16bit, 10=32bit
    input         vec,
    output reg [15:0] exp,
    output reg [22:0] fraction
);

always @(*) begin
    exp      = 16'd0;
    fraction = 23'd0;

    case ({vec, pres})

    3'b100: begin
        exp      = { V[30:27], V[22:19], V[14:11], V[6:3] };
        fraction = { 11'd0,
                     V[26:24], V[18:16],
                     V[10:8],  V[2:0] };
    end

    3'b101: begin
        exp      = { 6'd0, V[30:26], V[14:10] };
        fraction = { 3'd0, V[25:16], V[9:0] };
    end

    3'b110: begin
        exp      = { 8'd0, V[30:23] };
        fraction = V[22:0];
    end

    3'b000: begin
        exp      = { 12'd0, V[30:27] };
        fraction = { 20'd0, V[26:24] };
    end

    3'b001: begin
        exp      = { 11'd0, V[30:26] };
        fraction = { 13'd0, V[25:16] };
    end

    default: begin
        exp      = { 8'd0, V[30:23] };
        fraction = V[22:0];
    end

    endcase
end

endmodule