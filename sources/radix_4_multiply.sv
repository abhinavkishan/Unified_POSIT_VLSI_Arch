`timescale 1ns / 1ps

module vector_multiplier #(
    parameter W = 32
)(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [1:0]  precision_mode,   // 00=8bit, 01=16bit, 10=32bit
    output logic [63:0] P
);

    logic [7:0] A_lane [3:0];
    logic [7:0] B_lane [3:0];

    logic [15:0] pp [3:0][3:0];
    logic [63:0] shifted_pp [3:0][3:0];

    
    assign {A_lane[3], A_lane[2], A_lane[1], A_lane[0]} = A;
    assign {B_lane[3], B_lane[2], B_lane[1], B_lane[0]} = B;

   
    always_comb begin

        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                pp[i][j]        = 16'd0;
                shifted_pp[i][j]= 64'd0;
            end
        end

        case (precision_mode)

       
        2'b10: begin
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    pp[i][j] = A_lane[i] * B_lane[j];
                end
            end
        end

       
        2'b01: begin
            for (int i = 0; i < 2; i++) begin
                for (int j = 0; j < 2; j++) begin
                    pp[i][j] = A_lane[i] * B_lane[j];
                end
            end

            for (int i = 2; i < 4; i++) begin
                for (int j = 2; j < 4; j++) begin
                    pp[i][j] = A_lane[i] * B_lane[j];
                end
            end
        end

        
        2'b00: begin
            for (int i = 0; i < 4; i++) begin
                pp[i][i] = A_lane[i] * B_lane[i];
            end
        end

        endcase

        
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                shifted_pp[i][j] = 
                    64'(pp[i][j]) << (8*(i+j));
            end
        end

    end

    always_comb begin
        P = 64'd0;

        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                P = P + shifted_pp[i][j];
            end
        end
    end

endmodule