`timescale 1ns / 1ps

module vector_inverter (
    input  logic [31:0] vin,
    input  logic [1:0]  p_m,
    output logic [31:0] vout
);

always_comb begin
    vout = vin;

    unique case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            vout[i*8 + 7] = vin[i*8 + 7];
            vout[i*8 +: 7] =
                vin[i*8 + 6] ? ~vin[i*8 +: 7] : vin[i*8 +: 7];
        end
    end

    2'b01: begin
        vout[15]   = vin[15];
        vout[14:0] = vin[14] ? ~vin[14:0] : vin[14:0];

        vout[31]   = vin[31];
        vout[30:16]= vin[30] ? ~vin[30:16] : vin[30:16];
    end

    2'b10: begin
        vout[31]   = vin[31];
        vout[30:0] = vin[30] ? ~vin[30:0] : vin[30:0];
    end

    endcase
end

endmodule