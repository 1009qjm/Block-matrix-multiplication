`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 21:51:58
// Design Name: 
// Module Name: compute_mm
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


module compute_mm(               //O=A*B
input logic clk,
input logic rst,
input logic start,
input logic [15:0]dina,          //读取矩阵A
input logic [15:0]dinb,          //读取矩阵B
output logic [7:0]addra,        
output logic [7:0]addrb,
output logic we,                 //结果写入O矩阵
output logic [7:0]addro,
output logic [15:0]douto,
output logic done
    );
parameter N = 16;
parameter Tn = 4;

logic [15:0]buff_o1[0:Tn-1][0:Tn-1];
logic [15:0]buff_o2[0:Tn-1][0:Tn-1];
logic [7:0]block_row;
logic [7:0]block_col;
logic [7:0]pre_block_row;                 //compute block and store pre_block
logic [7:0]pre_block_col;

logic pingpang;
logic pingpang_start;
logic pingpang_done;

logic start_compute1;
logic start_compute2;
logic start_store1;
logic start_store2;
logic compute1_done;
logic compute2_done;
logic store1_done;
logic store2_done;
logic compute1_done_ff;
logic compute2_done_ff;
logic store1_done_ff;
logic store2_done_ff;

logic we1;
logic we2;
logic [7:0]addro1;
logic [7:0]addro2;
logic [15:0]douto1;
logic [15:0]douto2;
logic [7:0]addra1;
logic [7:0]addra2;
logic [7:0]addrb1;
logic [7:0]addrb2;

logic first_compute;
logic final_store;
logic busy;
//busy
always_ff@(posedge clk,posedge rst)
if(rst)
   busy<=1'b0;
else if(start)
   busy<=1'b1;
else if(done)
   busy<=1'b0;
//block_col
always_ff@(posedge clk,posedge rst)
if(rst)
   block_col<=8'd0;
else if(start)
   block_col<=8'd0;
else if(pingpang_done)
   if(block_col==N-Tn)
      block_col<=8'd0;
   else
      block_col<=block_col+Tn;
//block_row
always_ff@(posedge clk,posedge rst)
if(rst)
   block_row<=8'd0;
else if(start)
   block_row<=8'd0;
else if(pingpang_done&&block_col==N-Tn)
   block_row<=block_row+Tn;
//pre_block_row,pre_block_col
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    pre_block_row<=8'd0;
    pre_block_col<=8'd0;
end
else if(pingpang_done)
begin
    pre_block_row<=block_row;
    pre_block_col<=block_col;
end
//pingpang
always_ff@(posedge clk,posedge rst)
if(rst)
   pingpang<=1'b0;
else if(start)
   pingpang<=1'b0;
else if(pingpang_done)
   pingpang<=~pingpang;
//pingpang_start
always_ff@(posedge clk,posedge rst)
if(rst)
    pingpang_start<=1'b0;
else if(start)
    pingpang_start<=1'b1;
else if(pingpang_done&&~pingpang_start&&~done)
    pingpang_start<=1'b1;
else 
    pingpang_start<=1'b0;
//compute1_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
   compute1_done_ff<=1'b0;
else if(compute1_done)
   compute1_done_ff<=1'b1;
else if(pingpang_done)
   compute1_done_ff<=1'b0;
//compute2_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
   compute2_done_ff<=1'b0;
else if(compute2_done)
   compute2_done_ff<=1'b1;
else if(pingpang_done)
   compute2_done_ff<=1'b0;
//store1_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
   store1_done_ff<=1'b0;
else if(store1_done)
   store1_done_ff<=1'b1;
else if(pingpang_done)
   store1_done_ff<=1'b0;
//store2_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
   store2_done_ff<=1'b0;
else if(store2_done)
   store2_done_ff<=1'b1;
else if(pingpang_done)
   store2_done_ff<=1'b0;
//pingpang_done
always_ff@(posedge clk,posedge rst)
if(rst)
   pingpang_done<=1'b0;
else if(pingpang==1'b0)                    //compute1 and store2
    if(~pingpang_done)                
        if(first_compute&&compute1_done_ff)
            pingpang_done<=1'b1;
        else if(final_store&&store2_done_ff)
            pingpang_done<=1'b1;
        else if(compute1_done_ff&&store2_done_ff)
            pingpang_done<=1'b1;
        else
            pingpang_done<=1'b0;
    else
        pingpang_done<=1'b0;
else                                        //compute2 and store1
    if(~pingpang_done)
        if(first_compute&&compute2_done_ff)
            pingpang_done<=1'b1;
        else if(final_store&&store1_done_ff)
            pingpang_done<=1'b1;
        else if(compute2_done_ff&&store1_done_ff)
            pingpang_done<=1'b1;
        else
            pingpang_done<=1'b0;
    else
        pingpang_done<=1'b0; 
//done,fisrt_compute,final_compute
assign done=(pingpang_done&&pre_block_col==N-Tn&&pre_block_row==N-Tn)?1'b1:1'b0;
assign first_compute=(block_row==0&&block_col==0&&busy)?1'b1:1'b0;
assign final_store=(pre_block_row==N-Tn&&pre_block_col==N-Tn&&busy)?1'b1:1'b0;
//start1,2
assign start_compute1=(~pingpang&&pingpang_start&&~final_store)?1'b1:1'b0;
assign start_store2=(~pingpang&&pingpang_start&&~first_compute)?1'b1:1'b0;
assign start_compute2=(pingpang&&pingpang_start&&~final_store)?1'b1:1'b0;
assign start_store1=(pingpang&&pingpang_start&&~first_compute)?1'b1:1'b0;
//addra1,addra2,addrb1,addrb2
assign addra=(pingpang==1'b0)?addra1:addra2;
assign addrb=(pingpang==1'b0)?addrb1:addrb2;
//addro1,addro2,we1,we2,douto1,douto2
assign addro=(pingpang==1'b0)?addro2:addro1;                                   //compute1 and store2
assign we=(pingpang==1'b0)?we2:we1;
assign douto=(pingpang==1'b0)?douto2:douto1;
//模块例化
compute_one_block U1(
.clk(clk),
.rst(rst),
.start(start_compute1),
.dina(dina),
.dinb(dinb),
.block_row(block_row),
.block_col(block_col),
.addra(addra1),
.addrb(addrb1),
.result(buff_o1),
.done(compute1_done)
    );

compute_one_block U2(
.clk(clk),
.rst(rst),
.start(start_compute2),
.dina(dina),
.dinb(dinb),
.block_row(block_row),
.block_col(block_col),
.addra(addra2),
.addrb(addrb2),
.result(buff_o2),
.done(compute2_done)
    );

store_block V1(
.block_row(pre_block_row),
.block_col(pre_block_col),
.block_mat(buff_o1),
.clk(clk),
.rst(rst),
.start(start_store1),
.we(we1),
.addr(addro1),
.dout(douto1),
.done(store1_done)
    );

store_block V2(
.block_row(pre_block_row),
.block_col(pre_block_col),
.block_mat(buff_o2),
.clk(clk),
.rst(rst),
.start(start_store2),
.we(we2),
.addr(addro2),
.dout(douto2),
.done(store2_done)
    );
endmodule

