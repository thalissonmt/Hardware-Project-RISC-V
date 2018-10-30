module breakregister(iyoda_type,acm_type,paguso_type);


	input logic[63:0] acm_type;
	input logic[1:0] iyoda_type;
	output logic[63:0] paguso_type;
	logic[31:0] zero;
	logic[31:0] um;
	logic[47:0] zero1;
	logic[47:0] um1;
	logic[55:0] zero2;
	logic[55:0] um2;

	initial begin
		zero = 0;
		zero1 = 0;
		zero2 = 0;
		um = 32'b11111111111111111111111111111111;
		um1 = 48'b111111111111111111111111111111111111111111111111;
		um2 = 56'b11111111111111111111111111111111111111111111111111111111;
	end

	always_comb begin
		case(iyoda_type)
			2'b00:begin //ld
					paguso_type <= acm_type;
				end

			2'b01:begin //lw
					
					paguso_type[31:0] <= acm_type[31:0];
					if(acm_type[31]==1'b0)begin
						paguso_type[63:32] <= zero;
					end else if(acm_type[31]==1'b1) begin
						paguso_type[63:32] <= um;
					end
				end

			2'b10:begin //lh
					
					paguso_type[15:0] <= acm_type[15:0];
					if(acm_type[15]==1'b0)begin	
						paguso_type[63:16] <= zero1;
					end else  if(acm_type[15]==1'b1)begin
						paguso_type[63:16] <= um1;
					end			
				end

			2'b11:begin //lbu
					
					paguso_type[7:0] <= acm_type[7:0];
					if(acm_type[7]==1'b0)begin
						paguso_type[63:8] <= zero2;
					end else if(acm_type[7]==1'b1) begin
						paguso_type[63:8] <= zero2;
					end	
				end

		endcase //iyoda_type

	end

endmodule