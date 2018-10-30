module muxpc(mux_pc_signal,pc_zero,pc_one,mux_pc_out,pc_exception);
	input logic [1:0]mux_pc_signal;
	input logic [63:0]pc_zero;
	input logic [63:0]pc_one;
	input logic [63:0]pc_exception;
	output logic [63:0]mux_pc_out;

	always_comb begin
		if(mux_pc_signal==0)begin
			mux_pc_out = pc_zero;
		end else if(mux_pc_signal==1) begin
			mux_pc_out = pc_one;
		end else if(mux_pc_signal==2) begin
			mux_pc_out = pc_exception;
		end
	end

endmodule:muxpc 