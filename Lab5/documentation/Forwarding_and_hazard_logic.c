// Pseduo C-code logical descriptions of the hazard and data forwarding controls


/*/// DEFINITION OF TERMS  /////
-------------------------------------------------------------------------------------
||  TERM           ||  Reference
-------------------------------------------------------------------------------------
||  if/id          ||  Refers to the data buffer between the Instruction Fetch and the 
||                 ||  Instruction Decode pipelining stages
-------------------------------------------------------------------------------------
||  id/ex          ||  Refers to the data buffer between the Instruction Decode and the 
||                 ||  Execution pipelining stages
-------------------------------------------------------------------------------------
||  ex/mem         ||  Refers to the data buffer between the Execution and the 
||                 ||  Memory pipelinging stages
--------------------------------------------------------------------------------------
||  mem/wb         ||  Refers to the data bffer between the Memory and the
||                 ||  Write Back pipelining stages
--------------------------------------------------------------------------------------
||  op             ||  The op-code part of an instruction: instr[31:26] (6-bits)
---------------------------------------------------------------------------------------
||  rs             ||  The 1st FR register address in an instruction: instr[25:21] (5-bits)
||                 ||  this indicates a register that is being read
--------------------------------------------------------------------------------------
||  rt             ||  The 2nd FR register address in an instruction: instr[20:16] (5-bits)
||                 ||  this indicates the register that is written to for immediate instructions
||                 ||  or a register that is read for register instructions
---------------------------------------------------------------------------------------
||  rd             ||  The 2nd FR register address in an instruction (register only): instr[15:11] (5-bits)
||                 ||  this indicates the register that is written to for register instructions
||                 ||  it is invalid for immediate instructions
---------------------------------------------------------------------------------------
||  funct          ||  The part of the instruction that indicates the ALU function to perform:
||                 ||      instr[5:0] (6-bit)
---------------------------------------------------------------------------------------              
||  alui_wr        ||  Op-codes for instructions that write data to FR from the ALU:
||                 ||      ADDI, SLTI, ANDI, ORI, XORI, SLLI
-------------------------------------------------------------------------------------
||  alui_rd         ||  Op-codes for instructions that read data to ALU from the FR:
||                 ||      ADDI, SLTI, ANDI, ORI, XORI, SLLI, SW, LW
-------------------------------------------------------------------------------------
||  alur           ||  ALU funct code for register instructions (Op-code = 0) that read
||                 ||  from the FR to the ALU and also write from the ALU to the FR:
||	               ||      ADD, SUB, SLT, AND, OR, XOR, SLLV
-------------------------------------------------------------------------------------
*/


///// DATA-FORWARDING /////
// FORWARDING TO ALU
/*
alu mux logic and data (alu_mux == true  means alu_D is forwarded):
signals:
   alu_mux0, alu_mux1
   alu_D0,   alu_D1
*/
// alu mux logic
if(id/ex_op == alui_rd) {
   // mux logic
   // mux 0
   if(ex/mem_op == alui_wr)
      alu_mux0 = (ex/mem_rt == id/ex_rs);
   else if(ex/mem_op == 0 && ex/mem_func == alur)
      alu_mux0 = (ex/mem_rd == id/ex_rs);
   else if(mem/wb_op == alui_wr || mem/wb_op == lw)
      alu_mux0 = (mem/wb_rt == id/ex_rs);
   else
      alu_mux0 = (mem/wb_rd == id/ex_rs);
   // mux 1
   alu_mux1 = 0;
   // data logic
   // mux 0 data
   if((ex/mem_op == alui_wr) || (ex/mem_op == 0 && ex/mem_func == alur))
      alu_D0 = ex/mem_ALU_D;
   else
      alu_D0 = X;
   // mux 1 data
   alu_D1 = X;
}
else if(id/ex_op == 0 && id/ex_func == alur) {
   if(ex/mem_op == alui_wr) {
      // mux logic
      if(mem/wb_op == alui_wr || mem/wb_op == lw) {
         alu_mux0 = (ex/mem_rt == id/ex_rs) || (mem/wb_rt == id/ex_rs);
         alu_mux1 = (ex/mem_rt == id/ex_rt) || (mem/wb_rt == id/ex_rt);
      }
      else if(mem/wb_op == 0 && mem/wb_func == alur) {
         alu_mux0 = (ex/mem_rt == id/ex_rs) || (mem/wb_rd == id/ex_rs);
         alu_mux1 = (ex/mem_rt == id/ex_rt) || (mem/wb_rd == id/ex_rt);
      }
      else {
         alu_mux0 = (ex/mem_rt == id/ex_rs);
         alu_mux1 = (ex/mem_rt == id/ex_rt);
      }
      // data logic
      // mux 0 data
      if(ex/mem_rt == id/ex_rs)
         alu_D0 = ex/mem_ALU_D;
      else
         alu_D0 = mem/wb_ALU_D;
      // mux 1 data
      if(ex/mem_rt == id/ex_rt)
         alu_D1 = ex/mem_ALU_D;
      else if
         alu_D1 = mem/wb_ALU_D;
   }
   else if(ex/mem_op == 0 && ex/mem_func == alur) {
      // mux logic
      if(mem/wb_op == alui_wr || mem/wb_op == lw) {
         alu_mux0 = (ex/mem_rd == id/ex_rs) || (mem/wb_rt == id/ex_rs);
         alu_mux1 = (ex/mem_rd == id/ex_rt) || (mem/wb_rt == id/ex_rt);
      }
      else if(mem/wb_op == 0 && mem/wb_func == alur) {
         alu_mux0 = (ex/mem_rd == id/ex_rs) || (mem/wb_rd == id/ex_rs);
         alu_mux1 = (ex/mem_rd == id/ex_rt) || (mem/wb_rd == id/ex_rt);
      }
      else {
         alu_mux0 = (ex/mem_rd == id/ex_rs);
         alu_mux1 = (ex/mem_rd == id/ex_rt);
      }
      // data logic
      // mux 0 data
      if(ex/mem_rd == id/ex_rs)
         alu_D0 = ex/mem_ALU_D;
      else
         alu_D0 = mem/wb_ALU_D;
      // mux 1 data
      if(ex/mem_rd == id/ex_rt)
         alu_D1 = ex/mem_ALU_D;
      else
         alu_D1 = mem/wb_ALU_D;
   }
}


// FORWARDING TO DATA MEMORY
/*
mem mux logic and data (memD_mux == true  means memD is forwarded):
signals:
   ex_memD_mux, mem_memD_mux
   ex_memD,     mem_memD
*/
// ex mem mux
if(id/ex_op == sw) {
   if((ex/mem_op == alui_wr) && (ex/mem_rt == id/ex_rt)) {
      ex_memD_mux = 1;
   else if((ex/mem_op == 0 && ex/mem_func == alur) && (ex/mem_rd == id/ex_rt))
      ex_memD_mux = 1;
   else if((mem/wb_op == alui_wr || mem/wb_op == lw) && mem/wb_rt == id/ex_rt)
      ex_memD_mux = 1;
   else if (mem/wb_op == 0 && mem/wb_func == alur)
      ex_memD_mux = mem/wb_rd == id/ex_rt;
   else
      ex_memD_mux = 0;
}
// ex mem mux data
if(id/ex_op == sw) {
   if((ex/mem_op == alui_wr) && (ex/mem_rt == id/ex_rt))
      ex_memD = ex/mem_ALU_D;
   else if((ex/mem_op == 0 && ex/mem_func == alur) && (ex/mem_rd == id/ex_rt))
      ex_memD = ex/mem_ALU_D;
   else if((mem/wb_op == alui_wr) && (mem/wb_rt == id/ex_rt))
      ex_memD = mem/wb_ALU_D;
   else if((mem/wb_op == 0 && mem/wb_func = alur) && (mem/wb_rd == id/ex_rt)) 
      ex_memD = mem/wb_ALU_D;
   else:
      ex_memD = mem/wb_MEM_D;
}
// mem mem mux and data
mem_memD = mem/wb_MEM_D;
if(ex/mem_op == sw && mem/wb_op == lw)
   mem_memD_mux = mem/wb_rt == ex/mem_rt;
else
   mem_memD_mux = 0;


// FORWARDING TO JUMPS
/*
jmp mux logic and data (jmp_mux == true  means jmpD is forwarded)
signals:
   jmp0_mux,   jmpD0
   jmp1_mux,   jmpD1
*/
// jmp mux
if((if/id_op == 0 && if/id_func == jr) || if/id == bgt) {
   if(ex/mem_op == alui_wr) {
      jmp0_mux = ex/mem_rt == if/id_rs;
      jmp1_mux = ex/mem_rt == if/id_rt;
   }
   else if(ex/mem_op == 0 && ex/mem_func == alur) {
      jmp0_mux = ex/mem_rd == if/id_rs;
      jmp1_mux = ex/mem_rd == if/id_rt;
   }
   else{
      jmp0 = 0;
      jmp1 = 0;
   }
}
else{
   jmp0 = 0;
   jmp1 = 0;
}

// jmp mux data
if((if/id_op == 0 && if/id_func == jr) || if/id == bgt) {
   if(ex/mem_op == alui_wr || (ex/mem_op == 0 && ex/mem_func == alur)) {
      jmpD0 = ex/mem_ALU_D;
      jmpD1 = ex/mem_ALU_D;
   }
}


///// HAZARD CONTROL /////
/*
signals:
   if_id_stall
   id_ex_stall
   flush
   guess_brnch (currently not implemented)
*/
// stall
if(ex/mem_op == lw) {  // stall for forwarding from memory to alu
   if(id/ex_op == alui_rd)
      id_ex_stall = ex/mem_rt == id/ex_rs;
   if(id/ex_op == 0 && id/ex_func == alur)
      id_ex_stall = ex/mem_rt == id/ex_rs || ex/mem_rt == id/ex_rt;
}
else if(if/id_op == 0 && if/id_func == jr)  {  // stall for data from alu / memory to jr
   if(id/ex_op == alui_wr || id/ex_op == lw)
      if_id_stall = id/ex_rt == if/id_rs;
   else if(id/ex_op == 0 && id/ex_func == alur)
      if_id_stall = id/ex_rd == if/id_rs;
   else if(ex/mem_op == lw)
      stall = ex/mem_rt == if/id_rs;
}
else if(if/id_op == bgt) {  // stall for data from alu / memory to bgt
   if(id/ex_op == alui_wr || id/ex_op == lw)
      if_id_stall = id/ex_rt == if/id_rs || id/ex_rt == if/id_rt;
   else if(id/ex_op == 0 && id/ex_func == alur)
      if_id_stall = id/ex_rt == (
                           id/ex_rt == if/id_rs || id/ex_rt == if/id_rt || 
                           id/ex_rs == if/id_rs || id/ex_rs == if/id_rt 
                          );
   else if(ex/mem_op == lw)
      if_id_stall = ex/mem_rt == if/id_rs || ex/mem_rt == if/id_rt;
}

// calc_branch
flush = (if/id_op == 0 && if/id_func == jr) || if/id_op == bgt || if/id_op == jmp)
