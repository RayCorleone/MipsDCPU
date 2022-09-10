`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Usage    先写后读专用路径模块
// Vision   1.0
// Auther   Ray
//////////////////////////////////////////////////////////////////////////////////

module mux(
    input [4:0] rs,
    input [4:0] rt,
    input [31:0] rs_data,
    input [31:0] rt_data,

    input [31:0] npc_EXE,
    input [31:0] mul_EXE,
    input [31:0] alu_EXE,
    input [4:0] waddr_EXE,
    input write_EXE,
    input is_LW_EXE,
    input is_JAL_EXE,
    input is_MUL_EXE,

    input [31:0] npc_MEM,
    input [31:0] mul_MEM,
    input [31:0] alu_MEM,
    input [4:0] waddr_MEM,
    input write_MEM,
    input is_LW_MEM,
    input is_JAL_MEM,
    input is_MUL_MEM,

    output reg [31:0] rs_MUX = 32'b0,
    output reg [31:0] rt_MUX = 32'b0,
    output reg conf_LW = 1'b0
    );

    reg conf_LW_rs = 1'b0;
    reg conf_LW_rt = 1'b0;

    always @(*) begin
        if(conf_LW_rs || conf_LW_rt) begin
            conf_LW = 1'b1; end
        else begin
            conf_LW = 1'b0; end
    end

    always @(*) begin
        if(write_EXE && waddr_EXE == rs && rs != 5'b0) begin
            if(is_JAL_EXE) begin
                conf_LW_rs = 1'b0;  rs_MUX = npc_EXE;   end
            else if(is_MUL_EXE) begin
                conf_LW_rs = 1'b0;  rs_MUX = mul_EXE;   end
            else if(is_LW_EXE) begin
                conf_LW_rs = 1'b1;  rs_MUX = 32'b0;     end
            else begin
                conf_LW_rs = 1'b0;  rs_MUX = alu_EXE;   end
        end
        else begin
            if(write_MEM && waddr_MEM == rs && rs != 5'b0)begin
                if(is_JAL_MEM) begin
                    conf_LW_rs = 1'b0;  rs_MUX = npc_MEM;   end
                else if(is_MUL_MEM) begin
                    conf_LW_rs = 1'b0;  rs_MUX = mul_MEM;   end
                else if(is_LW_MEM) begin
                    conf_LW_rs = 1'b1;  rs_MUX = 32'b0;     end
                else begin
                    conf_LW_rs = 1'b0;  rs_MUX = alu_MEM;   end
            end
            else begin
                conf_LW_rs = 1'b0;  rs_MUX = rs_data;       end
        end
    end

    always @(*) begin
        if(write_EXE && waddr_EXE == rt && rt != 5'b0) begin
            if(is_JAL_EXE) begin
                conf_LW_rt = 1'b0;  rt_MUX = npc_EXE;   end
            else if(is_MUL_EXE) begin
                conf_LW_rt = 1'b0;  rt_MUX = mul_EXE;   end
            else if(is_LW_EXE) begin
                conf_LW_rt = 1'b1;  rt_MUX = 32'b0;     end
            else begin
                conf_LW_rt = 1'b0;  rt_MUX = alu_EXE;   end
        end
        else begin
            if(write_MEM && waddr_MEM == rt && rt != 5'b0)begin
                if(is_JAL_MEM) begin
                    conf_LW_rt = 1'b0;  rt_MUX = npc_MEM;   end
                else if(is_MUL_MEM) begin
                    conf_LW_rt = 1'b0;  rt_MUX = mul_MEM;   end
                else if(is_LW_MEM) begin
                    conf_LW_rt = 1'b1;  rt_MUX = 32'b0;     end
                else begin
                    conf_LW_rt = 1'b0;  rt_MUX = alu_MEM;   end
            end
            else begin
                conf_LW_rt = 1'b0;  rt_MUX = rt_data;       end
        end
    end
endmodule