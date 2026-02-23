module vector_inverter (
    input  wire [31:0] vin,
    input  wire [1:0]  p_m, 
    output reg  [31:0] vout
);

integer i;

always @(*) begin
    case (p_m)
    2'b00: begin
        for (i = 0; i < 4; i = i + 1) begin
            vout[i*8 + 7] = vin[i*8 + 7];

            if (vin[i*8 + 6])
                vout[i*8 +: 7] = ~vin[i*8 +: 7];
            else
                vout[i*8 +: 7] = vin[i*8 +: 7];
        end
    end

    2'b01: begin
        vout[15] = vin[15];
        if (vin[14])
            vout[14:0] = ~vin[14:0];
        else
            vout[14:0] = vin[14:0];

        vout[31] = vin[31];
        if (vin[30])
            vout[30:16] = ~vin[30:16];
        else
            vout[30:16] = vin[30:16];
    end

    2'b10: begin
        vout[31] = vin[31]; 

        if (vin[30])        
            vout[30:0] = ~vin[30:0];
        else
            vout[30:0] = vin[30:0];
    end

    default: vout = vin;

    endcase
end

endmodule
