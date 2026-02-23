`timescale 1ns/1ps 

module VectorSubtract(
    input  [15:0] exp,
    input  [1:0]  pres,   // 00=8bit, 01=16bit, 10=32bit
    input         vec,    // vector enable
    output signed [31:0] sf
);

assign sf =
    
    (pres == 2'b00) ? 
        (
            (vec == 1'b1) ?
                {
                    ($signed({4'b0000, exp[15:12]}) - 8'sd7),
                    ($signed({4'b0000, exp[11:8] }) - 8'sd7),
                    ($signed({4'b0000, exp[7:4]  }) - 8'sd7),
                    ($signed({4'b0000, exp[3:0]  }) - 8'sd7)
                }
                :
                {
                    24'sd0,
                    ($signed({4'b0000, exp[3:0]}) - 8'sd7)
                }
        )
    
    : (pres == 2'b01) ?
    (
        (vec == 1'b1) ?
            {
                ($signed({11'b0, exp[15:11]}) - 16'sd15),
                ($signed({11'b0, exp[7:3]  }) - 16'sd15)
            }
            :
            {
                16'sd0,
                ($signed({11'b0, exp[7:3]}) - 16'sd15)
            }
    )
    
    :
    (
        $signed({24'b0, exp[7:0]}) - 32'sd127
    );

endmodule