`timescale 1ns / 1ps

module vector_adder (
    input  logic [31:0] vin,
    input  logic [19:0] zero_count,
    input  logic [1:0]  p_m,
    output logic signed [19:0] k_out
);

always_comb begin
    k_out = '0;

    unique case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            logic signed [4:0] count;
            logic regime_bit;

            count      = zero_count[i*5 +: 5];
            regime_bit = vin[i*8 + 6];

            k_out[i*5 +: 5] =
                regime_bit ? (count - 5'sd1)
                           : (-count);
        end
    end

    2'b01: begin
        logic signed [9:0] count;
        logic regime_bit;

        count      = zero_count[9:0];
        regime_bit = vin[14];
        k_out[9:0] =
            regime_bit ? (count - 10'sd1)
                       : (-count);

        count      = zero_count[19:10];
        regime_bit = vin[30];
        k_out[19:10] =
            regime_bit ? (count - 10'sd1)
                       : (-count);
    end

    2'b10: begin
        logic signed [19:0] count;
        logic regime_bit;

        count      = zero_count;
        regime_bit = vin[30];

        k_out =
            regime_bit ? (count - 20'sd1)
                       : (-count);
    end

    endcase
end