module signale(input logic [31:0] data, output logic [63:0] dataout);

    logic [63:0] zerow;

    logic [31:0] dataw; 
    logic [63:0] dataoutw;

    initial begin
        zerow = 0;
    end

    always_comb begin
        dataw = data;
        if(data[31]==1)begin
            dataw = ~dataw;
            dataw = dataw+1;
            dataoutw = zerow + dataw;
            dataoutw = ~dataoutw;
            dataout = dataoutw + 1;
        end else begin
           dataout = zerow + dataw;
        end
    end

endmodule
