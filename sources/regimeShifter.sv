module regimeShifter (
    input  logic [31:0] vin,
    input  logic [19:0] zero_count,
    input  logic [1:0]  p_m,
    output logic [31:0] vout
);

logic [4:0] shift_amt;

always_comb begin
    vout = '0;

    case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            shift_amt = zero_count[i*5 +: 5] + 1;
            vout[i*8 + 7] = vin[i*8 + 7];
            vout[i*8 +: 7] = vin[i*8 +: 7] << shift_amt;
        end
    end

    2'b01: begin
        shift_amt = zero_count[4:0] + 1;
        vout[15] = vin[15];
        vout[14:0] = vin[14:0] << shift_amt;

        shift_amt = zero_count[9:5] + 1;
        vout[31] = vin[31];
        vout[30:16] = vin[30:16] << shift_amt;
    end

    2'b10: begin
        shift_amt = zero_count[4:0] + 1;
        vout[31] = vin[31];
        vout[30:0] = vin[30:0] << shift_amt;
    end

    endcase
end

endmodule