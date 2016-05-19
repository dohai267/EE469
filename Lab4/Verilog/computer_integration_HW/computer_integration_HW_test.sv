/*
Author: Ian Gilman
Title: Computer Integration Hardware & Program
Summary: Instantiates integrated computer, programs it, and runs the 
   programmed instructions
*/

/* Module Dependencies
`include "../file_register/file_register.v"
`include "../sram/sram.v"
`include "../alu/alu.v"
`include "../instruction_memory/instruction_memory.v"
`include "../instruction_memory/decoder_7bit/decoder_7bit.v"
`include "../Program_Control/Program_Control.v"
`include "../control_signals/control_signals.v"
`include "../file_register/register_32bit/d_flipflop/d_flipflop.v"
`include "../file_register/mux_2to1/mux_2to1.v"
`include "../file_register/register_32bit/register_32bit.v"
`include "../file_register/decoder_5bit/decoder_5bit.v"
`include "../computer_integration/computer_integration.v"
*/

module computer_integration_HW_test(CLOCK_50, SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
// I/O
   input wire CLOCK_50;  // 50 MHz clock
   input wire [9:0] SW;  // switches
   input wire [3:0] KEY;  // keypad
   output wire [9:0] LEDR;  // LEDs
   output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;  // 7-Seg displays
// Internal
   // Timing
   wire sys_clk;  // system clock
   wire [32:0] clocks;  // divided clocks to choose the system clock from
   // Control
   wire comp_rst, comp_en, wr_instr_en;  // computer !reset, computer !enable, write instruction enable
   // Data
   wire [6:0] wr_instr_addr;  // address to write instruction
   wire [31:0] wr_instr;  // instruction to write to instruction memory
   // User Interface
   wire[2:0] clk_select;  // selects clocks to use
   wire clk_speed, next_state,  // select fast or slow clock, start next state for sm, 
        reset_sm;  // reset sm to default state
   
   
   // Define User Interface
   assign clk_select = SW[8:6];
   assign clk_speed = SW[9];
   assign next_state = KEY[0];
   assign reset_sm = KEY[3];
   // Inactive Outputs
   assign LEDR = 10'd0;
   assign HEX0 = 7'h7F;
   assign HEX1 = 7'h7F;
   assign HEX2 = 7'h7F;
   assign HEX3 = 7'h7F;
   assign HEX4 = 7'h7F;
   assign HEX5 = 7'h7F;
   
   // Define System Clock
   div_clock clock_divider(.orig_clk(CLOCK_50), .div_clks(clocks[32:1]));
   assign clocks[0] = CLOCK_50;
   assign sys_clk = clk_speed ? clocks[clk_select] : clocks[(clk_select + 18)];
   
   // Integrated Computer
   computer_integration Computer(
      .clk(sys_clk),
      .comp_rst(comp_rst),
      .comp_en(comp_en),
      .wr_instr_en(wr_instr_en),
      .wr_instr_addr(wr_instr_addr),
      .wr_instr(wr_instr)
   );

   // Computer State Machine
   computer_integration_HW_SM Computer_Control_SM(
      .clk(sys_clk),
      .comp_rst(comp_rst),
      .comp_en(comp_en),
      .wr_instr_en(wr_instr_en),
      .wr_instr_addr(wr_instr_addr),
      .wr_instr(wr_instr),
      .next_state(next_state),
      .reset_sm(reset_sm)
   );
   
endmodule






/*
Author: Ian Gilman
Title: Computer Integration HW Test State Machine
Summary: State machine for programming and running computer integration
*/

module computer_integration_HW_SM(
   clk,
   comp_rst,
   comp_en,
   wr_instr_en,
   wr_instr_addr,
   wr_instr,
   next_state,
   reset_sm
);
// I/O
   input clk, next_state, reset_sm;  // sm clock, PB indicating transition to next state, reset sm signal
   output reg comp_rst, comp_en, wr_instr_en;  // reset computer, enable computer, enable write instruction
   output reg [6:0] wr_instr_addr;  // address for writing instruction
   output reg [31:0] wr_instr;  // instruction to write
// Internal
   reg [6:0] instr_count;  // current write instruction count
   reg [1:0] comp_state;  // state that the sm is driving the computer in
   reg curr_state;  // used to detect transition to next state
   wire state_change;  // detects when sm should start changing state
   
   
   // Detect when comp SM receives a state change command
   assign state_change = !next_state && curr_state;
   
   // Initialize SM regs
   initial begin
      // Output regs
      comp_rst = 1'b0;
      comp_en = 1'b1;
      wr_instr_en = 1'b0;
      wr_instr_addr = 7'b0;
      wr_instr = 32'b0;
      // SM regs
      instr_count = 7'b0;
      comp_state = IDLE;
      curr_state = 1'b0;
   end
   
   // Computer State Machine Logic
   always @(posedge clk or negedge reset_sm) begin
            
      // Reset Computer SM
      if(!reset_sm) begin
         // Output regs
         comp_rst <= 1'b0;
         comp_en <= 1'b1;
         wr_instr_en <= 1'b0;
         wr_instr_addr <= 7'b0;
         wr_instr <= 32'b0;
         // SM regs
         instr_count = 7'b0;
         comp_state <= IDLE;
         curr_state <= 1'b0;
      end
      
      // Computer States Defined
      else begin   
         // sm state change command found
         curr_state <= next_state;
      
         // STATES START HERE
         case(comp_state)
         
            // Computer is Idling and nothing changes
            IDLE: begin
               comp_rst <= 1'b0;
               if(state_change) begin
                  comp_rst <= 1'b1;
                  comp_state <= WRITE_PROGRAM;
               end
            end
         
            // Program instructions are being written to the computer
            WRITE_PROGRAM: begin
               if(instr_count < N_INSTR) begin
                  wr_instr_en <= 1'b1;
                  wr_instr_addr <= instr_count;
                  wr_instr <= INSTR_TO_COMPUTER[instr_count];
                  instr_count <= instr_count + 7'b1;
               end
               else begin
                  wr_instr_en <= 1'b0;
                  comp_state <= RUN_PROGRAM;
               end
            end
            
            // Let computer Run through all of the instructions written to instruction memory
            RUN_PROGRAM: begin
               comp_en <= 1'b0;
            end
         
         endcase
         
      end
      
   end
   
   // Computer States
   parameter IDLE = 2'b00;
   parameter WRITE_PROGRAM = 2'b01;
   parameter RUN_PROGRAM = 2'b10;
   
   // Instructions to Write
   parameter N_INSTR = 27;
   parameter bit [31:0] INSTR_TO_COMPUTER [0:(N_INSTR-1)] = 
   '{                                              //           C Equivalent
      {ADDI,   zero,    t0,   16'd7},              // instr 0     int A = 7;
      {SW,     zero,    t0,   A    },              // instr 1
      {ADDI,   zero,    t0,   16'd5},              // instr 2     int B = 5;  
      {SW,     zero,    t0,   B    },              // instr 3
      {ADDI,   zero,    t0,   16'd2},              // instr 4     int C = 2;
      {SW,     zero,    t0,   C    },              // instr 5
      {ADDI,   zero,    t0,   16'd4},              // instr 6     int D = 4;
      {SW,     zero,    t0,   D    },              // instr 7
      {ADDI,   zero,    t0,   D    },              // instr 8     int* DPtr = &D;
      {SW,     zero,    t0,   DPtr },              // instr 9
      {LW,     zero,    t0,   A    },              // instr 10    if (A-B) > 3 {
      {LW,     zero,    t1,   B    },              // instr 11
      {REG,    t0,      t1,   t1,   SHAMT,   SUB}, // instr 12
      {ADDI,   zero,    t0,   16'd3},              // instr 13
      {BGT,    t0,      t1,   16'd6},              // instr 14
      {ADDI,   zero,    t0,   16'd6},              // instr 15    C = 6;
      {SW,     zero,    t0,   C    },              // instr 16
      {LW,     zero,    t0,   D    },              // instr 17    D = D << 2;}
      {SLLI,   t0,      t0,   16'd2},              // instr 18
      {SW,     zero,    t0,   D    },              // instr 19
      {JMP,    26'd27},                            // instr 20    else {
      {LW,     zero,    t0,   C    },              // instr 21    C = C << 5;
      {SLLI,   t0,      t0,   16'd5},              // instr 22
      {SW,     zero,    t0,   C    },              // instr 23
      {LW,     zero,    t0,   DPtr },              // instr 24    *DPtr = 7;}
      {ADDI,   zero,    t1,   16'd7},              // instr 25
      {SW,     t0,      t1,   16'd0}               // instr 26    
    };
    
   
   // Program with every operation
   // PLACEHOLDER

   // C-Program Variable Memory locations
   parameter A = 16'd0;
   parameter B = 16'd1;
   parameter C = 16'd2;
   parameter D = 16'd3;
   parameter DPtr = 16'd4;
   
   // Computer OP-CODES
   parameter REG = 6'd0;
   parameter JMP = 6'd2;
   parameter BGT = 6'd7;
   parameter ADDI = 6'd8;
   parameter SLTI = 6'd10;
   parameter ANDI = 6'd12;
   parameter ORI = 6'd13;
   parameter XORI = 6'd14;
   parameter SLLI = 6'd15;
   parameter LW = 6'd35;
   parameter SW = 6'd43;
   
   // Function Codes
   parameter NOP = 6'd0;
   parameter SLLV = 6'd4;
   parameter ADD = 6'd8;
   parameter SUB = 6'd34;
   parameter AND = 6'd36;
   parameter OR = 6'd37;
   parameter XOR = 6'd38;
   parameter SLT = 6'd42;
   
   // FR Register Common Names
   parameter zero = 5'd0;
   parameter t0 = 5'd8;
   parameter t1 = 5'd9;
   parameter t2 = 5'd10;
   parameter t3 = 5'd11;
   parameter t4 = 5'd12;
   parameter t5 = 5'd13;
   parameter t6 = 5'd14;
   parameter t7 = 5'd15;

   parameter SHAMT = 5'b11111;  // SHAMT filler for REG instructions
   
endmodule






/*
Author: Ian Gilman
Title: clock divider
Summary: create vector of divided clocks based on original clock
*/

module div_clock(orig_clk, div_clks);
   input wire orig_clk;
   output reg [31:0] div_clks;

   // increment vector of clocks for every orig_clk pulse
   always @(posedge orig_clk) begin
      div_clks = div_clks + 32'b1;
   end   
endmodule