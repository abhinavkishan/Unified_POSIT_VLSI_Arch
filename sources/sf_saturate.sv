module sf_saturate #(
    parameter LANE_WIDTH = 8,     
    parameter MAX_SF     = 126,
    parameter MIN_SF     = -126
)(
    input  logic signed [31:0] sf_in,   
    input  logic [1:0]         p_m,     
    output logic signed [31:0] sf_out
);

always_comb begin
    sf_out = '0;

    case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            automatic logic signed [7:0] lane;
            lane = sf_in[i*8 +: 8];

            if (lane > MAX_SF)
                sf_out[i*8 +: 8] = MAX_SF;
            else if (lane < MIN_SF)
                sf_out[i*8 +: 8] = MIN_SF;
            else
                sf_out[i*8 +: 8] = lane;
        end
    end

    2'b01: begin
        for (int i = 0; i < 2; i++) begin
            automatic logic signed [15:0] lane;
            lane = sf_in[i*16 +: 16];

            if (lane > MAX_SF)
                sf_out[i*16 +: 16] = MAX_SF;
            else if (lane < MIN_SF)
                sf_out[i*16 +: 16] = MIN_SF;
            else
                sf_out[i*16 +: 16] = lane;
        end
    end

    2'b10: begin
        if ($signed(sf_in) > MAX_SF)
            sf_out = MAX_SF;
        else if ($signed(sf_in) < MIN_SF)
            sf_out = MIN_SF;
        else
            sf_out = sf_in;
    end

    default: sf_out = sf_in;

    endcase
end

endmodule