module vector_adder (
    input  wire [31:0] vin,
    input  wire [19:0] zero_count,   
    input  wire [1:0]  p_m,
    output reg  signed [19:0] k_out
);

integer i;

reg signed [4:0] count;
reg regime_bit;

always @(*) begin
    k_out = 20'd0;

    case (p_m)
    2'b00: begin
        for (i = 0; i < 4; i = i + 1) begin
            count = zero_count[i*5 +: 5];
            regime_bit = vin[i*8 + 6]; 

            if (regime_bit)
                k_out[i*5 +: 5] = count - 5'd1;
            else
                k_out[i*5 +: 5] = -count;   
        end
    end

    2'b01: begin
        count = zero_count[4:0];
        regime_bit = vin[14];

        if (regime_bit)
            k_out[4:0] = count - 5'd1;
        else
            k_out[4:0] = -count;

        count = zero_count[9:5];
        regime_bit = vin[30];

        if (regime_bit)
            k_out[9:5] = count - 5'd1;
        else
            k_out[9:5] = -count;
    end

    2'b10: begin
        count = zero_count[4:0];
        regime_bit = vin[30]; 

        if (regime_bit)
            k_out[4:0] = count - 5'd1;
        else
            k_out[4:0] = -count;
    end

    default: k_out = 20'd0;

    endcase
end

endmodule