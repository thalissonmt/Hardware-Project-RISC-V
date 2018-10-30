module control(clk,rst,opcode,PcWr,MuxAS,immtype,MuxBS,MuxPC,AluOp,DtMemWr,InMemWr,InRegWr,
				state,BaRegWr,RegAWr,RegBWr,MuxDS,complete_inst,AluOutWr, MdrWr, Igual, Menor,break_type,
				break_mem_type,ShiftOP, EpcWr,Case_Number,CaseWr,MuxDataMem,Overflow);
	input logic clk;
	input logic rst;
	input logic Igual, Menor, Overflow;
	input logic [6:0]opcode;
	input logic [31:0]complete_inst;
	output logic PcWr;
	output logic MuxAS;
	output logic BaRegWr;
	output logic RegAWr;
	output logic EpcWr;
	output logic RegBWr;
	output logic AluOutWr;
	output logic CaseWr;
	output logic [1:0]MuxBS,ShiftOP;
	output logic [2:0]AluOp, immtype,MuxDS;
	output logic InMemWr, InRegWr, MdrWr, DtMemWr;
	output logic [31:0]state;
	output logic [1:0] break_type;
	output logic [1:0] break_mem_type;
	output logic [1:0] MuxPC,MuxDataMem;
	output logic [63:0] Case_Number;
	logic [1:0]next_break_type,next_break_mem_type,ShiftOP_next,MuxDataMem_next;
	logic [2:0]Operation, immtype_next,MuxDS_next,MuxDS_lock;
	logic [1:0]MuxBS_next;
	logic [31:0] choice;
	logic Memedopcode;
	initial InMemWr = 0;

	enum {RESET,FETCH,DECODER,PASSING_REGISTER,SAVE_RESULT,WRITE_REGISTER,MEM_READ,WRITE_DATA_MEMORY,MDR_WRITE,COMPARE_BEQ,COMPARE_BNE,
		COMPARE_BGE,COMPARE_BLT,JAL,EXCEPTION,WRITE_PC,BREAK} next_state=RESET;


	always_ff@(posedge clk or negedge rst)begin 
		if(rst)begin
			state <= RESET;
		end else begin
			state <= next_state;
		end
	end

	always_comb begin
		case(state)

		RESET:begin
			next_state = FETCH;
			CaseWr = 0;
			Operation = 1;
			MuxBS_next = 1;
			immtype_next = 0;
			choice = -1;
			MuxDS_lock = 3;
			ShiftOP = 3;
			ShiftOP_next = 3;
			Memedopcode = 1;			
			PcWr = 0;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 0;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			MuxDS = MuxDS_lock;
			break_type = 0;
			next_break_type = 0;
			break_mem_type = 0;
			next_break_mem_type = 0;
			MuxDataMem = 0;
			MuxDataMem_next = 0;
			end
		FETCH:begin
			next_state = DECODER;
			PcWr = 1;
			CaseWr = 0;
			InRegWr = 1;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 0;
			Memedopcode = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			MuxDS = MuxDS_lock;
			break_type = 0;
			next_break_type = 0;
			break_mem_type = 0;
			next_break_mem_type = 0;
			ShiftOP = ShiftOP_next;
			MuxDataMem = MuxDataMem_next;
		    end
		DECODER:begin
			PcWr = 0;
			CaseWr = 0;
			InRegWr = 0;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 0;
			if(complete_inst[6:0]==7'b1101111)begin //AluOut = PC+IMM
				MuxBS = 3;
				immtype = 4;	
				next_state = WRITE_REGISTER;
			end else begin //sum desl
				MuxBS = 3;	
				immtype = 3;
				next_state = PASSING_REGISTER;
			end
			AluOp = 1;
			AluOutWr = 1;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			MuxDS = MuxDS_lock;
			break_type = 0;
			break_mem_type = 0;
			EpcWr = 0;
			MuxDataMem = 0;
			if(complete_inst[6:0]==7'b0110011) begin //R-Type
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b000) begin// add or sub
					if(complete_inst[31:25]==7'b0000000) begin //add
						Operation = 1;
						MuxBS_next = 0;
						immtype_next = 0;
						choice = 0;
						MuxDS_next = 0;
					end else begin //sub
						Operation = 2;
						MuxBS_next = 0;
						immtype_next = 0;
						choice = 0;
						MuxDS_next = 0;
					end
				end else if(complete_inst[14:12]==3'b111)begin //and
					Operation = 3;
					MuxBS_next = 0;
					immtype_next = 0;
					choice = 0;
					MuxDS_next = 0;
				end else if(complete_inst[14:12]==3'b010)begin //slt
					Operation = 2;
					MuxBS_next = 0;
					immtype_next = 0;
					choice = 7;
					MuxDS_next = 3;
				end
			end

			if(complete_inst[6:0]==7'b0010011) begin //I-type
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b000) begin //addi
					if(complete_inst[31:7]!=0) begin
						immtype_next = 1;
						Operation = 1;
						MuxBS_next = 2;
						choice = 0;
						MuxDS_next = 0;
					end
				end else if(complete_inst[14:12]==3'b010)begin //slti
					immtype_next = 1;
					Operation = 2;
					MuxBS_next = 2;
					choice = 7;
					MuxDS_next = 3;
				end else if(complete_inst[14:12]==3'b101)begin //srli or srai
					if(complete_inst[31:26]==6'b000000)begin//srli
						immtype_next = 1;
						ShiftOP_next = 1;
						choice = 7;
						MuxDS_next = 4;
					end else if(complete_inst[31:26]==6'b010000)begin //srai
						immtype_next = 1;
						ShiftOP_next = 2;
						choice = 7;
						MuxDS_next = 4;
					end
				end else if(complete_inst[14:12]==3'b001)begin //slli
					immtype_next = 1;
					ShiftOP_next = 0;
					choice = 7;
					MuxDS_next = 4;
				end
			end

			if(complete_inst[6:0]==7'b0000011) begin //load 
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b011) begin //load double word
					immtype_next = 1;
					Operation = 1;
					MuxBS_next = 2;
					choice = 1;
					MuxDS_next = 2;
					MuxDataMem_next = 0;
				end
			end

			if(complete_inst[6:0]==7'b0000011)begin//load
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b010)begin//load word
					immtype_next = 1;
					Operation = 1;
					choice = 1;
					MuxBS_next = 2;
					MuxDS_next = 2;
					next_break_type = 1;
					MuxDataMem_next = 0;
				end
			end

			if(complete_inst[6:0]==7'b0000011)begin//load
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b001)begin//load half word
					immtype_next = 1;
					Operation = 1;
					choice = 1;
					MuxBS_next = 2;
					MuxDS_next = 2;
					next_break_type = 2;
					MuxDataMem_next = 0;
				end
			end

			if(complete_inst[6:0]==7'b0000011)begin//load
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b100)begin//load byte unsigned
					immtype_next = 1;
					Operation = 1;
					choice = 1;
					MuxBS_next = 2;
					MuxDS_next = 2;
					next_break_type = 3;
					MuxDataMem_next = 0;
				end
			end				

			if(complete_inst[6:0]==7'b0100011) begin //store
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b111) begin //store double word
					immtype_next = 2;
					Operation = 1;
					MuxBS_next = 2;
					choice = 2;
				end
			end

			if(complete_inst[6:0]==7'b0100011)begin //store
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b010)begin  //store word
					immtype_next = 2;
					Operation = 1;
					MuxBS_next = 2;
					choice = 2;
					next_break_mem_type = 1;
				end
			end

			if(complete_inst[6:0]==7'b0100011)begin //store
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b001)begin  //store half word
					immtype_next = 2;
					Operation = 1;
					MuxBS_next = 2;
					choice = 2;
					next_break_mem_type = 2;
				end
			end

			if(complete_inst[6:0]==7'b0100011)begin //store
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b000)begin  //store byte
					immtype_next = 2;
					Operation = 1;
					MuxBS_next = 2;
					choice = 2;
					next_break_mem_type = 3;
				end
			end

			if(complete_inst[6:0]==7'b0110111) begin //lui
				Memedopcode = 0;
				immtype_next = 5;
				MuxDS_next = 1;
				next_state = WRITE_REGISTER;
			end
			
			if(complete_inst[6:0]==7'b1100011) begin //branch
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b000) begin //beq
					immtype_next = 3;
					Operation = 2;
					MuxBS_next = 0;
					choice = 3;
				end
			end

			if(complete_inst[6:0]==7'b1100111) begin //branch
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b001) begin //bne
					immtype_next = 3;
					Operation = 2;
					MuxBS_next = 0;
					choice = 4;
				end
			end

			if(complete_inst[6:0]==7'b1100111) begin //branch
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b101) begin //bge
					immtype_next = 3;
					Operation = 2;
					MuxBS_next = 0;
					choice = 5;
				end
			end

			if(complete_inst[6:0]==7'b1100111) begin //branch
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b100) begin //blt
					immtype_next = 3;
					Operation = 2;
					MuxBS_next = 0;
					choice = 6;
				end
			end

			if(complete_inst[6:0]==7'b1101111) begin //jal
				Memedopcode = 0;
				immtype_next = 4;
				choice = 8;
				MuxDS_next = 5;
			end

			if(complete_inst[6:0]==7'b1100111) begin //jalr
				Memedopcode = 0;
				if(complete_inst[14:12]==3'b000) begin //jalr
					immtype_next = 1;
					Operation = 1;
					MuxBS_next = 2;
					choice = 8;
					MuxDS_next = 5;
				end
			end //

			if(complete_inst[6:0]==7'b0010011) begin //nop
				Memedopcode = 0;
				if(complete_inst[31:7]==0) begin
					next_state = RESET;
				end
			end

			if(complete_inst[6:0]==7'b1110011) begin //break
				Memedopcode = 0;
				next_state = BREAK;
			end

			if(Memedopcode)begin //opcode
				Operation = 2;
				Case_Number = 0;
				EpcWr =  0;
				MuxBS_next = 1;
				MuxDS_next = 2;
				next_break_type = 3;
				choice = 9;
				MuxDataMem_next = 1;
			end

			if(Overflow)begin //Overflow
				Operation = 2;
				Case_Number = 1;
				EpcWr =  0;
				MuxBS_next = 1;
				MuxDS_next = 2;
				next_break_type = 3;
				choice = 9;
				MuxDataMem_next = 2;
			end
			// $display(" OPCODE = %b ",opcode);
			end
		PASSING_REGISTER:begin
			if(choice==-1)begin
				next_state = RESET;
			end else if(choice==0)begin
				next_state = SAVE_RESULT;
				MuxAS = 1;
			end else if(choice==1)begin
				next_state = SAVE_RESULT;
				MuxAS = 1;
			end else if(choice==2)begin
				next_state = SAVE_RESULT;
				MuxAS = 1;
			end else if(choice==3)begin
				next_state = COMPARE_BEQ;
				MuxAS = 1;
			end else if(choice==4)begin
				next_state = COMPARE_BNE;
				MuxAS = 1;
			end else if(choice==5)begin
				next_state = COMPARE_BGE;
				MuxAS = 1;
			end else if(choice==6)begin
				next_state = COMPARE_BLT;
				MuxAS = 1;
			end else if(choice==7)begin
				next_state = WRITE_REGISTER;
				MuxAS = 1;
			end else if(choice==8)begin
				next_state = SAVE_RESULT;
				MuxAS = 1;
			end else if(choice==9)begin
				next_state = SAVE_RESULT;
				MuxAS = 0;
			end 
			CaseWr = 0;
			PcWr = 0;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 1;
			RegBWr = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = next_break_type;
			MuxDS = MuxDS_lock;
			break_mem_type = next_break_mem_type;
			ShiftOP = ShiftOP_next;
			MuxDataMem = MuxDataMem_next;
			end
		SAVE_RESULT:begin
			if(!Overflow)begin
				if(choice==-1)begin
					next_state = RESET;
				end else if(choice==0)begin
					next_state = WRITE_REGISTER;
					MuxAS = 1;
				end else if(choice==1)begin
					next_state = MEM_READ;
					MuxAS = 1;
				end else if(choice==2)begin
					next_state = MEM_READ;
					MuxAS = 1;
				end else if(choice==8)begin
					next_state = WRITE_REGISTER;
					MuxAS = 1;
				end else if(choice==9)begin
					next_state = EXCEPTION;
					MuxAS = 0;
				end
				PcWr = 0;
				CaseWr = 0;
				InRegWr = 0;
				immtype = immtype_next;
				BaRegWr = 0;
				RegAWr = 0;
				RegBWr = 0;
				MuxBS = MuxBS_next;
				AluOp = Operation;
				AluOutWr = 1;
				MuxPC = 0;
				DtMemWr = 0;
				MdrWr = 0;
				break_type = next_break_type;
				MuxDS = MuxDS_lock;
				break_mem_type = next_break_mem_type;
				MuxDataMem = MuxDataMem_next;
			end else begin //if Overflow
				Operation = 2;
				Case_Number = 1;
				EpcWr =  0;
				MuxBS_next = 1;
				MuxDS_next = 2;
				next_break_type = 3;
				choice = 9;
				MuxDataMem_next = 2;
				next_state = PASSING_REGISTER;
			end
			end
		WRITE_REGISTER:begin
			if(choice==8)begin
				next_state = JAL;
			end else begin
				next_state = RESET;
			end
			PcWr = 0;
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 1;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = next_break_type;
			MuxDS = MuxDS_next;
			break_mem_type = next_break_mem_type;
			ShiftOP = ShiftOP_next;
			MuxDataMem = MuxDataMem_next;
			end
		MEM_READ:begin
			next_state = MDR_WRITE;
			PcWr = 0;
			CaseWr = 0;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = next_break_type;
			MuxDS = MuxDS_lock;
			break_mem_type = next_break_mem_type;
			MuxDataMem = MuxDataMem_next;
			end // MEM_READ:end
		MDR_WRITE:begin
			if(choice == 1)begin
				next_state = WRITE_REGISTER;
			end else if(choice == 2)begin
				next_state = WRITE_DATA_MEMORY;
			end else if(choice == 9)begin
				next_state = WRITE_PC;
			end
			PcWr = 0;
			MuxPC = 0;
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 1;
			break_type = next_break_type;
			MuxDS = MuxDS_lock;
			break_mem_type = next_break_mem_type;
			MuxDataMem = MuxDataMem_next;
			end
		WRITE_DATA_MEMORY:begin
			next_state = RESET;
			PcWr = 0;
			CaseWr = 0;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			MuxPC = 0;
			DtMemWr = 1;
			MdrWr = 0;
			break_type = next_break_type;
			break_mem_type = next_break_mem_type;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		COMPARE_BEQ:begin
			next_state = RESET;
			if(Igual)begin
				MuxPC = 1;
				PcWr = 1;
			end else begin
				MuxPC = 0;
				PcWr = 0;
			end 	
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = 0;
			break_mem_type = 0;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		COMPARE_BGE:begin
			next_state = RESET;
			if(!Menor)begin
				MuxPC = 1;
				PcWr = 1;
			end else begin
				MuxPC = 0;
				PcWr = 0;
			end 	
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = 0;
			break_mem_type = 0;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		COMPARE_BLT:begin
			next_state = RESET;
			if(Menor)begin
				MuxPC = 1;
				PcWr = 1;
			end else begin
				MuxPC = 0;
				PcWr = 0;
			end 	
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = 0;
			break_mem_type = 0;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		COMPARE_BNE:begin
			next_state = RESET;
			if(!Igual)begin
				MuxPC = 1;
				PcWr = 1;
			end else begin
				MuxPC = 0;
				PcWr = 0;
			end 	
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = 0;
			break_mem_type = 0;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		JAL:begin
			next_state = RESET;
			MuxPC = 1;
			PcWr = 1;
			InRegWr = 0;
			CaseWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 1;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_type = 0;
			break_mem_type = 0;
			MuxDS = MuxDS_lock;
			MuxDataMem = MuxDataMem_next;
			end
		EXCEPTION:begin			
			next_state = MEM_READ;
			EpcWr = 1;
			CaseWr = 1;
			MuxPC = 0;
			PcWr = 0;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 0;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_mem_type = 0;
			break_type = next_break_type;
			MuxDS = MuxDS_next;
			MuxDataMem = MuxDataMem_next;
		end
		WRITE_PC:begin			
			next_state = RESET;
			EpcWr = 0;
			CaseWr = 0;
			MuxPC = 2;
			PcWr = 1;
			InRegWr = 0;
			immtype = immtype_next;
			BaRegWr = 0;
			RegAWr = 0;
			RegBWr = 0;
			MuxAS = 0;
			MuxBS = MuxBS_next;
			AluOp = Operation;
			AluOutWr = 0;
			DtMemWr = 0;
			MdrWr = 0;
			break_mem_type = 0;
			break_type = next_break_type;
			MuxDS = MuxDS_next;
			MuxDataMem = MuxDataMem_next;
		end
		BREAK:begin			
			next_state = BREAK;
		end
		endcase

	end

endmodule