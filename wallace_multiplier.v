`timescale 1ns / 1ps
module fa(input wire a,b,c,output wire s,output wire cout);
    assign s=a^b^c;
    assign cout=(a&b)|(b&c)|(a&c);
endmodule

module comp7to3(
    input wire x0,x1,x2,x3,x4,x5,x6,
    output wire sum,cout,cout1
);
    wire s01, c01,s23, c23,s2, c2,s3, c3;
    fa u01(.a(x0),.b(x1),.c(x2),.s(s01),.cout(c01));
    fa u23(.a(x3),.b(x4),.c(x5),.s(s23),.cout(c23));
    fa u2(.a(s01),.b(s23),.c(x6),.s(s2),.cout(c2));
    fa u3(.a(c01),.b(c23),.c(c2),.s(s3),.cout(c3));
    assign sum=s2;
    assign cout=s3;
    assign cout1=c3;
endmodule

module comp7to3array (
    input wire [31:0] x0,
    input wire [31:0] x1,
    input wire [31:0] x2,
    input wire [31:0] x3,
    input wire [31:0] x4,
    input wire [31:0] x5,
    input wire [31:0] x6,
    output wire [31:0] sumarr,
    output wire [31:0] coutarr,
    output wire [31:0] coutarr1
);
    genvar b;
    generate
        for (b=0; b<32; b=b+1) begin
            comp7to3 u (
                .x0(x0[b]),.x1(x1[b]),.x2(x2[b]),
                .x3(x3[b]),.x4(x4[b]),.x5(x5[b]),.x6(x6[b]),
                .sum(sumarr[b]),.cout(coutarr[b]),.cout1(coutarr1[b])
            );
        end
    endgenerate
endmodule


module comp3to2(
    input wire [31:0] x,
    input wire [31:0] y,
    input wire [31:0] z,
    output wire [31:0] s,
    output wire [31:0] cout
);
    assign s=x^y^z;
    assign cout=((x&y)|(x&z)|(y&z))<<1;
endmodule

module walllacetree (
    input wire clk,
    input wire rst,
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [31:0] product
);
    
    wire [31:0] pp [0:15];
    genvar r,k;
    generate
        for (r=0;r<16;r=r+1) begin
            for (k=0;k<32;k=k+1) begin
                if((k>=r)&&(k<r+16))
                    assign pp[r][k]=a[k-r]&b[r];
                else
                    assign pp[r][k]=1'b0;
            end
        end
    endgenerate

    wire [31:0] s0,c0,c02,s1,c1,c12;
    comp7to3array G0 (.x0(pp[0]),.x1(pp[1]),.x2(pp[2]),.x3(pp[3]),.x4(pp[4]),.x5(pp[5]),.x6(pp[6]),
                      .sumarr(s0),.coutarr(c0),.coutarr1(c02));
    comp7to3array G1 (.x0(pp[7]),.x1(pp[8]),.x2(pp[9]),.x3(pp[10]),.x4(pp[11]),.x5(pp[12]),.x6(pp[13]),
                      .sumarr(s1),.coutarr(c1),.coutarr1(c12));

    reg [31:0] s0reg,c0reg,c02reg,s1reg,c1reg,c12reg,pp14reg,pp15reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s0reg<=0;
            c0reg<=0;
            c02reg<=0;
            s1reg<=0;
            c1reg<=0;
            c12reg<=0;
            pp14reg<=0;
            pp15reg<=0;
        end else begin
            s0reg<=s0;
            c0reg<=c0;
            c02reg<=c02;
            s1reg<=s1;
            c1reg<=c1;
            c12reg<=c12;
            pp14reg<=pp[14];
            pp15reg<=pp[15];
        end
    end

    wire [31:0] c0s=c0reg<<1,c02s=c02reg<<2,c1s=c1reg<<1,c12s=c12reg<<2;
    wire [31:0] sumA,coutA,coutA2;
    comp7to3array G2 (.x0(s0reg),.x1(c0s),.x2(c02s),
                      .x3(s1reg),.x4(c1s),.x5(c12s),.x6(pp14reg),
                      .sumarr(sumA),.coutarr(coutA),.coutarr1(coutA2));

    reg [31:0] sumAreg,coutAreg,coutA2reg,pp15reg2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sumAreg<=0;
            coutAreg<=0;
            coutA2reg<=0;
            pp15reg2<=0;
        end else begin
            sumAreg<=sumA;
            coutAreg<=coutA;
            coutA2reg<=coutA2;
            pp15reg2<=pp15reg;
        end
    end

    wire [31:0] cAs=coutAreg<<1,cA2s=coutA2reg<<2;
    wire [31:0] sumx,coutx;
    comp3to2 C1 (.x(sumAreg),.y(cAs),.z(cA2s),.s(sumx),.cout(coutx));
    wire [31:0] sumy,couty;
    comp3to2 C2 (.x(sumx),.y(coutx),.z(pp15reg2),.s(sumy),.cout(couty));

    reg [31:0] sumyreg,coutyreg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sumyreg<=0;coutyreg<=0;
        end else begin
            sumyreg<=sumy;coutyreg<=couty;
        end
    end

    wire [31:0] finalsum;
    wire ex;
    han_carlson_add lastadd (
        .clk(clk),.rst(rst),
        .a(sumyreg),.b(coutyreg),
        .cin(1'b0),
        .sum(finalsum),.cout(ex)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            product<=0;
        else
            product<=finalsum;
    end
endmodule

module han_carlson_add(
    input wire clk,
    input wire rst,
    input wire [31:0] a,
    input wire [31:0] b,
    input wire cin,
    output reg [31:0] sum,
    output reg cout
);
    wire [31:0] p0=a^b;
    wire [31:0] g0=a&b;

    reg [31:0] g1r,g2r,g3r,g4r,g5r,p1r,p2r,p3r,p4r,p5r,pd1,pd2,pd3,pd4,pd5;
    reg cind1,cind2,cind3,cind4,cind5;
    wire [31:0] g1,p1;
    genvar i1;
    generate
        for (i1=0;i1<32;i1=i1+1) begin
            assign g1[i1]=(i1>=1)?(g0[i1]|(p0[i1]&g0[i1-1])):g0[i1];
            assign p1[i1]=(i1>=1)?(p0[i1]&p0[i1-1]):p0[i1];
        end
    endgenerate

    wire [31:0] g2,p2;
    genvar i2;
    generate
        for (i2=0;i2<32;i2=i2+1) begin
            assign g2[i2]=(i2>=2)?(g1r[i2]|(p1r[i2]&g1r[i2-2])):g1r[i2];
            assign p2[i2]=(i2>=2)?(p1r[i2]&p1r[i2-2]):p1r[i2];
        end
    endgenerate

    wire [31:0] g3,p3;
    genvar i3;
    generate
        for (i3=0;i3<32;i3=i3+1) begin
            assign g3[i3]=(i3>=4)?(g2r[i3]|(p2r[i3]&g2r[i3-4])):g2r[i3];
            assign p3[i3]= (i3>=4)?(p2r[i3]&p2r[i3-4]):p2r[i3];
        end
    endgenerate

    wire [31:0] g4,p4;
    genvar i4;
    generate
        for (i4=0;i4<32;i4=i4+1) begin
            assign g4[i4]=(i4>=8)?(g3r[i4]|(p3r[i4]&g3r[i4-8])):g3r[i4];
            assign p4[i4]=(i4>=8)?(p3r[i4]&p3r[i4-8]):p3r[i4];
        end
    endgenerate

    wire [31:0] g5,p5;
    genvar i5;
    generate
        for (i5=0;i5<32;i5=i5+1) begin
            assign g5[i5]=(i5>=16)?(g4r[i5]|(p4r[i5]&g4r[i5-16])):g4r[i5];
            assign p5[i5]=(i5>=16)?(p4r[i5]&p4r[i5-16]):p4r[i5];
        end
    endgenerate

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            g1r<=0;
            p1r<=0; 
            g2r<=0;
            p2r<=0; 
            g3r<=0;
            p3r<=0;
            g4r<=0;
            p4r<=0; 
            g5r<=0;
            p5r<=0;
            pd1<=0;
            pd2<=0;
            pd3<=0;
            pd4<=0;
            pd5<=0;
            cind1<=0;
            cind2<=0;
            cind3<=0;
            cind4<=0;
            cind5<=0;
        end else begin
            g1r<=g1; 
            p1r<=p1;
            g2r<=g2; 
            p2r<=p2;
            g3r<=g3; 
            p3r<=p3;
            g4r<=g4; 
            p4r<=p4;
            g5r<=g5; 
            p5r<=p5;
            pd1<=p0; 
            pd2<=pd1; 
            pd3<=pd2; 
            pd4<=pd3; 
            pd5<=pd4;
            cind1<=cin; 
            cind2<=cind1; 
            cind3<=cind2; 
            cind4<=cind3; 
            cind5<=cind4;
        end
    end

    wire [32:0] carry;
    assign carry[0]=cind5;
    genvar j;
    generate
        for (j=0;j<32;j=j+1) begin
            assign carry[j+1]=g5r[j]|(p5r[j]&carry[j]);
        end
    endgenerate

    wire [31:0] sum_w=pd5^carry[31:0];
    wire cout_w=carry[32];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum<=0;
            cout<=0;
        end else begin
            sum<=sum_w;
            cout<=cout_w;
        end
    end
endmodule
