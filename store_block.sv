`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 19:12:44
// Design Name: 
// Module Name: store_block
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


module store_block(
input logic [7:0]block_row,
input logic [7:0]block_col,
input logic [15:0]block_mat[0:Tn-1][0:Tn-1],
input logic clk,
input logic rst,
input logic start,
output logic we,
output logic [7:0]addr,
output logic [15:0]dout,
output logic done
    );
parameter Tn=4;
parameter N=16;
logic [7:0]row;
logic [7:0]col;
logic busy;
//busy
always_ff@(posedge clk,posedge rst)
if(rst)
   busy<=1'b0;
else if(start)
   busy<=1'b1;
else if(row==block_row+Tn-1&&col==block_col+Tn-1)
   busy<=1'b0;
//row
always_ff@(posedge clk,posedge rst)
if(rst)
   row<=8'd0;
else if(start)
   row<=block_row;
else if(col==block_col+Tn-1)
   if(row==block_row+Tn-1)
       row<=8'd0;
   else
       row<=row+8'd1;
//col
always_ff@(posedge clk,posedge rst)
if(rst)
   col<=8'd0;
else if(start)
   col<=block_col;
else if(col==block_col+Tn-1)
   col<=block_col;
else
   col<=col+8'd1;
//we
always_ff@(posedge clk,posedge rst)
if(rst)
   we<=1'b0;
else if(busy)
   we<=1'b1;
else
   we<=1'b0;
//addr
always_ff@(posedge clk,posedge rst)
if(rst)
   addr<=8'd0;
else if(busy)
   addr<=row*N+col;
else
   addr<=8'd0;
//dout
always_ff@(posedge clk,posedge rst)
if(rst)
   dout<=16'd0;
else if(busy)
   dout<=block_mat[row-block_row][col-block_col];
else 
   dout<=16'd0;
//done
assign done=(~busy&&we)?1'b1:1'b0;
endmodule

