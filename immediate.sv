module immediate(instruction,immtype,outimm);
	input logic [31:0]instruction;
	input logic [2:0]immtype;
	output logic [31:0]outimm;

	always_comb begin
		case(immtype)
		3'b000:begin
			outimm <= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		end // 3'b000: R
		3'b001:begin

			outimm <= instruction[31:20];

			if(instruction[31]==1'b0)begin
				outimm[31:12] <= 20'b00000000000000000000;
			end else begin
				outimm[31:12] <= 20'b11111111111111111111;
			end
		end // 3'b001: I
		3'b010:begin
			outimm[11:5] <= instruction[31:25];
			outimm[4:0] <= instruction[11:7];

			if(instruction[31]==1'b0)begin
				outimm[31:12] <= 20'b00000000000000000000;
			end else begin
				outimm[31:12] <= 20'b11111111111111111111;
			end
		end // 3'b010: S
		3'b011:begin
			outimm[0] <= 1'b0;

			outimm[11] <= instruction[7];

			outimm[12] <= instruction[31];

			outimm[4:1] <= instruction[11:8];

			outimm[10:5] <= instruction[30:25];

			if(instruction[31]==1'b0)begin
				outimm[31:13] <= 19'b0000000000000000000;
			end else begin
				outimm[31:13] <= 19'b1111111111111111111;
			end
		end // 3'b011: SB
		3'b100:begin	
			outimm[0] <= 1'b0;

			outimm[10:1] <= instruction[30:21];

			outimm[11] <= instruction[20];

			outimm[19:12] <= instruction[19:12];

			outimm[20] <= instruction[31];

			if(instruction[31]==1'b0)begin
				outimm[31:21]<=11'b00000000000;
			end else begin
				outimm[31:21] <=11'b11111111111;
			end
		end // 3'b100: UJ
		3'b101:begin
			
			outimm[11:0] <= 12'b000000000000;
		
			outimm[31:12] <= instruction[31:12];
		
		end // 3'b101: U
		default:begin
		end//memes

	endcase
	end

endmodule