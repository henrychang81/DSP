module Linear_Regression( 
    input clk, 
    input rst, 
    input signed [15:0] X, 
    input signed [15:0] Y, 
    output reg [31:0] B1,
    output reg [31:0] B0, 
    output reg [31:0] MSE,
    output reg busy
        );
//===================================================================
reg signed [15:0] tempx;
reg signed [15:0] tempy;

reg signed [15:0] tempx1,tempx2,tempx3,tempx4,tempx5,tempx6,tempx7;
reg signed [15:0] tempy1,tempy2,tempy3,tempy4,tempy5,tempy6,tempy7;

reg signed [31:0] sum_xy;

reg signed [15:0] sum_x;
reg signed [15:0] sum_y;

reg signed [31:0] sumsquare_x;

reg signed [31:0] B1_up,B1_down;

reg signed [31:0] tempMSE;
reg signed [31:0] tempMSE1,tempMSE2,tempMSE3,tempMSE4,tempMSE5,tempMSE6,tempMSE7;
//===================================================================
// data[x] represent data(t-x) 
//===================================================================
integer counter;
integer N;
//===================================================================
reg [2:0] state;
parameter IDLE=3'b000,propagateXY=3'b001,calculateXY=3'b010,calculateB1=3'b011,calculateB0=3'b100,calculateMSE=3'b101;
//===================================================================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tempx <=16'd0; tempx1<=16'd0; tempx2<=16'd0; tempx3<=16'd0;
        tempx4<=16'd0; tempx5<=16'd0; tempx6<=16'd0; tempx7<=16'd0; 

        tempy <=16'd0; tempy1<=16'd0; tempy2<=16'd0; tempy3<=16'd0;
        tempy4<=16'd0; tempy5<=16'd0; tempy6<=16'd0; tempy7<=16'd0;
 
        sum_xy<=32'd0;
        sum_x <=16'd0; 
        sum_y <=16'd0;
        sumsquare_x<=32'd0;
                
        B1_up<=32'd0; B1_down<=32'd0;
        B1<=32'd0; B0<=32'd0;

        tempMSE <=32'd0; tempMSE1<=32'd0; tempMSE2<=32'd0; tempMSE3<=32'd0;
        tempMSE4<=32'd0; tempMSE5<=32'd0; tempMSE6<=32'd0; tempMSE7<=32'd0;
        MSE<=32'd0;

        counter<=0;
        N<=8;
        busy<=0;
        state<=propagateXY;
    end
    else begin
        case (state)
        //IDLE
        IDLE : begin
            busy<=0;
            counter<=0;
            state <= propagateXY;

            tempx <=16'd0; tempx1<=16'd0; tempx2<=16'd0; tempx3<=16'd0;
            tempx4<=16'd0; tempx5<=16'd0; tempx6<=16'd0; tempx7<=16'd0; 

            tempy <=16'd0; tempy1<=16'd0; tempy2<=16'd0; tempy3<=16'd0;
            tempy4<=16'd0; tempy5<=16'd0; tempy6<=16'd0; tempy7<=16'd0; 
            
            B1_up<=32'd0; B1_down<=32'd0;
            B1<=32'd0; B0<=32'd0;

            tempMSE <=32'd0; tempMSE1<=32'd0; tempMSE2<=32'd0; tempMSE3<=32'd0;
            tempMSE4<=32'd0; tempMSE5<=32'd0; tempMSE6<=32'd0; tempMSE7<=32'd0;
            MSE<=32'd0;
        end
        //propagateXY
        propagateXY : begin
		
            tempx<= X; tempy<= Y;
            busy <= 1;
          
            tempx1 <= tempx  ; tempy1 <= tempy ;
            tempx2 <= tempx1 ; tempy2 <= tempy1;
            tempx3 <= tempx2 ; tempy3 <= tempy2;
            tempx4 <= tempx3 ; tempy4 <= tempy3;
            tempx5 <= tempx4 ; tempy5 <= tempy4;
            tempx6 <= tempx5 ; tempy6 <= tempy5;
            tempx7 <= tempx6 ; tempy7 <= tempy6;
                
            state <= calculateXY;

        end
        //calculateXY
        calculateXY : begin
            //top and left sigma : sigma x * y
            sum_xy <= sum_xy + (tempx * tempy);
             
            //top and right sigma : sigma x * sigma y
            sum_x <= sum_x + tempx;
            sum_y <= sum_y + tempy;
               
            //bottom and left sigma : sigma of square x
            sumsquare_x  <= sumsquare_x + (tempx**2);

			
            counter <= counter+1;
            if (counter== 7)begin 
                state <= calculateB1; 
                busy  <= 1; 
            end
            else begin 
                state <= propagateXY;
                busy  <= 0;
            end           
        end
        //calculate B1
        calculateB1 : begin
            B1_up   <= (N * sum_xy) - (sum_x * sum_y) ;
            B1_down <= (N * sumsquare_x) - (sum_x)**2 ;
            B1      <= B1_up / B1_down ;
			
            if (B1 == 0) begin state <= calculateB1; end
            else begin state <= calculateB0;
            end     
        end
        //calculate B0
        calculateB0 : begin
            B0 <= ( sum_y-(B1 * sum_x) ) / N;
            
            if (B0 == 0) begin state <= calculateB0; end
            else begin state <= calculateMSE; 
            end
        end
        //calculate MSE
        calculateMSE : begin
            tempMSE  <= (tempy -B0-B1*tempx )**2;
            tempMSE1 <= (tempy1-B0-B1*tempx1)**2;
            tempMSE2 <= (tempy2-B0-B1*tempx2)**2;
            tempMSE3 <= (tempy3-B0-B1*tempx3)**2;
            tempMSE4 <= (tempy4-B0-B1*tempx4)**2;
            tempMSE5 <= (tempy5-B0-B1*tempx5)**2;
            tempMSE6 <= (tempy6-B0-B1*tempx6)**2;
            tempMSE7 <= (tempy7-B0-B1*tempx7)**2;
			
            MSE <= (tempMSE + tempMSE1 + tempMSE2 + tempMSE3 + tempMSE4 + tempMSE5 + tempMSE6 + tempMSE7) / N;
			
            if (MSE == 0) begin state <= calculateMSE; end
            else begin state <= IDLE;
            end
        end
        endcase         
    end
end     

endmodule
