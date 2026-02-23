`timescale 1ns / 1ps

module FieldExtract(
    input [31:0] V,
    output [15:0] exp,
    output [22:0] fraction,
    input [1:0] pres,
    input vec
    );
    
    
  assign exp =
    (vec == 1'b1) ?
        (
            (pres == 2'b00) ? { V[30:27], V[22:19], V[14:11], V[6:3] } :
            (pres == 2'b01) ? { 6'b0, V[30:26], V[14:10] } :
                              { 8'b0, V[30:23] }
        )
    :
        (
            (pres == 2'b00) ? { 12'b0, V[30:27] } :
            (pres == 2'b01) ? { 11'b0, V[30:26] } :
                              { 8'b0, V[30:23] }
        );
        
   assign fraction =
    (vec == 1'b1) ?
        (
            (pres == 2'b00) ? { {11{1'b0}}, V[26:24], V[18:16], V[10:8], V[2:0] } :
            (pres == 2'b01) ? { {3{1'b0}}, V[25:16], V[9:0] } :
                              V[22:0]
        )
    :
        (
            (pres == 2'b00) ? { {20{1'b0}}, V[26:24] } :
            (pres == 2'b01) ? { {13{1'b0}}, V[25:16] } :
                              V[22:0]
        );
endmodule