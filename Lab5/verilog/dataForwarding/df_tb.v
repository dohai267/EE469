/*
Author: David Dolengewicz
Summary: Test the operation of the Program_Control module
*/

`include "dataForwarding.v"

//test bench
module df_tb();

wire [31:0] 	instrIFID,	//Data inputs
				instrIDEX,
				instrEXMEM,
				instrMEMWB,
				aluEXMEM_Data,
				aluMEMWB_Data,
				EXMEM_Data2Mem,
				MEMWB_MemData;
					
wire [31:0]		jmp0D,		//Data outputs
				jmp1D,
				aluD0,
				aluD1,
				exmemD,
				memMemD;	
					
wire			jmp0,			//Control outputs
				jmp1,
				stall,
				calc_branch,
				alu0,
				alu1,
				exmem,
				mem_mem;		

df_tester tester(	.instrIFID(instrIFID),	//inputs
					.instrIDEX(instrIDEX),
					.instrEXMEM(instrEXMEM),
					.instrMEMWB(instrMEMWB),
					.aluEXMEM_Data(aluEXMEM_Data),
					.aluMEMWB_Data(aluMEMWB_Data),
					.EXMEM_Data2Mem(EXMEM_Data2Mem),
					.MEMWB_MemData(MEMWB_MemData),
					.jmp0D(jmp0D),		//Data outputs
					.jmp1D(jmp1D),
					.aluD0(aluD0),
					.aluD1(aluD1),
					.exmemD(exmemD),
					.memMemD(memMemD),
					.jmp0(jmp0),			//Control outputs
					.jmp1(jmp1),
					.stall(stall),
					.calc_branch(calc_branch),
					.alu0(alu0),
					.alu1(alu1),
					.exmem(exmem),
					.mem_mem(mem_mem)		);							

dataForwarding dut(	.instrIFID(instrIFID),	//inputs
					.instrIDEX(instrIDEX),
					.instrEXMEM(instrEXMEM),
					.instrMEMWB(instrMEMWB),
					.aluEXMEM_Data(aluEXMEM_Data),
					.aluMEMWB_Data(aluMEMWB_Data),
					.EXMEM_Data2Mem(EXMEM_Data2Mem),
					.MEMWB_MemData(MEMWB_MemData),
					.jmp0D(jmp0D),		//Data outputs
					.jmp1D(jmp1D),
					.aluD0(aluD0),
					.aluD1(aluD1),
					.exmemD(exmemD),
					.memMemD(memMemD),
					.jmp0(jmp0),			//Control outputs
					.jmp1(jmp1),
					.stall(stall),
					.calc_branch(calc_branch),
					.alu0(alu0),
					.alu1(alu1),
					.exmem(exmem),
					.mem_mem(mem_mem)		);								
								
   // Store waveform data
   initial begin
      $dumpfile("DFTest.vcd");
      $dumpvars(4, dut);
   end
																
endmodule





//tester							
								
module df_tester(	instrIFID,	//inputs (tester outputs)
					instrIDEX,
					instrEXMEM,
					instrMEMWB,
					aluEXMEM_Data,
					aluMEMWB_Data,
					EXMEM_Data2Mem,
					MEMWB_MemData,
					jmp0D,		//Data outputs (tester inputs)
					jmp1D,
					aluD0,
					aluD1,
					exmemD,
					memMemD,
					jmp0,			//Control outputs (tester inputs)
					jmp1,
					stall,
					calc_branch,
					alu0,
					alu1,
					exmem,
					mem_mem		);
								
output wire [31:0] 	instrIFID,	//outputs
					instrIDEX,
					instrEXMEM,
					instrMEMWB;
					
output reg [31:0]	aluEXMEM_Data,
					aluMEMWB_Data,
					EXMEM_Data2Mem,
					MEMWB_MemData;
					
input wire [31:0]	jmp0D,		//inputs
					jmp1D,
					aluD0,
					aluD1,
					exmemD,
					memMemD;	
					
input wire			jmp0,		//inputs
					jmp1,
					stall,
					calc_branch,
					alu0,
					alu1,
					exmem,
					mem_mem;

reg	[4:0]		op_IFID,
				op_IDEX,
				op_EXMEM,
				op_MEMWB,	
                rs_IFID,
				rs_IDEX,
				rs_EXMEM,
				rs_MEMWB,
                rt_IFID, 
				rt_IDEX,
				rt_EXMEM,
				rt_MEMWB,
                rd_IFID,
				rd_IDEX,
				rd_EXMEM,
				rd_MEMWB;
				
reg [5:0]       funct_IFID, 	 			 		
                funct_IDEX,	
                funct_EXMEM, 	
                funct_MEMWB; 	

assign	instrIFID	=	{op_IFID, rs_IFID, rt_IFID, rd_IFID, 5'b11111, funct_IFID};
assign  instrIDEX	=	{op_IDEX, rs_IDEX, rt_IDEX, rd_IDEX, 5'b11111, funct_IDEX};
assign  instrEXMEM	=	{op_EXMEM, rs_EXMEM, rt_EXMEM, rd_EXMEM, 5'b11111, funct_EXMEM};
assign  instrMEMWB	=	{op_MEMWB, rs_MEMWB, rt_MEMWB, rd_MEMWB, 5'b11111, funct_MEMWB};
				
//parameters
// Instruction OP Codes
parameter REG = 6'd0;
parameter JUMP = 6'd2;
parameter BGTI = 6'd7;
parameter ADDI = 6'd8;
parameter SLTI = 6'd10;
parameter ANDI = 6'd12;
parameter ORI = 6'd13;
parameter XORI = 6'd14;
parameter SLLI = 6'd15;
parameter LW = 6'd35;
parameter SW = 6'd43;

// ALU Functions
parameter NOP = 6'd0;
parameter SLLV = 6'd4;
parameter JR = 6'd8;
parameter ADD = 6'd32;
parameter SUB = 6'd34;
parameter AND = 6'd36;
parameter OR = 6'd37;
parameter XOR = 6'd38;
parameter SLT = 6'd42;					
					
					
/*					
initial begin
	$display("\tIFID \tIDEX \tEXMEM \tMEMWB \talu0	\talu1	\ttime");
    $monitor("\t%b  \t%b  \t%b \t%b  \t%b	\t%b  \t%g",
              instrIFID,
					insrtIDEX,
						  instrEXMEM,
								instrMEMWB,
									  alu0,
											alu1,
												$time   );
   end					
*/					
   parameter delay = 1;					
					
					
	initial begin
	
	
	//reset parameters
	{op_IFID, rs_IFID, rt_IFID, rd_IFID, funct_IFID} = 27'd1;
	{op_IDEX, rs_IDEX, rt_IDEX, rd_IDEX, funct_IDEX} = 27'd1;
	{op_IFID, rs_EXMEM, rt_EXMEM, rd_EXMEM, funct_EXMEM} = 27'd1;
	{op_MEMWB, rs_MEMWB, rt_MEMWB, rd_MEMWB, funct_MEMWB} = 27'd1;
	
	aluEXMEM_Data = 32'd2;
	aluMEMWB_Data = 32'd4;
	EXMEM_Data2Mem = 32'd6;
	MEMWB_MemData = 32'd8;
	/*
	//BLOCK 1, op_IDEX_is_alui_rd = true
	#delay; 
	op_IDEX = ADDI;
		//Case 3:   		op_MEMWB_is_alui_wr || op_MEMWB == LW
		//result 3: 		alu0 = (rd_MEMWB == rs_IDEX);
		#delay; #delay;	
		op_MEMWB = ADDI;
		rd_MEMWB = 5'b10101; //true case
		rs_IDEX =  5'b10101;
		#delay; #delay;
		rs_IDEX = 5'b0; 	//false case
		#delay; #delay;

		op_MEMWB = LW;
		rd_MEMWB = 5'b10101; //true case
		rs_IDEX =  5'b10101;
		#delay; #delay;
		rs_IDEX = 5'b0; 	//false case
		#delay; #delay;
	
		//Case 1, 			op_EXMEM_is_alui_wr
		//result 1: 		alu0 = (rt_EXMEM == rs_IDEX);
		#delay; #delay;	
		op_EXMEM = ADDI;		
		rt_EXMEM = 5'b10101; //true case
		rs_IDEX =  5'b10101;
		#delay; #delay;
		rs_IDEX = 5'b0; 	//false case
		#delay; #delay; 
		#delay; #delay; #delay; #delay; 
		
		
		//Case 2, 			op_EXMEM == 0 && funct_EXMEM_is_alur
		//result 2: 		alu0 = (rd_EXMEM == rs_IDEX);
		#delay; #delay;	
		op_EXMEM = 6'b0;
		funct_EXMEM = ADD;
		rd_EXMEM = 5'b10101; //true case
		rs_IDEX =  5'b10101;
		#delay; #delay;
		rs_IDEX = 5'b0; 	//false case
		#delay; #delay;
		#delay; #delay; #delay; #delay; 
	*/
	
/*
	//BLOCK 2 op_IDEX == 0 && funct_IDEX_is_alur

	op_IDEX = 6'b0;
	funct_IDEX = ADD;
	
	rt_MEMWB = 5'b1;
	rd_MEMWB = 5'b1;
	
		//case 1
		op_EXMEM = ADDI;
		rt_EXMEM = 5'd15;
		rs_IDEX =  5'd15;
		rt_IDEX = 5'd15;
		//both alu0 and alu1 are on.
		#delay; #delay;
		rs_IDEX = 5'b0; //alu0 off;
		#delay; #delay;
		rt_IDEX = 5'b0; //alu1 off;
		#delay; #delay;
		#delay; #delay;
		
		op_MEMWB = 0;
		rt_EXMEM = 5'd15;
		rs_IDEX =  5'd15;
		rt_IDEX = 5'd15;
		//both alu0 and alu1 are on.
		#delay; #delay;
		rs_IDEX = 5'b0; //alu0 off;
		#delay; #delay;
		rt_IDEX = 5'b0; //alu1 off;
		#delay; #delay;
		#delay; #delay;
*/	

	//BLOCK 3 FORWARDING TO DATA MEMORY
	op_IDEX = SW;
	
	op_EXMEM = ADDI;
	rt_EXMEM = 5'd15;
	rt_IDEX  = 5'd15;
	rt_MEMWB = 5'd10;
		
/*		

	//BLOCK 6 FORWARDING TO JUMPS
	op_IFID = BGTI;
	op_EXMEM = ADDI;
	rt_EXMEM = 5'b10101;
	rt_IFID = 5'b10101;
	rs_IFID = 5'b10101;	//jmp0 and jmp1 true
	#delay; #delay;
	rs_IFID = 5'b0;
	#delay; #delay;
	rt_IFID = 5'b0;
	#delay; #delay;
	funct_EXMEM = ADD;
	#delay; #delay;
*/	
	
	//BLOCK 4 HAZARD CONTROL

			

			
			
			
			
			
			
			
	$finish;
	end
					
					
endmodule	















































				