`include "defines.v"

module id(

	output wire                                     stallreq,
	
	input wire										rst,
	input wire[`InstAddrBus]			pc_i,
	input wire[`InstBus]          inst_i,

	//����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire										ex_wreg_i,
	input wire[`RegBus]						ex_wdata_i,
	input wire[`RegAddrBus]       ex_wd_i,
	
	//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire										mem_wreg_i,
	input wire[`RegBus]						mem_wdata_i,
	input wire[`RegAddrBus]       mem_wd_i,
	
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	//�����һ��ָ����ת��ָ���ô��һ��ָ���������ʱ��is_in_delayslotΪtrue
	input wire                    is_in_delayslot_i,
	
	//�͵�regfile����Ϣ
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	output reg                    next_inst_in_delayslot_o,
	
	output reg                    branch_flag_o,
	output reg[`RegBus]           branch_target_address_o,       
	output reg[`RegBus]           link_addr_o,
	output reg                    is_in_delayslot_o,
	
	//�͵�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]         aluop_o,
	output reg[`AluSelBus]        alusel_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o
);

	wire[6:0] op1 = inst_i[6:0];
	wire[4:0] op2 = inst_i[11:7];
	wire[2:0] op3 = inst_i[14:12];
	wire[4:0] op4 = inst_i[19:15];
	wire[4:0] op5 = inst_i[24:20];
	wire[6:0] op6 = inst_i[31:25];
	
	reg[`RegBus]	imm;
	reg instvalid;
	
	wire[`RegBus] pc_plus_8;
	wire[`RegBus] pc_plus_4;
	wire[`RegBus] imm_sll2_signedext;  
	wire[`RegBus] imm_sll2_unsignedext;
	
	assign pc_plus_8 = pc_i + 8;
	assign pc_plus_4 = pc_i + 4;
	assign imm_sll2_signedext = {{20{inst_i[31]}}, inst_i[7],inst_i[30:25],inst_i[11:8],1'b0 };  
	assign imm_sll2_unsignedext = {20'b0, inst_i[7],inst_i[30:25],inst_i[11:8],1'b0 };  
  
	assign stallreq = `NoStop;
  
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;				
		end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[11:7];
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[19:15];
			reg2_addr_o <= inst_i[24:20];		
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			next_inst_in_delayslot_o <= `NotInDelaySlot; 	
		  case (op1)
		    `OP_LUI:	begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
				alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				reg1_addr_o <= 5'b00000;
				imm <= {inst_i[31:12], 12'h0};		
				wd_o <= inst_i[11:7];		  	
				instvalid <= `InstValid;
			end
			`OP_AUIPC:	begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
				alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				reg1_addr_o <= 5'b00000;
				imm <= {inst_i[31:12], 12'h0} + pc_i;		wd_o <= inst_i[11:7];		  	
				instvalid <= `InstValid;
			end
			`OP_OP:		begin
		    	case (op3)
		    				`FUNCT3_OR:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end  
		    				`FUNCT3_AND:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  	
		    				`FUNCT3_XOR:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  				
		    				`FUNCT3_SLL: begin
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end 
							`FUNCT3_SRL_SRA : begin
                                if (op6 == 7'b0000000) begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
									alusel_o <= `EXE_RES_SHIFT;        reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
									instvalid <= `InstValid;  
                                end else   	begin
                                    wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
                                    alusel_o <= `EXE_RES_SHIFT;        reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                                    instvalid <= `InstValid;      
                                end			
		  					end			
							`FUNCT3_SLT: begin
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`FUNCT3_SLTU: begin
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`FUNCT3_ADD_SUB: 
                                if (op6 == 7'b0000000) begin
                                    wreg_o <= `WriteEnable;        aluop_o <= `EXE_ADD_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;        reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                                    instvalid <= `InstValid;    
                                end else	  begin
                                    wreg_o <= `WriteEnable;        aluop_o <= `EXE_SUB_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;        reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                                    instvalid <= `InstValid;    
                                end
							default:	begin
						    end
				endcase
			end
			
			`OP_OP_IMM:	begin
				case(op3)
				
				`FUNCT3_ORI:			begin                        //ORIָ��
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{20{inst_i[31]}}, inst_i[31:20]};		wd_o <= inst_i[11:7];
					instvalid <= `InstValid;	
				end
				`FUNCT3_ANDI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
					alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{20{inst_i[31]}}, inst_i[31:20]};		wd_o <= inst_i[11:7];		  	
					instvalid <= `InstValid;	
				end	 	
				`FUNCT3_XORI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
					alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{20{inst_i[31]}}, inst_i[31:20]};		wd_o <= inst_i[11:7];		  	
					instvalid <= `InstValid;	
				end	 		
				`FUNCT3_SLTI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
					alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{20{inst_i[31]}}, inst_i[31:20]};		wd_o <= inst_i[11:7];		  	
					instvalid <= `InstValid;	
				end
				`FUNCT3_SLTIU:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
					alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {21'b0, inst_i[30:20]};		wd_o <= inst_i[11:7];		  	
					instvalid <= `InstValid;	
				end
				`FUNCT3_ADDI:			begin
					wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADD_OP;
					alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{20{inst_i[31]}}, inst_i[31:20]};		wd_o <= inst_i[11:7];		  	
					instvalid <= `InstValid;	
				end
				`FUNCT3_SLLI : begin
                    wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
                    alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b1;    reg2_read_o <= 1'b0;          
                    imm[4:0] <= {27'b000000000000000000000000000,inst_i[24:20]};        wd_o <= inst_i[11:7];
                    instvalid <= `InstValid;      
                end 
				`FUNCT3_SRLI_SRAI : begin
					if (op6 == 7'b0000000) begin
						wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
						alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm[4:0] <= {27'b000000000000000000000000000,inst_i[24:20]};        wd_o <= inst_i[11:7];
                    instvalid <= `InstValid;
					end else begin
						wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
						alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm[4:0] <= {27'b000000000000000000000000000,inst_i[24:20]};        wd_o <= inst_i[11:7];
						instvalid <= `InstValid;
					end
				end
				default:			begin
				end
				endcase
			end
			`OP_JAL: begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_JAL_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;    reg2_read_o <= 1'b0;
                wd_o <= inst_i[11:7];    
                link_addr_o <= pc_plus_4 ;
                branch_target_address_o <= pc_i + {{12{inst_i[31]}}, inst_i[19:12],inst_i[20:20],inst_i[30:25], inst_i[24:21],1'b0};
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;              
                instvalid <= `InstValid;    	
			end
			`OP_JALR: begin
				wreg_o <= `WriteEnable;		aluop_o <= `EXE_JALR_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  		wd_o <= inst_i[11:7];
		  		link_addr_o <= pc_plus_4;					
			    branch_target_address_o <= reg1_o + pc_i;
			    branch_flag_o <= `Branch;  
			    next_inst_in_delayslot_o <= `InDelaySlot;
			    instvalid <= `InstValid;	
			end	
			`OP_BRANCH		:
				case (op3) 								 											  											
				`FUNCT3_BEQ:			begin
		  		    wreg_o <= `WriteDisable;		aluop_o <= `EXE_BEQ_OP;
		  		    alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  		    instvalid <= `InstValid;	
		  		    if(reg1_o == reg2_o) begin
						branch_target_address_o <= pc_i + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
				end
				`FUNCT3_BNE:			begin
                    wreg_o <= `WriteDisable;        aluop_o <= `EXE_BLEZ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;    
                    if(reg1_o != reg2_o) begin
                        branch_target_address_o <= pc_i + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                        next_inst_in_delayslot_o <= `InDelaySlot;              
                    end
                end
				`FUNCT3_BGE:			begin
					wreg_o <= `WriteDisable;		aluop_o <= `EXE_BGTZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
					instvalid <= `InstValid;	
					if(reg1_o >= reg2_o) begin
						branch_target_address_o <= pc_i + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;		  	
					end
				end
				`FUNCT3_BGEU:			begin
                    wreg_o <= `WriteDisable;        aluop_o <= `EXE_BGTZ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;    
                    if(reg1_o >= reg2_o) begin
						branch_target_address_o <= pc_i + imm_sll2_unsignedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;              
                    end
                end
				`FUNCT3_BLT:			begin
					wreg_o <= `WriteDisable;		aluop_o <= `EXE_BLEZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
					instvalid <= `InstValid;	
					if(reg1_o < reg2_o) begin
						branch_target_address_o <= pc_i + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;		  	
					end
				end
				`FUNCT3_BLTU:			begin
					wreg_o <= `WriteDisable;        aluop_o <= `EXE_BLEZ_OP;
                    alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;    
                    if(reg1_o < reg2_o) begin
                        branch_target_address_o <= pc_i + imm_sll2_unsignedext;
                        branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;              
                    end
                end
				default begin end
				endcase
		endcase		  //case op
		end  
		
	end         //always
	

	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;		
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
			&& (ex_wd_i != `RegNumLog2'h0)&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
			&& (mem_wd_i !=`RegNumLog2'h0)&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

endmodule