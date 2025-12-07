`timescale 1ns / 1ps
module wb(
    input  wire        clk,
    input  wire        rst,
    input  wire        MemtoReg,
    input  wire [31:0] memReaddata,
    input  wire [31:0] memALUresult,
    output wire [31:0] wb_data
);
    assign wb_data = MemtoReg ? memReaddata : memALUresult;
endmodule
