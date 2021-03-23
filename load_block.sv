`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/13 18:10:01
// Design Name: 
// Module Name: load_block
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


module load_block(
input logic start,
input logic clk,
input logic rst,
input logic [15:0] din,
output logic [7:0] addr,
input logic [7:0]block_row,
input logic [7:0]block_col,         //读取M[block_row:block_row+Tn,block_col:block_col+Tn]
output logic [15:0]block_mat[0:Tn-1][0:Tn-1],
output logic done
     );
parameter Tn = 4;
parameter N = 16 ;

logic [7:0]row;
logic [7:0]col;
logic [7:0]row_ff1;
logic [7:0]row_ff2;
logic [7:0]col_ff1;
logic [7:0]col_ff2;
logic busy;
logic busy_ff1;
logic busy_ff2;
logic done_ff0;
logic done_ff1;
logic done_ff2;

assign done=done_ff2;
//done_ff0
always_ff@(posedge clk,posedge rst)
if(rst)
    done_ff0<=1'b0;
else if(row==block_row+Tn-1&&col==block_col+Tn-1&&~done_ff0)
    done_ff0<=1'b1;
else 
    done_ff0<=1'b0;
//done_ff1,ff2
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    done_ff1<=1'b0;
    done_ff2<=1'b0;
end
else
begin
    done_ff1<=done_ff0;
    done_ff2<=done_ff1;
end
//busy
always_ff@(posedge clk,posedge rst)
if(rst)
    busy<=1'b0;
else if(start)
    busy<=1'b1;
else if(row==block_row+Tn-1&&col==block_col+Tn-1)
    busy<=1'b0;
//busy_ff1,busy_ff2
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    busy_ff1<=1'b0;
    busy_ff2<=1'b0;
end
else
begin
    busy_ff1<=busy;
    busy_ff2<=busy_ff1;
end
//row
always_ff@(posedge clk,posedge rst)
if(rst)
    row<=8'd0;
else if(start)
    row<=block_row;
else if(col==block_col+Tn-1)
    row<=row+1;
//col
always_ff@(posedge clk,posedge rst)
if(rst)
    col<=8'd0;
else if(start)
    col<=block_col;
else if(busy)
if(col==block_col+Tn-1)
    col<=block_col;
else 
    col<=col+1;
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    row_ff1<=8'd0;
    row_ff2<=8'd0;
    col_ff1<=8'd0;
    col_ff2<=8'd0;
end
else
begin
    row_ff1<=row;
    row_ff2<=row_ff1;
    col_ff1<=col;
    col_ff2<=col_ff1;
end
//addr
assign addr=(row*N+col);
//din
always_ff@(posedge clk,posedge rst)
if(rst)
    ;
else if(busy_ff2)
    block_mat[row_ff2-block_row][col_ff2-block_col]<=din;    

endmodule

