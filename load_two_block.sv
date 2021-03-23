`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/14 10:30:18
// Design Name: 
// Module Name: load_two_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//


module load_two_block
(
input logic clk,
input logic rst,
input logic start,
input logic [7:0]block_row,
input logic [7:0]block_col,
input logic [7:0]block_k,                        //load A[block_row:block_row+Tn,block_k:block_k+Tn]
input logic [15:0]dina,                          //load B[block_k:bloc_k+Tn,block_col:block_col+Tn]
input logic [15:0]dinb,
output logic [7:0]addra,
output logic [7:0]addrb,
output logic [15:0]block_mat_a[0:Tn-1][0:Tn-1],
output logic [15:0]block_mat_b[0:Tn-1][0:Tn-1],
output logic done
);
parameter Tn=4;

logic done_a;
logic done_b;
assign done=done_a&&done_b;

load_block block_a(
.start(start),
.clk(clk),
.rst(rst),
.din(dina),
.addr(addra),
.block_row(block_row),
.block_col(block_k),         //读取M[block_row:block_row+Tn,block_col:block_col+Tn]
.block_mat(block_mat_a),
.done(done_a)
);

load_block block_b(
.start(start),
.clk(clk),
.rst(rst),
.din(dinb),
.addr(addrb),
.block_row(block_k),
.block_col(block_col),         //读取M[block_row:block_row+Tn,block_col:block_col+Tn]
.block_mat(block_mat_b),
.done(done_b)
);
endmodule

