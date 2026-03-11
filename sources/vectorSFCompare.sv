`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2026 21:21:36
// Design Name: 
// Module Name: vectorSFCompare
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


module vectorSFCompare(
    input logic [31:0] sfqs,sfqp,
    input logic [1:0] pres,
    output logic [3:0]cmp
    );
    always_comb begin
        cmp = 4'b0000;
        case(pres)
            2'b00:
                begin
                    for(int i=0;i<4;i++) begin
                        if($signed(sfqs[i*8 +: 8]) < $signed(sfqp[i*8 +: 8]))
                            cmp[i] = 1'b1;
                    end
                end
                2'b01:
                begin
                    
                        if($signed(sfqs[31:16]) < $signed(sfqp[31:16]))
                            cmp[3:2] = 2'b11;
                
                        if($signed(sfqs[15:0]) < $signed(sfqp[15:0]))
                            cmp[1:0] = 2'b11;
                        end
                2'b10:
                begin
                    if($signed(sfqs) < $signed(sfqp))
                        cmp = 4'b1111;
                end
                endcase
    
    end
    
endmodule
