module shamt_saturate #(
    parameter MAX_SF = 126,
    parameter MIN_SF = -126
)(
    input  logic signed [31:0] sfc,     
    input  logic [1:0]         p_m,     

    output logic signed [31:0] shamt,   
    output logic signed [31:0] sfqc     
);

always_comb begin

    shamt = '0;
    sfqc  = '0;

    case (p_m)

    
    2'b00: begin
        for (int i=0;i<4;i++) begin

            logic signed [7:0] lane;

            lane = sfc[i*8 +: 8];

            if (lane > MAX_SF) begin
                shamt[i*8 +: 8] = MAX_SF;
                sfqc [i*8 +: 8] = lane - MAX_SF;
            end

            else if (lane < MIN_SF) begin
                shamt[i*8 +: 8] = MIN_SF;
                sfqc [i*8 +: 8] = lane - MIN_SF;
            end

            else begin
                shamt[i*8 +: 8] = lane;
                sfqc [i*8 +: 8] = 0;
            end

        end
    end


    
    2'b01: begin
        for (int i=0;i<2;i++) begin

            logic signed [15:0] lane;

            lane = sfc[i*16 +: 16];

            if (lane > MAX_SF) begin
                shamt[i*16 +: 16] = MAX_SF;
                sfqc [i*16 +: 16] = lane - MAX_SF;
            end

            else if (lane < MIN_SF) begin
                shamt[i*16 +: 16] = MIN_SF;
                sfqc [i*16 +: 16] = lane - MIN_SF;
            end

            else begin
                shamt[i*16 +: 16] = lane;
                sfqc [i*16 +: 16] = 0;
            end

        end
    end


    
    2'b10: begin

        if (sfc > MAX_SF) begin
            shamt = MAX_SF;
            sfqc  = sfc - MAX_SF;
        end

        else if (sfc < MIN_SF) begin
            shamt = MIN_SF;
            sfqc  = sfc - MIN_SF;
        end

        else begin
            shamt = sfc;
            sfqc  = 0;
        end

    end

    endcase

end

endmodule