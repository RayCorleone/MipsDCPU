`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Usage    下板所需模块汇总
// Vision   1.0
// Auther   Ray 
//////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
// (0) 下版模块：选择输出pc,inst,i,a[i],b[i],c[i],d[i]
module pcpu_onboard(
    input clk_in,
    input reset,
    input stop,
    input [5:0] choose,
    output [7:0] o_seg,
    output [7:0] o_sel
    );
    wire [31:0] i_data;
    wire [31:0] inst,pc,reg6,reg7,reg8,reg9,reg10;
	wire [31:0] reg10_real;
    wire clk_cpu;
    wire clk_seg;
//    reg [31:0] i_data=32'h9fd0b7ea;
    /////////////////////////////////////////////////////////////////////
    // 选择显示 inst,pc,drop_cnt,egg_cnt,last_result
    assign reg10_real = ((inst != 32'b0) ? reg10 : 32'h9fd0b7ea);
    assign i_data = (choose[5]) ? inst : (
                    (choose[4]) ? pc :(
                    (choose[3]) ? reg7 :(
                    (choose[2]) ? reg8 :(
                    (choose[1]) ? reg9 :(
                    (choose[0]) ? reg10_real : reg6)))));
    
    divider #(1000000) div_cpu(clk_in,reset,clk_cpu);
    divider #(4) div_seg(clk_in,reset,clk_seg);
    seg7x16(clk_seg,reset,i_data,o_seg,o_sel);
    
    /////////////////////////////////////////////////////////////////////
    // pcpu_onboard 顶层部分
   	wire [31:0] a;
	wire clk_real;
	assign a = pc - 32'h00400000;
    assign clk_real = (inst != 32'b0) ? clk_cpu : 1'b0;

	imem imem(a[12:2], inst);	
   	pcpu_board sccpu(clk_real,stop,reset,inst,pc,reg6,reg7,reg8,reg9,reg10);
endmodule

/////////////////////////////////////////////////////////
// (1) regfile_board 模块
module regfile_board (
    input clk,
    input rst,
    input write,
    input [4:0] rna,
    input [4:0] rnb,
    input [4:0] waddr,
    input [31:0] idata,
    output [31:0] odata1,
    output [31:0] odata2,
	output [31:0] reg6,reg7,reg8,reg9,reg10
    );
    
    integer i;
    reg [31:0] array_reg[31:0];
     
    //从寄存器读取数据
    assign reg6 = array_reg[6];
    assign reg7 = array_reg[7];
    assign reg8 = array_reg[8];
    assign reg9 = array_reg[9];
    assign reg10 = array_reg[10];
    assign odata1 = (rna)?array_reg[rna]:0;
    assign odata2 = (rnb)?array_reg[rnb]:0;

    //将数据写入寄存器
    always@(negedge clk or posedge rst) begin
        if(rst==1) begin
            for(i=0;i<32;i=i+1) begin
                array_reg[i]<=0; end end
        else if(waddr != 0 && write) begin
            array_reg[waddr]<=idata; end
    end
endmodule

/////////////////////////////////////////////////////////
// (2) mul_board 模块
module mul_board(    //有符号乘法器
    input rst,    //复位信号，高电平有效
    input [31:0] a, //输入数 a(被乘数)
    input [31:0] b, //输入数 b（乘数）
    output [63:0] z //乘积输出 z
    );
    
    reg [2:0] state;
    reg [63:0] stored00=0, stored01=0, stored02=0, stored03=0;
    reg [63:0] stored04=0, stored05=0, stored06=0, stored07=0;
    reg [63:0] stored08=0, stored09=0, stored10=0, stored11=0;
    reg [63:0] stored12=0, stored13=0, stored14=0, stored15=0;
    reg [63:0] stored16=0, stored17=0, stored18=0, stored19=0;
    reg [63:0] stored20=0, stored21=0, stored22=0, stored23=0;
    reg [63:0] stored24=0, stored25=0, stored26=0, stored27=0;
    reg [63:0] stored28=0, stored29=0, stored30=0, stored31=0;
    reg [63:0] add00_01, add02_03, add04_05, add06_07;
    reg [63:0] add08_09, add10_11, add12_13, add14_15;
    reg [63:0] add16_17, add18_19, add20_21, add22_23;
    reg [63:0] add24_25, add26_27, add28_29, add30_31;
    reg [63:0] add00_03, add04_07, add08_11, add12_15;
    reg [63:0] add16_19, add20_23, add24_27, add28_31;
    reg [63:0] add00_07, add08_15, add16_23, add24_31;
    reg [63:0] add00_15, add16_31;
    reg [63:0] temp;
    
    reg a_sign=0;       // a的符号位
    reg b_sign=0;       // b的符号位
    reg z_sign=0;       // z的符号位
    reg [31:0] a_temp=0;// clk时的a
    reg [31:0] b_temp=0;// clk时的b
    wire [31:0] a_abs;  // a的绝对值
    wire [31:0] b_abs;  // b的绝对值
    reg flag=0;
    
    assign a_abs = a_sign ? (~a_temp+1) : a_temp;
    assign b_abs = b_sign ? (~b_temp+1) : b_temp;
    assign z = z_sign ? (~temp+1):temp;

    always @(*) begin
        if(rst) begin
            a_sign <= 0; b_sign <= 0; z_sign <= 0; a_temp <= 0; b_temp <= 0;
            temp <= 0; state <= 0;
            stored00 <= 0; stored01 <= 0; stored02 <= 0; stored03 <= 0;
            stored04 <= 0; stored05 <= 0; stored06 <= 0; stored07 <= 0;
            stored08 <= 0; stored09 <= 0; stored10 <= 0; stored11 <= 0;
            stored12 <= 0; stored13 <= 0; stored14 <= 0; stored15 <= 0;
            stored16 <= 0; stored17 <= 0; stored18 <= 0; stored19 <= 0;
            stored20 <= 0; stored21 <= 0; stored22 <= 0; stored23 <= 0;
            stored24 <= 0; stored25 <= 0; stored26 <= 0; stored27 <= 0;
            stored28 <= 0; stored29 <= 0; stored30 <= 0; stored31 <= 0;
            
            add00_01 <= 0; add02_03 <= 0; add04_05 <= 0; add06_07 <= 0;
            add08_09 <= 0; add10_11 <= 0; add12_13 <= 0; add14_15 <= 0;
            add16_17 <= 0; add18_19 <= 0; add20_21 <= 0; add22_23 <= 0;
            add24_25 <= 0; add26_27 <= 0; add28_29 <= 0; add30_31 <= 0;
            add00_03 <= 0; add04_07 <= 0; add08_11 <= 0; add12_15 <= 0;
            add16_19 <= 0; add20_23 <= 0; add24_27 <= 0; add28_31 <= 0;
            add00_07 <= 0; add08_15 <= 0; add16_23 <= 0; add24_31 <= 0;
            add00_15 <= 0; add16_31 <= 0;
            end
        else begin
            case(state)
            3'b000: begin
                a_sign <= a[31];    b_sign <= b[31];
                a_temp <= a;        b_temp <= b;
                state <= 1; end
            3'b001: begin
                stored00 <= b_abs[0]? {32'b0, a_abs} :64'b0;            stored01 <= b_abs[1]? {31'b0, a_abs, 1'b0} :64'b0;
                stored02 <= b_abs[2]? {30'b0, a_abs, 2'b0} :64'b0;      stored03 <= b_abs[3]? {29'b0, a_abs, 3'b0} :64'b0;
                stored04 <= b_abs[4]? {28'b0, a_abs, 4'b0} :64'b0;      stored05 <= b_abs[5]? {27'b0, a_abs, 5'b0} :64'b0;
                stored06 <= b_abs[6]? {26'b0, a_abs, 6'b0} :64'b0;      stored07 <= b_abs[7]? {25'b0, a_abs, 7'b0} :64'b0;
                stored08 <= b_abs[8]? {24'b0, a_abs, 8'b0} :64'b0;      stored09 <= b_abs[9]? {23'b0, a_abs, 9'b0} :64'b0;
                stored10 <= b_abs[10]? {22'b0, a_abs, 10'b0} :64'b0;    stored11 <= b_abs[11]? {21'b0, a_abs, 11'b0} :64'b0;
                stored12 <= b_abs[12]? {20'b0, a_abs, 12'b0} :64'b0;    stored13 <= b_abs[13]? {19'b0, a_abs, 13'b0} :64'b0;
                stored14 <= b_abs[14]? {18'b0, a_abs, 14'b0} :64'b0;    stored15 <= b_abs[15]? {17'b0, a_abs, 15'b0} :64'b0;
                stored16 <= b_abs[16]? {16'b0, a_abs, 16'b0} :64'b0;    stored17 <= b_abs[17]? {15'b0, a_abs, 17'b0} :64'b0;
                stored18 <= b_abs[18]? {14'b0, a_abs, 18'b0} :64'b0;    stored19 <= b_abs[19]? {13'b0, a_abs, 19'b0} :64'b0;
                stored20 <= b_abs[20]? {12'b0, a_abs, 20'b0} :64'b0;    stored21 <= b_abs[21]? {11'b0, a_abs, 21'b0} :64'b0;
                stored22 <= b_abs[22]? {10'b0, a_abs, 22'b0} :64'b0;    stored23 <= b_abs[23]? {9'b0, a_abs, 23'b0} :64'b0;
                stored24 <= b_abs[24]? {8'b0, a_abs, 24'b0} :64'b0;     stored25 <= b_abs[25]? {7'b0, a_abs, 25'b0} :64'b0;
                stored26 <= b_abs[26]? {6'b0, a_abs, 26'b0} :64'b0;     stored27 <= b_abs[27]? {5'b0, a_abs, 27'b0} :64'b0;
                stored28 <= b_abs[28]? {4'b0, a_abs, 28'b0} :64'b0;     stored29 <= b_abs[29]? {3'b0, a_abs, 29'b0} :64'b0;
                stored30 <= b_abs[30]? {2'b0, a_abs, 30'b0} :64'b0;     stored31 <= b_abs[31]? {1'b0, a_abs, 31'b0} :64'b0;
                state <= 2; end
            3'b010: begin
                add00_01 <= stored00+stored01;   add02_03 <= stored02+stored03;
                add04_05 <= stored04+stored05;   add06_07 <= stored06+stored07;
                add08_09 <= stored08+stored09;   add10_11 <= stored10+stored11;
                add12_13 <= stored12+stored13;   add14_15 <= stored14+stored15;
                add16_17 <= stored16+stored17;   add18_19 <= stored18+stored19;
                add20_21 <= stored20+stored21;   add22_23 <= stored22+stored23;
                add24_25 <= stored24+stored25;   add26_27 <= stored26+stored27;
                add28_29 <= stored28+stored29;   add30_31 <= stored30+stored31;
                state <= 3; end
            3'b011: begin
                add00_03 <= add00_01+add02_03;   add04_07 <= add04_05+add06_07;
                add08_11 <= add08_09+add10_11;   add12_15 <= add12_13+add14_15;
                add16_19 <= add16_17+add18_19;   add20_23 <= add20_21+add22_23;
                add24_27 <= add24_25+add26_27;   add28_31 <= add28_29+add30_31;
                state <= 4; end
            3'b100: begin
                add00_07 <= add00_03+add04_07;   add08_15 <= add08_11+add12_15;
                add16_23 <= add16_19+add20_23;   add24_31 <= add24_27+add28_31;
                state <= 5; end
            3'b101: begin
                add00_15 <= add00_07+add08_15;   add16_31 <= add16_23+add24_31;
                state <= 6; end
            3'b110: begin
                temp <= add00_15+add16_31;
                z_sign <= a_sign + b_sign;
                state <= 0; end
            endcase
        end
    end
endmodule

/////////////////////////////////////////////////////////
// (3) pcpu_board 模块
module pcpu_board(
    input clk_in,
    input ena,
    input rst,
    input [31:0] inst,
    output [31:0] pc,
    output [31:0] reg6,reg7,reg8,reg9,reg10
    );
    
    // 中断检测
    wire clk;
    assign clk = (ena) ? clk :clk_in;

//#########################################################################
//# IF 部分
//#########################################################################
    wire jump;          // 跳转信号
    wire stall;         // 延迟信号
    wire [31:0] npc_IF; // 始终是npc=pc+4
    wire [31:0] pc_ID;  // ID段返回的pc值
    wire [31:0] pc_IF;  // IF段流出的pc
    wire [31:0] inst_IF;// IF段流出的inst
    assign npc_IF   = pc + 32'd4;
    assign pc_IF    = (stall) ? pc : (jump) ? pc_ID : npc_IF;
    assign inst_IF  = (stall) ? 32'b0 : inst;
    PC PC(clk,rst,pc_IF,pc);
    
//#########################################################################
//# Pipe_IF_ID 流水线寄存器
//#########################################################################
    wire [31:0] inst_ID;
    wire [31:0] npc_ID;

    Pipe_IF_ID Pipe_IF_ID(
        .clk(clk),
        .rst(rst),
        .npc_IF(npc_IF),
        .inst_IF(inst_IF),
        .npc_ID(npc_ID),
        .inst_ID(inst_ID)
    );
    
//#########################################################################
//# ID 部分
//#########################################################################
 //-inst_ID指令解码
    wire [5:0] op,func;
	wire [4:0] rs,rt,rd,sa;
	wire [15:0] imm16;
	wire [25:0] index;
    wire [31:0] sa32_ID;       // sa 拓展
    wire [31:0] uimm32_ID;     // imme(offset) 无符号拓展
    wire [31:0] simm32_ID;     // imme(offset) 有符号拓展
    wire [31:0] offset32;   // offset << 2 拓展
	assign func     = inst_ID[5:0];
	assign sa       = inst_ID[10:6];
	assign imm16    = inst_ID[15:0];
	assign index    = inst_ID[25:0];
    assign op       = inst_ID[31:26];
    assign rs       = inst_ID[25:21];
	assign rt       = inst_ID[20:16];
	assign rd       = inst_ID[15:11];
    assign sa32_ID     = {27'b0, sa};
    assign uimm32_ID   = {16'b0, imm16};
    assign simm32_ID   = {{16{imm16[15]}}, imm16};
    assign offset32 = {{14{imm16[15]}}, imm16, 2'b0};

 //-pc_ID选择
    wire [31:0] rs_data;    // 寄存器rs中的数据
    wire [31:0] rt_data;    // 寄存器rt中的数据
    wire [1:0] mux_pc;      // pc_ID 选择信号
    wire [31:0] pc_add;     // beq bne bgez: pc + offset32
    wire [31:0] pc_jjal;    // j jal: pc[31:28]和index
    wire [31:0] pc_rs;      // jr: reg中rs位置存储的数据
    assign pc_rs  = rs_data;
    assign pc_add  = pc + offset32;
    assign pc_jjal  = {npc_IF[31:28], index, 2'b0};
    assign pc_ID = (mux_pc[1]) ? pc_add : (mux_pc[0]) ? pc_rs : pc_jjal;

 //-ID段先写后读专用路径
    wire write_EXE;         // EXE段写信号
    wire write_MEM;         // MEM段写信号
    wire [4:0] waddr_EXE;   // EXE段写地址
    wire [4:0] waddr_MEM;   // MEM段写地址
    wire is_LW_EXE;
    wire is_JAL_EXE;
    wire is_MUL_EXE;
    wire is_LW_MEM;
    wire is_JAL_MEM;
    wire is_MUL_MEM;
    wire [31:0] alu_EXE;
    wire [31:0] mul_EXE;
    wire [31:0] npc_EXE;
    wire [31:0] alu_MEM;
    wire [31:0] mul_MEM;
    wire [31:0] npc_MEM;
    wire conf_LW;           // LW冲突信号
    wire [31:0] rs_MUX;
    wire [31:0] rt_MUX;

    mux mux(
        .rs(rs),
        .rt(rt),
        .rs_data(rs_data),
        .rt_data(rt_data),
    
        .npc_EXE(npc_EXE),
        .mul_EXE(mul_EXE),
        .alu_EXE(alu_EXE),
        .waddr_EXE(waddr_EXE),
        .write_EXE(write_EXE),
        .is_LW_EXE(is_LW_EXE),
        .is_JAL_EXE(is_JAL_EXE),
        .is_MUL_EXE(is_MUL_EXE),
    
        .npc_MEM(npc_MEM),
        .mul_MEM(mul_MEM),
        .alu_MEM(alu_MEM),
        .waddr_MEM(waddr_MEM),
        .write_MEM(write_MEM),
        .is_LW_MEM(is_LW_MEM),
        .is_JAL_MEM(is_JAL_MEM),
        .is_MUL_MEM(is_MUL_MEM),
    
        .rs_MUX(rs_MUX),
        .rt_MUX(rt_MUX),
        .conf_LW(conf_LW)
    );

 //-控制信号产生
    wire DM_w_ID;           // ID段DMEM写信号
    wire write_ID;          // ID段写信号
    wire is_LW_ID;
    wire is_JAL_ID;
    wire is_MUL_ID;
    wire [3:0] aluc_ID;     // ID段aluc
    wire [4:0] waddr_ID;    // ID段写地址
    wire mux_alua_ID;           // ID段alua来源选择信号
    wire [1:0] mux_alub_ID;     // ID段alub来源选择信号
    wire [1:0] mux_waddr_ID;    // ID段写地址选择信号
    wire [1:0] mux_wdata_ID;    // ID段写数据选择信号
    assign waddr_ID = (mux_waddr_ID[1]) ? 5'd31 : (mux_waddr_ID[0]) ? rd : rt;
    control control(
        .op(op),
        .func(func),
        .rs_data(rs_MUX),
        .rt_data(rt_MUX),
        .jump(jump),
        .DM_w_ID(DM_w_ID), 
        .write_ID(write_ID), 
        .aluc_ID(aluc_ID), 
        .mux_pc(mux_pc), 
        .mux_alua_ID(mux_alua_ID), 
        .mux_alub_ID(mux_alub_ID), 
        .mux_waddr_ID(mux_waddr_ID),
        .is_LW_ID(is_LW_ID), 
        .is_JAL_ID(is_JAL_ID), 
        .is_MUL_ID(is_MUL_ID) 
    );

 //-冲突处理
    conflict conflict(
        .inst(inst),
        .is_LW_ID(is_LW_ID),
        .is_LW_EXE(is_LW_EXE),
        .is_LW_MEM(is_LW_MEM),
        .write_ID(write_ID),
        .write_EXE(write_EXE),
        .write_MEM(write_MEM),
        .waddr_ID(waddr_ID),
        .waddr_EXE(waddr_EXE),
        .waddr_MEM(waddr_MEM),
        .stall(stall)
    );

//#########################################################################
//# Pipe_ID_EXE 流水线寄存器
//#########################################################################
    wire [31:0] sa32_EXE;
    wire [31:0] simm32_EXE;
    wire [31:0] uimm32_EXE;
    wire [31:0] rs_data_EXE;
    wire [31:0] rt_data_EXE;
    wire [3:0] aluc_EXE;
    wire [31:0] DM_wdata_EXE;
    wire DM_w_EXE;
    wire mux_alua_EXE;
    wire [1:0] mux_alub_EXE;
    wire [1:0] mux_wdata_EXE;
    wire DM_w_ID_real;
    assign DM_w_ID_real = DM_w_ID && (~conf_LW);

    Pipe_ID_EXE Pipe_ID_EXE(
        .clk(clk),
        .rst(rst),

        .DM_w_ID(DM_w_ID_real),
        .write_ID(write_ID),
        .is_LW_ID(is_LW_ID), 
        .is_JAL_ID(is_JAL_ID), 
        .is_MUL_ID(is_MUL_ID),
        .mux_alua_ID(mux_alua_ID),
        .mux_alub_ID(mux_alub_ID),
        .aluc_ID(aluc_ID),
        .npc_ID(npc_ID),
        .waddr_ID(waddr_ID),
        .sa32_ID(sa32_ID),
        .simm32_ID(simm32_ID),
        .uimm32_ID(uimm32_ID),
        .rs_data_ID(rs_MUX),
        .rt_data_ID(rt_MUX),
        .DM_wdata_ID(rt_MUX),

        .DM_w_EXE(DM_w_EXE),
        .write_EXE(write_EXE),
        .is_LW_EXE(is_LW_EXE), 
        .is_JAL_EXE(is_JAL_EXE), 
        .is_MUL_EXE(is_MUL_EXE),
        .mux_alua_EXE(mux_alua_EXE),
        .mux_alub_EXE(mux_alub_EXE),
        .aluc_EXE(aluc_EXE),
        .npc_EXE(npc_EXE),
        .waddr_EXE(waddr_EXE),
        .sa32_EXE(sa32_EXE),
        .simm32_EXE(simm32_EXE),
        .uimm32_EXE(uimm32_EXE),
        .rs_data_EXE(rs_data_EXE),
        .rt_data_EXE(rt_data_EXE),
        .DM_wdata_EXE(DM_wdata_EXE)
    );
    
//#########################################################################
//# EXE 部分
//#########################################################################
    wire [31:0] alua;
    wire [31:0] alub;
    assign alua = mux_alua_EXE ? sa32_EXE : rs_data_EXE;
    assign alub = (mux_alub_EXE[1]) ? rt_data_EXE : (mux_alub_EXE[0]) ? uimm32_EXE : simm32_EXE;
    alu alu(alua,alub,aluc_EXE,alu_EXE);

    wire [63:0] mul_out;
    assign mul_out = alua * alub;
    //mul_board mul_board(rst,alua,alub,mul_out);
    assign mul_EXE = mul_out[31:0];
    
//#########################################################################
//# Pipe_EXE_MEM 流水线寄存器
//#########################################################################
    wire DM_w_MEM;
    wire [1:0] mux_wdata_MEM;
    wire [31:0] DM_wdata_MEM;

    Pipe_EXE_MEM Pipe_EXE_MEM(
        .clk(clk),
        .rst(rst),

        .DM_w_EXE(DM_w_EXE),
        .write_EXE(write_EXE),
        .is_LW_EXE(is_LW_EXE), 
        .is_JAL_EXE(is_JAL_EXE), 
        .is_MUL_EXE(is_MUL_EXE),
        .waddr_EXE(waddr_EXE),
        .npc_EXE(npc_EXE),
        .alu_EXE(alu_EXE),
        .mul_EXE(mul_EXE),
        .DM_wdata_EXE(DM_wdata_EXE),

        .DM_w_MEM(DM_w_MEM),
        .write_MEM(write_MEM),
        .is_LW_MEM(is_LW_MEM), 
        .is_JAL_MEM(is_JAL_MEM), 
        .is_MUL_MEM(is_MUL_MEM),
        .waddr_MEM(waddr_MEM),
        .npc_MEM(npc_MEM),
        .alu_MEM(alu_MEM),
        .mul_MEM(mul_MEM),
        .DM_wdata_MEM(DM_wdata_MEM)
    );

//#########################################################################
//# MEM 部分
//#########################################################################
    wire DM_w;
    wire [31:0] DM_addr;
    wire [31:0] DM_rdata;
    wire [31:0] DM_wdata;
    assign DM_addr = alu_MEM;
    assign DM_wdata = DM_wdata_MEM;
    assign DM_w = DM_w_MEM;
    dmem dmem(~clk,rst,DM_w,DM_addr,DM_wdata,DM_rdata);
    
//#########################################################################
//# Pipe_MEM_WB 流水线寄存器
//#########################################################################
    wire write_WB;
    wire is_LW_WB;
    wire is_JAL_WB;
    wire is_MUL_WB;
    wire [4:0] waddr_WB;
    wire [31:0] alu_WB;
    wire [31:0] mul_WB;
    wire [31:0] npc_WB;
    wire [31:0] DM_rdata_WB;
    wire [1:0] mux_wdata_WB;

    Pipe_MEM_WB Pipe_MEM_WB(
        .clk(clk),
        .rst(rst),
        
        .write_MEM(write_MEM),
        .is_LW_MEM(is_LW_MEM), 
        .is_JAL_MEM(is_JAL_MEM), 
        .is_MUL_MEM(is_MUL_MEM),
        .waddr_MEM(waddr_MEM),
        .alu_MEM(alu_MEM),
        .mul_MEM(mul_MEM),
        .npc_MEM(npc_MEM),
        .DM_rdata_MEM(DM_rdata),

        .write_WB(write_WB),
        .is_LW_WB(is_LW_WB), 
        .is_JAL_WB(is_JAL_WB), 
        .is_MUL_WB(is_MUL_WB),
        .waddr_WB(waddr_WB),
        .alu_WB(alu_WB),
        .mul_WB(mul_WB),
        .npc_WB(npc_WB),
        .DM_rdata_WB(DM_rdata_WB)
    );
    
//#########################################################################
//# WB 部分
//#########################################################################
    wire [31:0] wdata_WB;
    assign wdata_WB = (is_LW_WB) ? DM_rdata_WB : (is_JAL_WB) ? npc_WB : (is_MUL_WB) ? mul_WB : alu_WB;
    regfile_board regfile_board(clk,rst,write_WB,rs,rt,waddr_WB,wdata_WB,rs_data,rt_data,reg6,reg7,reg8,reg9,reg10);

endmodule