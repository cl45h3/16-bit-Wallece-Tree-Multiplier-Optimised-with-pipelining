module mult2x2 (input [1:0]a,input[1:0] b,output [3:0] out);
    wire [3:0] p0,p1,p2,p3;

    assign p0=a[0]&b[0];
    assign p1=(a[1]&b[0])<<1;
    assign p2=(a[0]&b[1])<<1;
    assign p3=(a[1]&b[1])<<2;

    assign out=p0+p1+p2+p3;
endmodule
module mult4x4(input [3:0] a,input [3:0] b,output [7:0] out);
    wire [3:0] p0,p1,p2,p3;
    wire [7:0] mid_sum,p3_2;
    wire [1:0] a_high,a_low,b_high,b_low;
    assign a_high=a[3:2];
    assign a_low=a[1:0];
    assign b_high=b[3:2];
    assign b_low=b[1:0];

    mult2x2 m1(a_low,b_low,p0);
    mult2x2 m2(a_high,b_low,p1);
    mult2x2 m3(a_low,b_high,p2);
    mult2x2 m4(a_high,b_high,p3);

    assign mid_sum=p1+p2;
    assign p3_2=p3;
    assign out=p0+(mid_sum<<2)+(p3_2<<4);
endmodule
module mult8x8 (input [7:0] a,input [7:0] b,output [15:0] out);
    wire [7:0] p0,p1,p2,p3;
    wire [15:0] mid_sum,p3_2;
    wire [3:0] a_high,a_low,b_high,b_low;
    assign a_high=a[7:4];
    assign a_low=a[3:0];
    assign b_high=b[7:4];
    assign b_low=b[3:0];

    mult4x4 m1(a_low,b_low,p0);
    mult4x4 m2(a_high,b_low,p1);
    mult4x4 m3(a_low,b_high,p2);
    mult4x4 m4(a_high,b_high,p3);

    assign mid_sum=p1+p2;
    assign p3_2=p3;
    assign out=p0+(mid_sum<<4)+(p3_2<<8);
endmodule
module mult16x16 (input [15:0] a,input [15:0] b,output [31:0] out);
    wire [15:0] p0,p1,p2,p3;
    wire [31:0] mid_sum,p3_2;
    wire [7:0] a_high,a_low,b_high,b_low;
    assign a_high=a[15:8];
    assign a_low=a[7:0];
    assign b_high=b[15:8];
    assign b_low=b[7:0];

    mult8x8 m1(a_low,b_low,p0);
    mult8x8 m2(a_high,b_low,p1);
    mult8x8 m3(a_low,b_high,p2);
    mult8x8 m4(a_high,b_high,p3);

    assign mid_sum=p1+p2;
    assign p3_2=p3;

    assign out=p0+(mid_sum<<8)+(p3_2<<16);
endmodule




    
