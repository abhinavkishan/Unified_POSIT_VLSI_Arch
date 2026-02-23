`timescale 1ns / 1ps

module Vector2sComp (
    input  logic [31:0] vin,
    input  logic [1:0]  p_m,
    output logic [31:0] vout
);

always_comb begin
    vout = vin;

    unique case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            vout[i*8 +: 8] =
                vin[i*8 + 7] ? ((~vin[i*8 +: 8]) + 8'd1)
                             : vin[i*8 +: 8];
        end
    end

    2'b01: begin
        vout[15:0]   =
            vin[15] ? ((~vin[15:0]) + 16'd1)
                    :  vin[15:0];

        vout[31:16]  =
            vin[31] ? ((~vin[31:16]) + 16'd1)
                    :  vin[31:16];
    end

    2'b10: begin
        vout =
            vin[31] ? ((~vin) + 32'd1)
                    :  vin;
    end

    endcase
end

endmodule