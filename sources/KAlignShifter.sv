`timescale 1ns / 1ps

module k_align_shifter (
    input  logic signed [19:0] k_in,
    input  logic [1:0]         precision_mode,
    input  logic [1:0]         es,
    output logic signed [31:0] k_aligned
);

always_comb begin
    k_aligned = '0;

    unique case (precision_mode)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            logic signed [7:0] k_lane;
            k_lane = k_in[i*5 +: 5];
            k_aligned[i*8 +: 8] = k_lane <<< es;
        end
    end

    2'b01: begin
        logic signed [15:0] k_lane;

        k_lane = k_in[9:0];
        k_aligned[15:0] = k_lane <<< es;

        k_lane = k_in[19:10];
        k_aligned[31:16] = k_lane <<< es;
    end

    2'b10: begin
        logic signed [31:0] k_lane;

        k_lane = k_in[19:0];
        k_aligned = k_lane <<< es;
    end

    endcase
end

endmodule