`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Usage    EXE_MEM Á÷Ë®Ïß¼Ä´æÆ÷
// Vision   1.0
// Auther   Ray 
//////////////////////////////////////////////////////////////////////////////////

module Pipe_EXE_MEM(
    input clk,
    input rst,

    input DM_w_EXE,
    input write_EXE,
    input is_LW_EXE,
    input is_JAL_EXE,
    input is_MUL_EXE,
    input [4:0] waddr_EXE,
    input [31:0] alu_EXE,
    input [31:0] mul_EXE,
    input [31:0] npc_EXE,
    input [31:0] DM_wdata_EXE,

    output reg DM_w_MEM = 1'b0,
    output reg write_MEM = 1'b0,
    output reg is_LW_MEM = 1'b0,
    output reg is_JAL_MEM = 1'b0,
    output reg is_MUL_MEM = 1'b0,
    output reg [4:0] waddr_MEM = 5'b0,
    output reg [31:0] alu_MEM = 32'b0,
    output reg [31:0] mul_MEM = 32'b0,
    output reg [31:0] npc_MEM = 32'b0,
    output reg [31:0] DM_wdata_MEM = 32'b0
    );

    always @(posedge rst or posedge clk) begin
        if(rst) begin
            write_MEM <= 1'b0;
            alu_MEM <= 32'b0;
            waddr_MEM <= 5'b0;
            DM_wdata_MEM <= 32'b0;
            DM_w_MEM <= 1'b0;
            npc_MEM <= 32'b0;
            is_LW_MEM <= 32'b0;
            is_JAL_MEM <= 32'b0;
            is_MUL_MEM <= 32'b0;
            mul_MEM <= 32'b0;
        end 
        else begin
            write_MEM <= write_EXE;
            alu_MEM <= alu_EXE;
            mul_MEM <= mul_EXE;
            waddr_MEM <= waddr_EXE;
            DM_wdata_MEM <= DM_wdata_EXE;
            DM_w_MEM <= DM_w_EXE;
            npc_MEM <= npc_EXE;
            is_LW_MEM <= is_LW_EXE;
            is_JAL_MEM <= is_JAL_EXE;
            is_MUL_MEM <= is_MUL_EXE;
        end
    end
endmodule