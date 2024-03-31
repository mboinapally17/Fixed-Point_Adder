`timescale 1ns / 1ps

//WI1, WF1 Word Length and Fraction Length of first number, WI2, WF2 Word length and Fraction Length of second number

module adder #(parameter WI1=4,WI2=4,WF1=4,WF2=4,WIO=4,WFO=4)
                  (in1,in2,start,clk,reset,out,OVF)  ;
input signed [WI1+WF1-1:0]in1;
input signed [WI2+WF2-1:0]in2;
input clk;
input start;
input reset;
output signed [WIO+WFO-1:0]out;
output reg OVF;

localparam WIDTH_I = (WI1>WI2)?WI1:WI2;
localparam WIDTH_F = (WF1>WF2)?WF1:WF2;
reg signed [WIDTH_I+WIDTH_F:0]temp_out;
reg [WFO-1:0]frcpart;
reg signed [WIO-1:0]intpart;

reg [WIO+WFO-1:0] a;
wire [WIO+WFO-1:0] b;
reg [WIDTH_I+WIDTH_F-1: WIDTH_F+WIO]temp;

always @(*) begin
    if(reset) begin
        temp_out=0;
        intpart=0;
        frcpart=0;
        temp=0;
     end

     else begin
        if(start) begin
            if ((WI1>=WI2) && (WF1>=WF2)) temp_out ={in1[WI1+WF1-1],in1}+{{((WI1-WI2)+1){in2[WI2+WF2-1]}},{in2},{(WF1-WF2){1'b0}}};
    
            if ((WI1>=WI2)&& (WF1<=WF2)) temp_out ={in1[WI1+WF1-1],in1,{(WF2-WF1){1'b0}}}+{{((WI1-WI2)+1){in2[WI2+WF2-1]}},{in2}};
    
            if ((WI1<=WI2)&&(WF1>=WF2)) temp_out = {{{((WI2-WI1)+1){in1[WI1+WF1-1]}},{in1}}}+ {{in2[WI2+WF2-1]},{in2},{(WF1-WF2){1'b0}}};
    
            if ((WI1<=WI2) &&(WF1<=WF2)) temp_out = {{{((WI2-WI1)+1){in1[WI1+WF1-1]}},{in1},{(WF2-WF1){1'b0}}}+ {in2[WI2+WF2-1],in2}};
        
            if (WIO>WIDTH_I+1)begin
            	intpart<={{(WIO-WIDTH_I){temp_out[WIDTH_I+WIDTH_F]}},{temp_out[WIDTH_I+WIDTH_F:WIDTH_F]}};
            	OVF<=0;
            end

            else if (WIO<WIDTH_I+1) begin
                intpart={{temp_out[WIDTH_I+WIDTH_F]},{temp_out[WIDTH_F+WIO-2:(WIDTH_F)]}};
                if (((WIDTH_I+1)-WIO)==1) begin
                     OVF=(temp_out[WIDTH_I+WIDTH_F-1]!=temp_out[WIDTH_I+WIDTH_F])?1:0;
                end

                else begin

                    if (in1[WI1+WF1-1]==in2[WI2+WF2-1]==(&(temp_out[WIDTH_I+WIDTH_F: WIDTH_F+WIO-1]))||(~in1[WI1+WF1-1]==~in2[WI2+WF2-1]==(|(temp_out[WIDTH_I+WIDTH_F: WIDTH_F+WIO-1])))) 			OVF<=0;

                    else OVF=1;
                end
            end

            else if (WIO==WIDTH_I+1) begin
                intpart={temp_out[WIDTH_I+WIDTH_F:WIDTH_F]};
                OVF=0;
            end

            if (WFO>(WIDTH_F)) frcpart={{temp_out[WIDTH_F-1:0]},{(WFO-WIDTH_F){1'b0}}};

            else if (WFO<(WIDTH_F))

            if(WFO>0)
                frcpart={temp_out[WIDTH_F-1:(WIDTH_F-WFO)]};
            else;

            else begin 
            	if(WFO>0) frcpart={temp_out[((WIDTH_F)-1):0]};
            end
        end
        else temp_out=temp_out;
    end
end

if(WFO>0)
	assign out={intpart,frcpart};   

else if(WFO==0)
	assign out={intpart}; 

endmodule
