module datapath(PcWr, InRegWr, clk, MuxAS, MuxBS, MuxPC, AluOutWr, rst, rst2, InMemWr, DtMemWr,AluOp, out_pc, complete_inst,out_muxDS, 
				BaRegWr, RegAWr, RegBWr, MuxDS, out_Rs1, out_Rs2, MdrWr, out_data_mem, immtype, Igual, Rs1, Rs2, Rd, Alu_Out,Menor,break_type,
				in_bank_register,break_mem_type,out_break_mem_type,ShiftOP,out_shift,EpcWr,Case_Number,CaseWr,MuxDataMem,out_EPC,out_Causa_Reg,
				out_mux_Data_mem,Overflow);
	
	input logic PcWr;
	input logic InRegWr;
	input logic clk;
	input logic MuxAS;
	input logic RegAWr;
	input logic RegBWr;
	input logic InMemWr;
	input logic rst;
	input logic EpcWr;
	input logic CaseWr;
	input logic rst2;
	input logic AluOutWr;
	input logic DtMemWr;
	input logic BaRegWr;
	input logic MdrWr;
	input logic [1:0] MuxBS,break_type,break_mem_type,ShiftOP,MuxPC,MuxDataMem;
	input logic [2:0] AluOp, immtype,MuxDS;
	input logic [63:0] Case_Number;
	output logic [4:0] Rs1, Rs2, Rd;
	output logic Igual, Menor, Overflow;
	output logic [31:0] complete_inst;
	output logic [63:0] out_pc, out_Rs1, out_Rs2, out_data_mem,Alu_Out,in_bank_register,out_break_mem_type,out_muxDS,out_shift,out_EPC,out_Causa_Reg,out_mux_Data_mem;

	logic [63:0] out_muxAS, out_muxBS, out_ula, out_shiftl,const_254,const_255;
	logic [63:0] out_muxPC, out_RegA, out_RegB, out_MDR, out_sign_ext;
	logic [31:0] zero, out_mem_inst, outimm;
	initial zero = 0;
	initial out_pc = 0;
	initial const_254 = 254;
	initial const_255 = 255;

	Registrador64 pc(.Entrada(out_muxPC),.Saida(out_pc),.Clk(clk),.Load(PcWr));	
	Memoria32 Instructions(.raddress(out_pc[31:0]),.waddress(zero),.Datain(zero),.Dataout(out_mem_inst),.Wr(InMemWr),.Clk(clk));
	Instr_Reg_RISC_V InstReg(.Reset(rst),.Load_ir(InRegWr),.Entrada(out_mem_inst),.Instr31_0(complete_inst),.Instr11_7(Rd),.Instr24_20(Rs2),.Instr19_15(Rs1),.Clk(clk));
	immediate Imm(.instruction(complete_inst),.immtype(immtype),.outimm(outimm));
	signale Sign_Ext(.data(outimm),.dataout(out_sign_ext));
	shiftl Shift_Left(.data(out_sign_ext),.outsl(out_shiftl));
	bancoReg Register_Bank(.clock(clk),.reset(rst2),.write(BaRegWr),.regreader1(Rs1),.regreader2(Rs2),.regwriteaddress(Rd),.datain(in_bank_register),.dataout1(out_Rs1),.dataout2(out_Rs2));
	Registrador64 RegA(.Entrada(out_Rs1),.Saida(out_RegA),.Clk(clk),.Load(RegAWr));	
	Registrador64 RegB(.Entrada(out_Rs2),.Saida(out_RegB),.Clk(clk),.Load(RegBWr));	
	muxpc muxAS(.pc_zero(out_pc),.pc_one(out_RegA),.mux_pc_out(out_muxAS),.mux_pc_signal(MuxAS));
	muxb muxBS(.b(out_RegB),.imm(out_sign_ext),.des(out_shiftl),.s(MuxBS),.f(out_muxBS));
	breakregister BRL(.iyoda_type(break_type),.acm_type(out_muxDS),.paguso_type(in_bank_register));
	breakmem BMM(.bmt(break_mem_type),.in(out_RegB),.read(out_MDR),.out(out_break_mem_type));
	ula64 Alu(.A(out_muxAS),.B(out_muxBS),.S(out_ula),.Seletor(AluOp),.Igual(Igual),.Menor(Menor),.Overflow(Overflow));
	Registrador64 AluOut(.Entrada(out_ula),.Saida(Alu_Out),.Clk(clk),.Load(AluOutWr));	
	muxpc muxPC(.pc_zero(out_ula),.pc_one(Alu_Out),.pc_exception(in_bank_register),.mux_pc_out(out_muxPC),.mux_pc_signal(MuxPC));
	muxDS muxDS(.out_ula(Alu_Out),.lui(out_sign_ext),.out_mdr(out_MDR),.Menor(Menor),.out_shift(out_shift),.out_pc(out_pc),.selector(MuxDS),.f(out_muxDS));
	muxpc mux_Data_Mem(.pc_zero(Alu_Out),.pc_one(const_254),.pc_exception(const_255),.mux_pc_out(out_mux_Data_mem),.mux_pc_signal(MuxDataMem));
	Memoria64 Data_Mem(.raddress(out_mux_Data_mem),.waddress(Alu_Out),.Datain(out_break_mem_type),.Dataout(out_data_mem),.Wr(DtMemWr),.Clk(clk));
	Registrador64 MDR(.Entrada(out_data_mem),.Saida(out_MDR),.Clk(clk),.Load(MdrWr));
	Deslocamento Shift_Register(.Shift(ShiftOP),.Entrada(out_RegA),.N(out_sign_ext[5:0]),.Saida(out_shift));

	Registrador64 EPC(.Entrada(Alu_Out),.Saida(out_EPC),.Clk(clk),.Load(EpcWr));
	Registrador64 Causa_Reg(.Entrada(Case_Number),.Saida(out_Causa_Reg),.Clk(clk),.Load(CaseWr));

endmodule // datapath
 