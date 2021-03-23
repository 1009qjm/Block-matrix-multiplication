`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 22:36:27
// Design Name: 
// Module Name: compute_mm_test
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


module compute_mm_test;
parameter N = 16;
logic clk;
logic rst;
logic start;
logic [15:0]dina;
logic [15:0]dinb;
logic [7:0]addra;
logic [7:0]addrb;
logic we;
logic [7:0]addro;
logic [15:0]douto;
logic done;
//
logic [7:0]addra_ff;
logic [7:0]addrb_ff;
logic [15:0]result[0:N-1][0:N-1];
logic [7:0]row;
logic [7:0]col;
logic [15:0]A[0:N-1][0:N-1];
logic [15:0]B[0:N-1][0:N-1];
logic [15:0]O[0:N-1][0:N-1];
int error_count;

initial 
begin
    for(int i=0;i<N;i++)
        for(int j=0;j<N;j++)
        begin
            A[i][j]=i*16+j;
            B[i][j]=i*16+j;
        end    
    for(int i=0;i<N;i++)
        for(int j=0;j<N;j++)
        begin
            O[i][j]=0;
            for(int k=0;k<N;k++)
                O[i][j]+=A[i][k]*B[k][j];
        end
    for(int i=0;i<N;i++)
    begin
        for(int j=0;j<N;j++)
        begin
            $write("%d,",O[i][j]);
        end
        $write("\n");
    end
end


assign row=addro[7:4];              //row=addro/16
assign col=addro[3:0];              //col=addro%16
//result
always_ff@(posedge clk,posedge rst)
if(rst)
for(int i=0;i<N;i++)
    for(int j=0;j<N;j++)
        result[i][j]=0;
else if(we)
begin
    result[row][col]<=douto;
end
//done
always_ff@(posedge clk)
if(done)
begin
$display("The Module's Result:");
for(int i=0;i<N;i++)
begin
    for(int j=0;j<N;j++)
    begin
        $write("%d,",result[i][j]);
    end
    $write("\n");
end
$display("Compare the result");
error_count=0;
for(int i=0;i<N;i++)
    for(int j=0;j<N;j++)
    begin
        if(O[i][j]!=result[i][j])
        begin
            $display("Error,O[%d][%d]!=result[%d][%d]",i,j,i,j);
            error_count++;
        end
    end
if(error_count==0)
    $display("Test Pass");
end
//dina,dinb
always_ff@(posedge clk,posedge rst)
if(rst)
begin
    dina<=16'd0;
    dinb<=16'd0;
end
else 
begin
    dina<=addra_ff;
    dinb<=addrb_ff;
end
always_ff@(posedge clk,posedge rst)
if(rst)
begin
   addra_ff<=8'd0;
   addrb_ff<=8'd0;
end
else
begin
    addra_ff<=addra;
    addrb_ff<=addrb;
end
//clk
initial
begin
    clk=0;
    forever
    #5
    clk=~clk;
end
//rst
initial
begin
    rst=1;
    #10
    rst=0;
end
//start
initial
begin
    start=0;
    #100
    start=1;
    #10
    start=0;
end

compute_mm U(.*);
endmodule

