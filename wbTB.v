`timescale 1ns / 1ps
module wbTB();
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, wbTB);
end
reg clk, rst, MemtoReg;
reg [31:0] memReaddata, memALUresult;
wire [31:0] wb_data;
wb u1(clk, rst, MemtoReg, memReaddata, memALUresult, wb_data);
initial begin
clk = 1'b0;
repeat(50) #5 clk = ~clk;
end
initial begin
rst = 1'b1;
MemtoReg = 1'b0;
memReaddata =32'd255;
memALUresult = 32'd0;
#10;
MemtoReg = 1'b1;
end
endmodule
