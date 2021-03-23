`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/13 16:04:32
// Design Name: 
// Module Name: block_mm
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


module block_mm
#(parameter Tn=4)
(
input logic clk,
input logic rst,
input logic start,                 //start拉高一个周期表示开始
input logic [15:0] A[0:Tn-1][0:Tn-1],
input logic [15:0] B[0:Tn-1][0:Tn-1],
output logic [15:0] O[0:Tn-1][0:Tn-1],
output logic done                              //done拉高一个周期表示完成
    );
int row;
int col;
int k;
logic busy;
//busy
always_ff@(posedge clk,posedge rst)
if(rst)
    busy<=1'b0;
else if(start)
    busy<=1'b1;
else if(row==Tn-1&&col==Tn-1&&k==Tn-1)
    busy<=1'b0;
//k
always_ff@(posedge clk,posedge rst)
if(rst)
    k<=0;
else if(start)
    k<=0;
else if(busy)
if(k==Tn-1)
    k<=0;
else
    k<=k+1;
//col
always_ff@(posedge clk,posedge rst)
if(rst)
    col<=0;
else if(start)
    col<=0;
else if(k==Tn-1)
if(col==Tn-1)
    col<=0;
else
    col<=col+1;
//row
always_ff@(posedge clk,posedge rst)
if(rst)
    row<=0;
else if(start)
    row<=0;
else if(col==Tn-1&&k==Tn-1)
    row<=row+1;
//done
always_ff@(posedge clk,posedge rst)
if(rst)
    done<=1'b0;
else if(row==Tn-1&&col==Tn-1&&k==Tn-1&&done==1'b0)
    done<=1'b1;
else
    done<=1'b0;
//calculate matrix 
always_ff@(posedge clk,posedge rst)
if(rst)
    ;
else if(busy)
    if(k==0)
        O[row][col]<=A[row][k]*B[k][col];
    else
        O[row][col]<=O[row][col]+A[row][k]*B[k][col];

endmodule

