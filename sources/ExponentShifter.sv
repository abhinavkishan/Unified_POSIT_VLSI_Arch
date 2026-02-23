`timescale 1ns / 1ps

module ExponentShifter (
    input  logic [31:0] vin,
    input  logic [1:0]  es,
    input  logic [1:0]  pres,
    output logic [31:0] fraction,
    output logic [31:0] exp
);

logic [31:0] mask;
logic [31:0] frac_mask;

always_comb begin
    fraction = '0;
    exp      = '0;

    mask = (32'h1 << es) - 1;

    unique case (pres)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            logic [7:0] lane;
            logic [7:0] frac_bits;
            int frac_width;

            lane = vin[i*8 +: 8];

            exp[i*8 +: 8] =
                (lane >> (6 - es + 1)) & mask;

            frac_width = 7 - es;

            frac_mask  = (32'h1 << frac_width) - 1;
            frac_bits  = lane & frac_mask;

            fraction[i*8 +: 8] =
                (1 << frac_width) | frac_bits;
        end
    end

    2'b01: begin
        logic [15:0] lane0, lane1;
        int frac_width;

        frac_width = 15 - es;
        frac_mask  = (32'h1 << frac_width) - 1;

        lane0 = vin[15:0];
        lane1 = vin[31:16];

        exp[15:0] =
            (lane0 >> (14 - es + 1)) & mask;
        fraction[15:0] =
            (1 << frac_width) | (lane0 & frac_mask);

        exp[31:16] =
            (lane1 >> (14 - es + 1)) & mask;
        fraction[31:16] =
            (1 << frac_width) | (lane1 & frac_mask);
    end

    2'b10: begin
        int frac_width;

        frac_width = 31 - es;
        frac_mask  = (32'h1 << frac_width) - 1;

        exp =
            (vin >> (30 - es + 1)) & mask;

        fraction =
            (1 << frac_width) | (vin & frac_mask);
    end

    endcase
end

endmodule