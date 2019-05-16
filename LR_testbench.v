`timescale 1ns/10ps
`define CYCLE      50          	          
`define End_CYCLE  5000         

module testfixture;
//===================================================================
reg   clk = 0;
reg   rst = 0;
reg signed [15:0] Xi [0:15];
reg signed [15:0] Yi [0:15];
reg signed [15:0] X;
reg signed [15:0] Y;
wire [31:0] B1,B0;
wire [31:0] MSE;
wire busy;

//===================================================================
integer i=0;
//===================================================================
initial begin
rst = 0;
#(`CYCLE) rst = 1;
#(`CYCLE) rst = 0;
end
//===================================================================
always #(`CYCLE/2) clk = ~clk;

//===================================================================
initial begin
Xi [0]  =  16'd9 ;
Xi [1]  = -16'd35;
Xi [2]  =  16'd80;
Xi [3]  =  16'd51;
Xi [4]  = -16'd94;
Xi [5]  =  16'd21;
Xi [6]  = -16'd60;
Xi [7]  =  16'd1 ;

Xi [8]  =  16'd17;
Xi [9]  =  16'd25;
Xi [10] = -16'd16;
Xi [11] = -16'd28;
Xi [12] =  16'd55;
Xi [13] =  16'd21;
Xi [14] =  16'd12;
Xi [15] = -16'd10;

Yi [0]  =  16'd5 ;
Yi [1]  =  16'd89;
Yi [2]  = -16'd64;
Yi [3]  =  16'd32;
Yi [4]  = -16'd15;
Yi [5]  =  16'd77;
Yi [6]  =  16'd45;
Yi [7]  = -16'd11;

Yi [8]  =  16'd19;
Yi [9]  =  16'd27;
Yi [10] = -16'd15;
Yi [11] = -16'd10;
Yi [12] =  16'd44;
Yi [13] =  16'd20;
Yi [14] =  16'd11;
Yi [15] =  16'd5 ;
end
//===================================================================
always @(negedge clk) begin
    if (busy == 0) begin
        X = Xi[i];
        Y = Yi[i];
        i =i+1;
    end
end
//===================================================================
initial begin
$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
$monitor($time,"B1=%b B0=%b MSE=%b",B1,B0,MSE);

#(`End_CYCLE);$finish;
end
//===================================================================
Linear_Regression LR( .clk(clk), .rst(rst), .X(X), .Y(Y), .B1(B1), .B0(B0), .MSE(MSE), .busy(busy) );

initial begin
$fsdbDumpfile("LR.fsdb");
$fsdbDumpvars;
end

endmodule
