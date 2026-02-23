`timescale 1ns / 1ps

module ExponentShifter (
    input  logic [31:0] vin,
    input  logic [1:0]  es,
    input  logic [1:0]  pres,
    output logic [31:0] fraction,
    output logic [31:0] exp
);

logic [31:0] mask;

always_comb begin
    fraction = '0;
    exp      = '0;

    mask = (32'h1 << es) - 1;

    unique case (pres)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            logic [7:0] lane;
            lane = vin[i*8 +: 8];

            exp[i*8 +: 8] =
                (lane >> (6 - es + 1)) & mask;

            fraction[i*8 +: 8] =
                lane & ((1 << (6 - es + 1)) - 1);
        end
    end

    2'b01: begin
        logic [15:0] lane0, lane1;

        lane0 = vin[15:0];
        lane1 = vin[31:16];

        exp[15:0] =
            (lane0 >> (14 - es + 1)) & mask;
        fraction[15:0] =
            lane0 & ((1 << (14 - es + 1)) - 1);

        exp[31:16] =
            (lane1 >> (14 - es + 1)) & mask;
        fraction[31:16] =
            lane1 & ((1 << (14 - es + 1)) - 1);
    end

    2'b10: begin
        exp =
            (vin >> (30 - es + 1)) & mask;
        fraction =
            vin & ((1 << (30 - es + 1)) - 1);
    end

    endcase
end

endmodule