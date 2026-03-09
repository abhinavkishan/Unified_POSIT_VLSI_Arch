module vector_quire_shift_128 (
    input  logic signed [127:0] in_val,   
    input  logic signed [31:0]  shamt,    
    input  logic [1:0]          mode,     
    output logic signed [127:0] out_val
);

always_comb begin
    out_val = '0;

    case (mode)

    
    2'b00: begin
        for (int i = 0; i < 4; i++) begin
            automatic logic signed [31:0] lane;
            automatic logic signed [7:0]  shift;

            lane  = in_val[i*32 +: 32];
            shift = shamt[i*8 +: 8];

            out_val[i*32 +: 32] = lane <<< shift;
        end
    end


    2'b01: begin
        for (int i = 0; i < 2; i++) begin
            automatic logic signed [63:0] lane;
            automatic logic signed [15:0] shift;

            lane  = in_val[i*64 +: 64];
            shift = shamt[i*16 +: 16];

            out_val[i*64 +: 64] = lane <<< shift;
        end
    end


    
    2'b10: begin
        out_val = in_val <<< shamt;
    end

    default: out_val = in_val;

    endcase
end

endmodule