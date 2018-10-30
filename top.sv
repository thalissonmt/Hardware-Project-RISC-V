`timescale 1ps/1ps

module top;
    localparam CLKDELAY = 2; 

    logic clk;
	logic PcWr, InMemWr, InRegWr, MdrWr,EpcWr,CaseWr;
	logic MuxAS, rst, BaRegWr, DtMemWr, Overflow;
	logic RegAWr, RegBWr, AluOutWr, rst2, Igual, Menor;
	logic [1:0] MuxBS,break_type,break_mem_type,ShiftOP,MuxPC,MuxDataMem;
	logic [2:0] AluOp, immtype,MuxDS;
	logic [31:0] count;
	logic [31:0] state, complete_inst;
	logic [63:0] out_pc,out_Rs1, out_Rs2, out_data_mem,Alu_Out,in_bank_register,out_break_mem_type;
	logic [63:0] out_muxDS,out_shift,Case_Number,out_EPC,out_mux_Data_mem;
	logic [63:0] out_Causa_Reg;
	logic [4:0] Rs1, Rs2, Rd;
    
    initial rst = 1'b0;
    initial clk = 1'b0;	
    initial rst2 = 1;
    always #(CLKDELAY) clk = ~clk;

	datapath godInCommand(.clk(clk),.PcWr(PcWr),.InMemWr(InMemWr),.InRegWr(InRegWr),.MuxAS(MuxAS),.MuxBS(MuxBS),
						.MuxPC(MuxPC),.AluOp(AluOp),.rst(rst),.out_pc(out_pc),.AluOutWr(AluOutWr),.complete_inst(complete_inst),
						.BaRegWr(BaRegWr),.RegAWr(RegAWr),.RegBWr(RegBWr),.MuxDS(MuxDS),.out_data_mem(out_data_mem),
						.out_Rs1(out_Rs1),.out_Rs2(out_Rs2),.rst2(rst2),.MdrWr(MdrWr),.DtMemWr(DtMemWr),.immtype(immtype),.Igual(Igual),
						.Rs1(Rs1),.Rs2(Rs2),.Rd(Rd),.Alu_Out(Alu_Out),.Menor(Menor),.break_type(break_type),.in_bank_register(in_bank_register),
						.break_mem_type(break_mem_type),.out_break_mem_type(out_break_mem_type),.out_muxDS(out_muxDS),.ShiftOP(ShiftOP),
						.out_shift(out_shift),.EpcWr(EpcWr),.Case_Number(Case_Number),.CaseWr(CaseWr),.MuxDataMem(MuxDataMem),
						.out_EPC(out_EPC),.out_Causa_Reg(out_Causa_Reg),.out_mux_Data_mem(out_mux_Data_mem),.Overflow(Overflow));

   	control ControlUnit(.clk(clk),.PcWr(PcWr),.InMemWr(InMemWr),.InRegWr(InRegWr),.MuxAS(MuxAS),.DtMemWr(DtMemWr),
   						.MuxBS(MuxBS),.MuxPC(MuxPC),.AluOp(AluOp),.rst(rst),.state(state),.AluOutWr(AluOutWr),
   						.complete_inst(complete_inst),.BaRegWr(BaRegWr),.RegAWr(RegAWr),.RegBWr(RegBWr),.MuxDS(MuxDS),
   						.MdrWr(MdrWr),.immtype(immtype),.Igual(Igual),.Menor(Menor),.break_type(break_type),.break_mem_type(break_mem_type),
   						.ShiftOP(ShiftOP),.EpcWr(EpcWr),.Case_Number(Case_Number),.CaseWr(CaseWr),.MuxDataMem(MuxDataMem),.Overflow(Overflow));

	initial begin
		$monitor($time, " entra_banco = %b", in_bank_register);
			for (count = 0;count<=12'b111111111111;count++) begin
				if(count==3)
					rst2 = 0;
				#1;
			end
		#1 $finish;
	end // initial

endmodule // datapath

//
