module breakmem(bmt,in,read,out);

	input logic [1:0] bmt;
	input logic [63:0] in;
	input logic [63:0] read;
	output logic [63:0] out;

	always_comb begin
		case(bmt)
			2'b00:begin //sd
					out <= in;
				end

			2'b01:begin //sw
					
					out[31:0] <= in[31:0];
					out[63:32] <= read[63:32];
				end

			2'b10:begin //sh
					
					out[15:0] <= in[15:0];	
					out[63:16] <= read[63:16];
								
				end

			2'b11:begin //sb
					
					out[7:0] <= in[7:0];
					out[63:8] <= read[63:8];
			
				end

		endcase 

	end

endmodule