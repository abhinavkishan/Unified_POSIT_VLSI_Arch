`timescale 1ns/1ps

module MULTIPLY(
input logic [3:0] sa,sb,
input logic [31:0] sfa,sfb,
input logic [31:0] fa,fb,
output logic [31:0] sfp,
output logic [63:0] fp,
output logic [3:0] sp,
input logic [5:0] ctrlr
);

mult32_fraction_vector rsab(fa,fb,ctrlr[5:4],fp);
assign sp=sa^sb;
vector_sf_adder vsa(.a(sfa),.b(sfb),.p_m(ctrlr[5:4]),.sum(sfp));

endmodule
