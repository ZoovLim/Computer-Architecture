/*-----------------------------------------------------------------------------

4190.308-002 Computer Architecture

Instructor: Prof. Jae W. Lee (jaewlee@snu.ac.kr)

Homework #3: RISC-V Pipeline in Verilog

Description:
	This module is your verilog pipeline.

-----------------------------------------------------------------------------*/

module riscv_pipeline
(
	input clk,
	input reset
);

	//IF stage
	reg [63:0] IF_pc;
	
	wire [31:0] IF_inst;
	
	//ID stage
	reg [31:0] ID_inst;
	
	wire [6:0] ID_opcode;
	wire [2:0] ID_funct3;
	wire [6:0] ID_funct7;
	wire [4:0] ID_rs1, ID_rs2, ID_rd;
	wire [63:0] ID_rf_data_rs1, ID_rf_data_rs2;
	wire [63:0] ID_rs1_data, ID_rs2_data;
	wire [63:0] ID_imm64;
	wire ID_alu_src;
	wire ID_mem_to_reg;
	wire ID_reg_write;
	wire ID_mem_read;
	wire ID_mem_write;
	wire [2:0] ID_alu_op;
	wire ID_halt;


	//EX stage
	reg [63:0] EX_rs1_data, EX_rs2_data;
	reg [63:0] EX_imm64;
	reg [4:0] EX_rd;
	reg EX_alu_src;
	reg EX_mem_to_reg;
	reg EX_reg_write;
	reg EX_mem_read;
	reg EX_mem_write;
	reg [2:0] EX_alu_op;
	reg EX_halt;

	wire [63:0] alu_lhs, alu_rhs, EX_alu_result;
	wire alu_zero, alu_sign;

	//Mem stage
	reg [63:0] MEM_rs2_data;
	reg [63:0] MEM_alu_result;
	reg MEM_zero, MEM_sign;
	reg [4:0] MEM_rd;
	reg MEM_mem_to_reg;
	reg MEM_reg_write;
	reg MEM_mem_read;
	reg MEM_mem_write;
	reg MEM_halt;

	wire [63:0] MEM_read_data;
	wire [63:0] MEM_fwd;

	//WB stage
	reg [63:0] WB_alu_result;
	reg [63:0] WB_mem_rddata;
	reg [4:0] WB_rd;
	reg WB_reg_write;
	reg WB_mem_to_reg;

	wire [63:0] WB_write_data;
	
	//Hazard detection unit & Forwarding unit
	reg hazard_detection;
	reg [2:0] forward_A;
	reg [2:0] forward_B;
	
	//Branch control
	wire ID_branch_check;
	reg EX_branch_check;
	reg MEM_branch_check;	
	reg [63:0] MEM_imm64;
	
	always @(*)
	begin
		hazard_detection <= reset ? 1'b0 : (((EX_mem_read == 1'b1) && (EX_rd != 4'b00) && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2))) ? 1'b1 : 1'b0);			
		forward_A <= reset ? 3'b000 : 
			(((EX_reg_write == 1'b1) && (EX_rd != 4'b0) && (ID_rs1 == EX_rd)) ? 3'b010 :
			(((MEM_reg_write == 1'b1) && (MEM_rd != 4'b0) && (ID_rs1 == MEM_rd) && (MEM_mem_read == 1'b1)) ? 3'b011 : 
			(((MEM_reg_write == 1'b1) && (MEM_rd != 4'b0) && (ID_rs1 == MEM_rd)) ? 3'b001 :
			(((WB_reg_write == 1'b1) && (WB_rd != 4'b0) && (ID_rs1 == WB_rd)) ? 3'b100 : 3'b000))));
		forward_B <= reset ? 3'b000 :
			(((EX_reg_write == 1'b1) && (EX_rd != 4'b0) && (ID_rs2 == EX_rd)) ? 3'b010 :
			(((MEM_reg_write == 1'b1) && (MEM_rd != 4'b0) && (ID_rs2 == MEM_rd) && (MEM_mem_read == 1'b1)) ? 3'b011 :
			(((MEM_reg_write == 1'b1) && (MEM_rd != 4'b0) && (ID_rs2 == MEM_rd)) ? 3'b001 :
			(((WB_reg_write == 1'b1) && (WB_rd != 4'b0) && (ID_rs2 == WB_rd)) ? 3'b100 : 3'b000))));			
	end	

	//--------------------IF stage-----------------------
	rom64 imem(IF_pc, IF_inst);

	always @(posedge clk)
	begin
		if(hazard_detection == 1'b0) 
		begin
			if(ID_branch_check == 1'b1)
			begin	
			IF_pc <= IF_pc - 4;
			ID_inst <= 32'h0;
			end		
			else if(EX_branch_check == 1'b1)
			begin		
			IF_pc <= IF_pc;
			ID_inst <= 32'h0;		
			end
			else if((MEM_branch_check == 1'b1) && (MEM_zero == 1'b1))
			begin
			IF_pc <= IF_pc + MEM_imm64;
			ID_inst <= 32'h0;
			end
			else if((MEM_branch_check == 1'b1) && (MEM_zero == 1'b0))
			begin
			IF_pc <= IF_pc + 4;
			ID_inst <= 32'h0;
			end
			else
			begin
			IF_pc <= reset ? 64'h0 : IF_pc + 4;
			ID_inst <= reset ? 32'h0 : IF_inst;
			end
		end
		else
		begin
			if(ID_branch_check == 1'b1)
			begin
			IF_pc <= IF_pc - 4;
			end	
		end		
	end
	
	//--------------------ID stage-----------------------

	inst_decoder id_unit(	.inst(ID_inst),
				.opcode(ID_opcode),
				.funct3(ID_funct3),
				.funct7(ID_funct7),
				.rs1(ID_rs1),
				.rs2(ID_rs2),
				.rd(ID_rd),
				.imm64(ID_imm64),
				.branch_check(ID_branch_check));

	pipeline_ctl id_ctl(	.opcode(ID_opcode),
				.funct3(ID_funct3),
				.funct7(ID_funct7),
				.hazard_detected(hazard_detection),
				.alu_src(ID_alu_src),
				.mem_to_reg(ID_mem_to_reg),
				.reg_write(ID_reg_write),
				.mem_read(ID_mem_read),
				.mem_write(ID_mem_write),
				.alu_operation(ID_alu_op),
				.halt(ID_halt));

	reg_file id_regfile(	.clk(clk), .rs1(ID_rs1), .rs2(ID_rs2),
				.rs1_data(ID_rf_data_rs1),
				.rs2_data(ID_rf_data_rs2),
				.rd(WB_rd), .write(WB_reg_write),
				.write_data(WB_write_data));

	//ID/EX pipeline registers
	always @(posedge clk)
	begin
		EX_alu_src	<= (reset) ? 1'h0 : ID_alu_src;
		EX_mem_to_reg	<= (reset) ? 1'h0 : ID_mem_to_reg;
		EX_reg_write	<= (reset) ? 1'h0 : ID_reg_write;
		EX_mem_read	<= (reset) ? 1'h0 : ID_mem_read;
		EX_mem_write	<= (reset) ? 1'h0 : ID_mem_write;
		EX_alu_op	<= (reset) ? 3'h0 : ID_alu_op;
		EX_halt		<= (reset) ? 1'h0 : ID_halt;

		EX_rs1_data	<= (reset) ? 64'h0 : ((forward_A == 3'b000) ? ID_rf_data_rs1 : ((forward_A == 3'b001) ? MEM_alu_result : ((forward_A == 3'b011) ? MEM_read_data : ((forward_A == 3'b100) ? WB_write_data : EX_alu_result))));
		EX_rs2_data	<= (reset) ? 64'h0 : ((forward_B == 3'b000) ? ID_rf_data_rs2 : ((forward_B == 3'b001) ? MEM_alu_result : ((forward_B == 3'b011) ? MEM_read_data : ((forward_B == 3'b100) ? WB_write_data : EX_alu_result))));
		EX_imm64	<= (reset) ? 64'h0 : ID_imm64;
		EX_rd		<= (reset) ? 5'h0 : ID_rd;
		
		EX_branch_check <= (reset) ? 1'b0 : ID_branch_check;
	end

	//------------------EX stage-----------------------

	assign alu_lhs = EX_rs1_data;
	assign alu_rhs = EX_alu_src ? EX_imm64 : EX_rs2_data;

	//ALU
	alu EX_alu(	.op(EX_alu_op),
			.lhs(alu_lhs), .rhs(alu_rhs),
			.result(EX_alu_result),
			.zero(alu_zero), .sign(alu_sign));

	//EX/MEM pipeline registers
	always @(posedge clk)
	begin
		MEM_mem_to_reg	<= (reset) ? 1'h0 : EX_mem_to_reg;
		MEM_reg_write	<= (reset) ? 1'h0 : EX_reg_write;
		MEM_mem_read	<= (reset) ? 1'h0 : EX_mem_read;
		MEM_mem_write	<= (reset) ? 1'h0 : EX_mem_write;
		MEM_halt	<= (reset) ? 1'h0 : EX_halt;

		MEM_rs2_data	<= (reset) ? 64'h0 : EX_rs2_data;
		MEM_alu_result	<= (reset) ? 64'h0 : EX_alu_result;
		MEM_zero	<= (reset) ? 1'h0 : alu_zero;
		MEM_sign	<= (reset) ? 1'h0 : alu_sign;
		MEM_rd		<= (reset) ? 5'h0 : EX_rd;
		
		MEM_branch_check <= (reset) ? 1'b0 : EX_branch_check;
		MEM_imm64 <= (reset) ? 64'h0 : EX_imm64;
	end

	//--------------------Mem stage------------------------

	mem64 MEM_dmem(	.clk(clk),
			.write_enable(MEM_mem_write),
			.halt(MEM_halt),
			.address(MEM_alu_result),
			.write_data(MEM_rs2_data),
			.read_data(MEM_read_data));

	//MEM/WB pipeline registers
	always @(posedge clk)
	begin
		WB_reg_write	<= (reset) ? 1'h0 : MEM_reg_write;
		WB_rd		<= (reset) ? 5'h0 : MEM_rd;
		WB_alu_result	<= (reset) ? 64'h0 : MEM_alu_result;
		WB_mem_rddata	<= (reset) ? 64'h0 : MEM_read_data;
		WB_mem_to_reg	<= (reset) ? 1'h0 : MEM_mem_to_reg;
	end

	//--------------------WB stage-----------------------
	assign WB_write_data = WB_mem_to_reg ? WB_mem_rddata : WB_alu_result;
	
endmodule
