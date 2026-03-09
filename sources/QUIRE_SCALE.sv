`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2026 22:41:31
// Design Name: 
// Module Name: QUIRE_SCALE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module QUIRE_SCALE(
input logic [3:0]sp,
input logic [3:0]sc,
input logic [31:0]fc,sfc,sfp,
input logic [63:0]fp,
output logic [127:0]quirec,quirep,
output logic [31:0]sfqc,sfqp,
    input logic op,
    input logic [5:0]ctrl
    );
    logic [127:0] quireo1;
    logic [127:0] quireo2;
    logic [31:0] shamt1,shamt2;
    quire_sign_from_32(
    .in_val(fc),     
    .sign_vec(sc),   
    .operation_sub(op),
    .mode(ctrl[5:4]),       
   .out(quireo1));
   
   quire_sign_vector(
   .fp(fp),        
   .sp(sp),        
     .operation_sub(op),
     .mode(ctrl[5:4]),      
  .out(quireo2));
    
    shamt_saturate(
     .shamt_in(sfc),   
     .p_m(ctrl[5:4]),     
    .shamt_out(shamt1),
    .sfqc(sfqc)
    );
    
    shamt_saturate(
     .shamt_in(sfp),   
     .p_m(ctrl[5:4]),     
    .shamt_out(shamt2),
    .sfqc(sfqp)
    );
    
    vector_quire_shift_128 (
   .in_val(quireo1),   
   .shamt(shamt1),    
    .mode(ctrl[5:4]),     
    .out_val(quirec)
);

vector_quire_shift_128 (
   .in_val(quireo2),   
   .shamt(shamt2),    
    .mode(ctrl[5:4]),     
    .out_val(quirep)
);

endmodule
