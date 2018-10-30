module shiftl(input logic [63:0] data, output logic [63:0] outsl);

    always_comb begin
        outsl = data << 1; 
    end

endmodule