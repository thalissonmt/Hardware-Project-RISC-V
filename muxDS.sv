module muxDS
    (output logic [63:0]f,
    input logic [63:0] out_ula,
    input logic [63:0] out_mdr, 
    input logic [63:0] lui,
    input logic [63:0] out_shift,
    input logic [63:0] out_pc,
    input logic Menor,
    input logic [2:0] selector
    );
    
    always_comb begin
        if(selector==3'b000) f = out_ula;
        else if(selector==3'b001) f = lui;
        else if(selector==3'b010) f = out_mdr;
        else if(selector==3'b011) f = Menor;
        else if(selector==3'b100) f = out_shift;
        else if(selector==3'b101) f = out_pc;
        else if(selector==3'b110) f = 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        else if(selector==3'b111) f = 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    end

endmodule