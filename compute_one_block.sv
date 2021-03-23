`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/16 22:53:40
// Design Name: 
// Module Name: compute_one_block
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


module compute_one_block(
input logic clk,
input logic rst,
input logic start,
input logic [15:0]dina,
input logic [15:0]dinb,
input logic [7:0]block_row,
input logic [7:0]block_col,
output logic [7:0]addra,
output logic [7:0]addrb,
output logic [15:0]result[0:Tn-1][0:Tn-1],
output logic done
    );
parameter Tn=4;
parameter N=16;

logic [15:0] buff_a1[0:Tn-1][0:Tn-1];
logic [15:0] buff_a2[0:Tn-1][0:Tn-1];
logic [15:0] buff_b1[0:Tn-1][0:Tn-1];
logic [15:0] buff_b2[0:Tn-1][0:Tn-1];
logic [15:0] buff_o1[0:Tn-1][0:Tn-1];
logic [15:0] buff_o2[0:Tn-1][0:Tn-1];

logic pingpang;
logic pingpang_start;
logic pingpang_done;

logic start_load1;
logic start_load2;
logic start_compute1;
logic start_compute2;
logic load1_done;
logic load2_done;
logic compute1_done;
logic compute2_done;
logic load1_done_ff;
logic load2_done_ff;
logic compute1_done_ff;
logic compute2_done_ff;

logic [7:0]addra1;
logic [7:0]addra2;
logic [7:0]addrb1;
logic [7:0]addrb2;

logic [7:0]block_k;
logic [7:0]pre_block_k;          //load block and compute pre_block_k

logic first_load;
logic final_compute;
logic busy;
//result
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    for(int i=0;i<Tn;i++)
        for(int j=0;j<Tn;j++)
            result[i][j]<=16'd0;
end
else if(start)
begin
    for(int i=0;i<Tn;i++)
        for(int j=0;j<Tn;j++)
            result[i][j]<=16'd0;
end
else if(busy)
    if(compute1_done)
        for(int i=0;i<Tn;i++)
            for(int j=0;j<Tn;j++)
                result[i][j]<=result[i][j]+buff_o1[i][j];
    else if(compute2_done)
        for(int i=0;i<Tn;i++)
            for(int j=0;j<Tn;j++)
                result[i][j]<=result[i][j]+buff_o2[i][j];
//first_load,final_compute
assign first_load=(busy&&block_k==0)?1'b1:1'b0;
assign final_compute=(busy&&pre_block_k==N-Tn)?1'b1:1'b0;
assign init=(busy&&pre_block_k==0)?1'b1:1'b0;
//busy
always_ff@(posedge clk,posedge rst)
if(rst)
    busy<=1'b0;
else if(start)
    busy<=1'b1;
else if(pingpang_done&&pre_block_k==N-Tn)
    busy<=1'b0;
//pingpang_start
always_ff@(posedge clk,posedge rst)
if(rst)
    pingpang_start<=1'b0;
else if(start)
    pingpang_start<=1'b1;
else if(pingpang_done&&~pingpang_start&&busy&&~done)
    pingpang_start<=1'b1;
else
    pingpang_start<=1'b0;
//pingpang
always_ff@(posedge clk,posedge rst)
if(rst)
    pingpang<=1'b0;
else if(start)
    pingpang<=1'b0;
else if(pingpang_done)
    pingpang<=~pingpang;
//load1_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
    load1_done_ff<=1'b0;
else if(start||pingpang_done)
    load1_done_ff<=1'b0;
else if(load1_done)
    load1_done_ff<=1'b1;
//load2_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
    load2_done_ff<=1'b0;
else if(start||pingpang_done)
    load2_done_ff<=1'b0;
else if(load2_done)
    load2_done_ff<=1'b1;
//compute1_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
    compute1_done_ff<=1'b0;
else if(start||pingpang_done)
    compute1_done_ff<=1'b0;
else if(compute1_done)
    compute1_done_ff<=1'b1;
//compute2_done_ff
always_ff@(posedge clk,posedge rst)
if(rst)
    compute2_done_ff<=1'b0;
else if(start||pingpang_done)
    compute2_done_ff<=1'b0;
else if(compute2_done)
    compute2_done_ff<=1'b1;
//pingpang_done
always_ff@(posedge clk,posedge rst)
if(rst)
    pingpang_done<=1'b0;
else if(pingpang==1'b0)                     //load buffer1 and compute buffer2
   if(~pingpang_done)
        if(first_load&&load1_done_ff)
            pingpang_done<=1'b1;
        else if(final_compute&&compute2_done_ff)
            pingpang_done<=1'b1;
        else if(load1_done_ff&&compute2_done_ff)
            pingpang_done<=1'b1;
        else
            pingpang_done<=1'b0;
    else
        pingpang_done<=1'b0;
else                                       //load2 and compute1
    if(~pingpang_done)
        if(first_load&&load2_done_ff)
            pingpang_done<=1'b1;
        else if(final_compute&&compute1_done_ff)
            pingpang_done<=1'b1;
        else if(load2_done_ff&&compute1_done_ff)
            pingpang_done<=1'b1;
        else
            pingpang_done<=1'b0;
    else
        pingpang_done<=1'b0;
//1，2的start_load和start_compute信号
assign start_load1=(~pingpang&&pingpang_start&&~final_compute)?1'b1:1'b0;
assign start_load2=(pingpang&&pingpang_start&&~final_compute)?1'b1:1'b0;
assign start_compute1=(pingpang&&pingpang_start&&~first_load)?1'b1:1'b0;
assign start_compute2=(~pingpang&&pingpang_start&&~first_load)?1'b1:1'b0;
//根据pingpang选择地址线来源
assign addra=(pingpang==1'b1)?addra2:addra1;
assign addrb=(pingpang==1'b1)?addrb2:addrb1;
//block_k
always_ff@(posedge clk,posedge rst)
if(rst)
    block_k<=8'd0;
else if(start)
    block_k<=8'd0;
else if(pingpang_done)
    block_k<=(block_k==N-Tn)?block_k:block_k+Tn;
//pre_block_k
always_ff@(posedge clk,posedge rst)
if(rst)
    pre_block_k<=8'd0;
else if(start)
    pre_block_k<=8'd0;
else if(pingpang_done)
    pre_block_k<=block_k;
//done
assign done=(pingpang_done&&pre_block_k==N-Tn)?1'b1:1'b0;
//模块例化
load_two_block   load1
(
.clk(clk),
.rst(rst),
.start(start_load1),
.block_row(block_row),
.block_col(block_col),
.block_k(block_k),                            //load A[block_row:block_row+Tn,block_k:block_k+Tn]
.dina(dina),                                        //load B[block_k:bloc_k+Tn,block_col:block_col+Tn]
.dinb(dinb),
.addra(addra1),
.addrb(addrb1),
.block_mat_a(buff_a1),
.block_mat_b(buff_b1),
.done(load1_done)
);

load_two_block   load2
(
.clk(clk),
.rst(rst),
.start(start_load2),
.block_row(block_row),
.block_col(block_col),
.block_k(block_k),                            //load A[block_row:block_row+Tn,block_k:block_k+Tn]
.dina(dina),                                        //load B[block_k:bloc_k+Tn,block_col:block_col+Tn]
.dinb(dinb),
.addra(addra2),
.addrb(addrb2),
.block_mat_a(buff_a2),
.block_mat_b(buff_b2),
.done(load2_done)
);

block_mm compute1
(
.clk(clk),
.rst(rst),
.start(start_compute1),                 //start拉高一个周期表示开始
.A(buff_a1),
.B(buff_b1),
.O(buff_o1),
.done(compute1_done)                              //done拉高一个周期表示完成
);

block_mm compute2
(
.clk(clk),
.rst(rst),
.start(start_compute2),                 //start拉高一个周期表示开始
.A(buff_a2),
.B(buff_b2),
.O(buff_o2),
.done(compute2_done)                              //done拉高一个周期表示完成
);

endmodule

