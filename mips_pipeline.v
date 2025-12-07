`timescale 1ns / 1ps
module mips_pipeline(
    input wire clk,
    input wire rst
);
    // IF/ID
    wire [31:0] if_id_npc;
    wire [31:0] if_id_instr;

    // ID/EX
    wire [1:0]  id_ex_wb;
    wire [2:0]  id_ex_mem;
    wire [3:0]  id_ex_ex;
    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_rdata1;
    wire [31:0] id_ex_rdata2;
    wire [31:0] id_ex_signext;
    wire [4:0]  id_ex_rt;
    wire [4:0]  id_ex_rd;

    // EX/MEM
    wire [1:0]  ex_mem_wb_ctl;
    wire        ex_mem_branch;
    wire        ex_mem_memread;
    wire        ex_mem_memwrite;
    wire [31:0] ex_mem_npc;
    wire        ex_mem_zero;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rdata2;
    wire [4:0]  ex_mem_rd;

    // MEM/WB
    wire [1:0]  mem_wb_WBControl;
    wire [31:0] mem_wb_ReadData;
    wire [31:0] mem_wb_ALUResult;
    wire [4:0]  mem_wb_WriteReg;

    // WB → Decode
    wire        wb_reg_write;
    wire [31:0] wb_writedata;

    // Branch to Fetch
    wire        PCSrc;

    // Fetch
    if_stage ifs(
        .ex_mem_pc_src(PCSrc),
        .ex_mem_npc(ex_mem_npc),
        .address_out(if_id_npc),
        .instr_out(if_id_instr),
        .clk(clk),
        .rst(rst)
    );

    // Decode
    id_stage ids(
        .clk(clk),
        .rst(rst),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg_location(mem_wb_WriteReg),
        .mem_wb_write_data(wb_writedata),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc),
        .id_ex_wb(id_ex_wb),
        .id_ex_mem(id_ex_mem),
        .id_ex_execute(id_ex_ex),
        .id_ex_npc(id_ex_npc),
        .id_ex_readdat1(id_ex_rdata1),
        .id_ex_readdat2(id_ex_rdata2),
        .id_ex_sign_ext(id_ex_signext),
        .id_ex_instr_bits_2016(id_ex_rt),
        .id_ex_instr_bits_1511(id_ex_rd)
    );

    // Execute
    EXECUTE exs(
        .wb_ctl(id_ex_wb),
        .m_ctl(id_ex_mem),
        .regdst(id_ex_ex[3]),
        .alusrc(id_ex_ex[0]),
        .aluop(id_ex_ex[2:1]),
        .npcout(id_ex_npc),
        .rdata1(id_ex_rdata1),
        .rdata2(id_ex_rdata2),
        .s_extendout(id_ex_signext),
        .instrout_2016(id_ex_rt),
        .instrout_1511(id_ex_rd),
        .wb_ctlout(ex_mem_wb_ctl),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .EX_MEM_NPC(ex_mem_npc),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rdata2out(ex_mem_rdata2),
        .five_bit_muxout(ex_mem_rd)
    );

    // Memory
    mem_stage mems(
        .clk(clk),
        .ALUResult(ex_mem_alu_result),
        .WriteData(ex_mem_rdata2),
        .WriteReg(ex_mem_rd),
        .WBControl(ex_mem_wb_ctl),
        .MemWrite(ex_mem_memwrite),
        .MemRead(ex_mem_memread),
        .Branch(ex_mem_branch),
        .Zero(ex_mem_zero),
        .ReadData(mem_wb_ReadData),
        .ALUResult_out(mem_wb_ALUResult),
        .WriteReg_out(mem_wb_WriteReg),
        .WBControl_out(mem_wb_WBControl),
        .PCSrc(PCSrc)
    );

    // Writeback
    assign wb_reg_write = mem_wb_WBControl[1]; // RegWrite
    wb wb_stage(
        .clk(clk),
        .rst(rst),
        .MemtoReg(mem_wb_WBControl[0]),
        .memReaddata(mem_wb_ReadData),
        .memALUresult(mem_wb_ALUResult),
        .wb_data(wb_writedata)
    );
endmodule
