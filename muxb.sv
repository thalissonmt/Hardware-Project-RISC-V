module muxb
    (output logic [63:0]f,
    input logic [63:0] b,
    input logic [63:0] des,
    input logic [63:0] imm,
    input logic [1:0] s
    );
    
    always_comb begin
        if(s==2'b00) f = b;
        else if(s==2'b01) f = 4;
        else if(s==2'b10) f = imm;
        else if(s==2'b11) f = des;
    end

endmodule