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
            k_aligned[i*8 +: 8] =
                ({{3{k_in[i*5+4]}}, k_in[i*5 +: 5]}) <<< es;
        end
    end

    2'b01: begin
        k_aligned[15:0]  =
            ({{6{k_in[9]}},  k_in[9:0]}) <<< es;

        k_aligned[31:16] =
            ({{6{k_in[19]}}, k_in[19:10]}) <<< es;
    end

    2'b10: begin
       k_aligned =
            ({{12{k_in[19]}}, k_in}) <<< es;
    end

    endcase
end

endmodule