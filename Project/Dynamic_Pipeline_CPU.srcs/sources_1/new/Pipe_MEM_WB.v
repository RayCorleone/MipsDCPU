`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Usage    MEM_WB Á÷Ë®Ïß¼Ä´æÆ÷
// Vision   1.0
// Auther   Ray 
//////////////////////////////////////////////////////////////////////////////////

module Pipe_MEM_WB(
    input clk,
    input rst,

    input write_MEM,
    input is_LW_MEM,
    input is_JAL_MEM,
    input is_MUL_MEM,
    input [4:0] waddr_MEM,
    input [31:0] alu_MEM,
    input [31:0] mul_MEM,
    input [31:0] npc_MEM,
    input [31:0] DM_rdata_MEM,

    output reg write_WB = 1'b0,
    output reg is_LW_WB = 1'b0,
    output reg is_JAL_WB = 1'b0,
    output reg is_MUL_WB = 1'b0,
    output reg [4:0] waddr_WB = 5'b0,
    output reg [31:0] alu_WB = 32'b0,
    output reg [31:0] mul_WB = 32'b0,
    output reg [31:0] npc_WB = 32'b0,
    output reg [31:0] DM_rdata_WB = 32'b0
    );

    always @(posedge rst or posedge clk) begin
        if(rst) begin
            write_WB <= 1'b0;
            alu_WB <= 32'b0;
            mul_WB <= 32'b0;
            DM_rdata_WB <= 32'b0;
            waddr_WB <= 5'b0;
            npc_WB <= 32'b0;
            is_LW_WB <= 32'b0;
            is_JAL_WB <= 32'b0;
            is_MUL_WB <= 32'b0;
        end 
        else begin
            write_WB <= write_MEM;
            alu_WB <= alu_MEM;
            mul_WB <= mul_MEM;
            DM_rdata_WB <= DM_rdata_MEM;
            waddr_WB <= waddr_MEM;
            npc_WB <= npc_MEM;
            is_LW_WB <= is_LW_MEM;
            is_JAL_WB <= is_JAL_MEM;
            is_MUL_WB <= is_MUL_MEM;
        end
    end
endmodule