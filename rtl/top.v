`define SIGNED_BIT   1
`define INT_BIT      5
`define FLOAT_BIT    8
                    
`define TOTAL_BIT    14

`include "PE.v"
`include "controller.v"
module top(
  input         clk_i,
  input         rst_ni,
  input [ 2:0]  PE_ARRAY_COL_i,
  input [ 4:0]  PE_COL_ROW_i,
  input [ 5:0]  WEIGHT_LOOP_i,
  input [ 5:0]  WEIGHT_IFMP_LOOP_i,
  input [10:0]  PE_ARRAY_FINISH_i,
  input [11:0]  PE_ARRAY_FINISH_SIZE_i,
  input [11:0]  PE_ARRAY_FINISH_SIZE_M_i,
  input [10:0]  THREE_ROW_WEIGHT_SIZE_i,
  input [13:0]  EIGHT_ROW_IFMAP_SIZE_i,
  input [ 3:0]  w_en,
  input [`TOTAL_BIT-1:0] weight0,
  input [`TOTAL_BIT-1:0] weight1,
  input [`TOTAL_BIT-1:0] weight2,
  input [`TOTAL_BIT-1:0] weight3,
  input [`TOTAL_BIT-1:0] weight4,
  input [`TOTAL_BIT-1:0] weight5,
  input [`TOTAL_BIT-1:0] weight6,
  input [`TOTAL_BIT-1:0] weight7,
  input [`TOTAL_BIT-1:0] weight8,
  input [`TOTAL_BIT-1:0] weight9,
  input [`TOTAL_BIT-1:0] weight10,
  input [`TOTAL_BIT-1:0] weight11,
  input [`TOTAL_BIT-1:0] weight12,
  input [`TOTAL_BIT-1:0] weight13,
  input [`TOTAL_BIT-1:0] weight14,
  input [`TOTAL_BIT-1:0] weight15,
  input [`TOTAL_BIT-1:0] ifmap0,
  input [`TOTAL_BIT-1:0] ifmap1,
  input [`TOTAL_BIT-1:0] ifmap2,
  input [`TOTAL_BIT-1:0] ifmap3,
  input [`TOTAL_BIT-1:0] ifmap4,
  input [`TOTAL_BIT-1:0] ifmap5,
  input [`TOTAL_BIT-1:0] ifmap6,
  input [`TOTAL_BIT-1:0] ifmap7,
  input [`TOTAL_BIT-1:0] ifmap8,
  input [`TOTAL_BIT-1:0] ifmap9,
  input [`TOTAL_BIT-1:0] ifmap10,
  input [`TOTAL_BIT-1:0] ifmap11,
  input [`TOTAL_BIT-1:0] ifmap12,
  input [`TOTAL_BIT-1:0] ifmap13,
  input [`TOTAL_BIT-1:0] ifmap14,
  input [`TOTAL_BIT-1:0] ifmap15,
  input signed [`TOTAL_BIT-1:0] add_i1,
  input signed [`TOTAL_BIT-1:0] add_i2,
  input signed [`TOTAL_BIT-1:0] add_i3,
  input signed [`TOTAL_BIT-1:0] add_i4,
  
  output reg  [`TOTAL_BIT-1:0] ofmap_o_0, ofmap_o_1, ofmap_o_2, ofmap_o_3,
  output reg        valid_o,
  output     [11:0] weight_index_o,
  output     [14:0] ifmap_index_o,
  output reg [12:0] write_addr_o,
  output     [12:0] read_addr_o,
  output reg        done_o,
  output [5:0] weight_ifmap_loop,
  output [10:0] counter
);
  
  wire signed  [`TOTAL_BIT-1:0] ofmap_o_0_temp, ofmap_o_1_temp, ofmap_o_2_temp, ofmap_o_3_temp;
  reg signed [`TOTAL_BIT-1:0] ofmap_o_0t, ofmap_o_1t, ofmap_o_2t, ofmap_o_3t;
  wire     [12:0] write_addr_o_temp;
  reg      [12:0] write_addr_o_temp1;
  wire            valid_o_temp;
  reg             valid_o_temp1;
  wire done_o_temp;
  reg signed [`TOTAL_BIT-1:0] max0;
  reg signed [`TOTAL_BIT-1:0] max1;
  reg signed [`TOTAL_BIT-1:0] max2;
  reg signed [`TOTAL_BIT-1:0] max3;
  
  always@(posedge clk_i)begin
    ofmap_o_0    <= (weight_ifmap_loop==WEIGHT_IFMP_LOOP_i&&PE_ARRAY_FINISH_i!=11'd5)?max0:ofmap_o_0t;
    ofmap_o_1    <= (weight_ifmap_loop==WEIGHT_IFMP_LOOP_i&&PE_ARRAY_FINISH_i!=11'd5)?max1:ofmap_o_1t;
    ofmap_o_2    <= (weight_ifmap_loop==WEIGHT_IFMP_LOOP_i&&PE_ARRAY_FINISH_i!=11'd5)?max2:ofmap_o_2t;
    ofmap_o_3    <= (weight_ifmap_loop==WEIGHT_IFMP_LOOP_i&&PE_ARRAY_FINISH_i!=11'd5)?max3:ofmap_o_3t;
    valid_o      <= valid_o_temp1;
    write_addr_o <= write_addr_o_temp1;
    done_o       <= done_o_temp;
  end
  
  always@(posedge clk_i)begin
    if(counter[1:0]==2'b01)begin
      max0 <= ofmap_o_0_temp;
      max1 <= ofmap_o_1_temp;
      max2 <= ofmap_o_2_temp;
      max3 <= ofmap_o_3_temp;
    end else begin
      max0 <= (ofmap_o_0_temp>max0)?ofmap_o_0_temp:max0;
      max1 <= (ofmap_o_1_temp>max1)?ofmap_o_1_temp:max1;
      max2 <= (ofmap_o_2_temp>max2)?ofmap_o_2_temp:max2;
      max3 <= (ofmap_o_3_temp>max3)?ofmap_o_3_temp:max3;
    end
  end
  
  reg [`TOTAL_BIT-1:0] ifmap0_reg;
  reg [`TOTAL_BIT-1:0] ifmap1_reg;
  reg [`TOTAL_BIT-1:0] ifmap2_reg;
  reg [`TOTAL_BIT-1:0] ifmap3_reg;
  reg [`TOTAL_BIT-1:0] ifmap4_reg;
  reg [`TOTAL_BIT-1:0] ifmap5_reg;
  reg [`TOTAL_BIT-1:0] ifmap6_reg;
  reg [`TOTAL_BIT-1:0] ifmap7_reg;
  reg [`TOTAL_BIT-1:0] ifmap8_reg;
  reg [`TOTAL_BIT-1:0] ifmap9_reg;
  reg [`TOTAL_BIT-1:0] ifmap10_reg;
  reg [`TOTAL_BIT-1:0] ifmap11_reg;
  reg [`TOTAL_BIT-1:0] ifmap12_reg;
  reg [`TOTAL_BIT-1:0] ifmap13_reg;
  reg [`TOTAL_BIT-1:0] ifmap14_reg;
  reg [`TOTAL_BIT-1:0] ifmap15_reg;
  always@(posedge clk_i)begin
    ifmap0_reg  <= ifmap0;
    ifmap1_reg  <= ifmap1;
    ifmap2_reg  <= ifmap2;
    ifmap3_reg  <= ifmap3;
    ifmap4_reg  <= ifmap4;
    ifmap5_reg  <= ifmap5;
    ifmap6_reg  <= ifmap6;
    ifmap7_reg  <= ifmap7;
    ifmap8_reg  <= ifmap8;
    ifmap9_reg  <= ifmap9;
    ifmap10_reg <= ifmap10;
    ifmap11_reg <= ifmap11;
    ifmap12_reg <= ifmap12;
    ifmap13_reg <= ifmap13;
    ifmap14_reg <= ifmap14;
    ifmap15_reg <= ifmap15;
  end
  
  always@(posedge clk_i)begin
    ofmap_o_0t         <= ofmap_o_0_temp;
    ofmap_o_1t         <= ofmap_o_1_temp;
    ofmap_o_2t         <= ofmap_o_2_temp;
    ofmap_o_3t         <= ofmap_o_3_temp;
    valid_o_temp1      <= valid_o_temp;
    write_addr_o_temp1 <= write_addr_o_temp;
  end
  
  wire signed [`TOTAL_BIT-1:0] ofmap_temp_0, ofmap_temp_1, ofmap_temp_2, ofmap_temp_3, ofmap_temp_4, ofmap_temp_5,
                               ofmap_temp_6, ofmap_temp_7, ofmap_temp_8, ofmap_temp_9, ofmap_temp_10, ofmap_temp_11,
                               ofmap_temp_12, ofmap_temp_13, ofmap_temp_14, ofmap_temp_15,
                               ofmap_temp_16, ofmap_temp_17, ofmap_temp_18, ofmap_temp_19;
                               
  wire signed [`TOTAL_BIT-1:0] ofmap_0,  ofmap_1,  ofmap_2,  ofmap_4,  ofmap_5,  ofmap_6,
                               ofmap_8,  ofmap_9,  ofmap_10, ofmap_12, ofmap_13, ofmap_14,
                               ofmap_16, ofmap_17, ofmap_18, ofmap_20, ofmap_21, ofmap_22,
                               ofmap_24, ofmap_25, ofmap_26, ofmap_28, ofmap_29, ofmap_30,
                               ofmap_32, ofmap_33, ofmap_34, ofmap_36, ofmap_37, ofmap_38,
                               ofmap_40, ofmap_41, ofmap_42, ofmap_44, ofmap_45, ofmap_46,
                               ofmap_48, ofmap_49, ofmap_50, ofmap_52, ofmap_53, ofmap_54,
                               ofmap_56, ofmap_57, ofmap_58, ofmap_60, ofmap_61, ofmap_62;
  
  assign ofmap_o_0_temp = (ofmap_temp_16[`TOTAL_BIT-1]&&weight_ifmap_loop==WEIGHT_IFMP_LOOP_i)?$signed(`TOTAL_BIT'd0):$signed(ofmap_temp_16);
  assign ofmap_o_1_temp = (ofmap_temp_17[`TOTAL_BIT-1]&&weight_ifmap_loop==WEIGHT_IFMP_LOOP_i)?$signed(`TOTAL_BIT'd0):$signed(ofmap_temp_17);
  assign ofmap_o_2_temp = (ofmap_temp_18[`TOTAL_BIT-1]&&weight_ifmap_loop==WEIGHT_IFMP_LOOP_i)?$signed(`TOTAL_BIT'd0):$signed(ofmap_temp_18);
  assign ofmap_o_3_temp = (ofmap_temp_19[`TOTAL_BIT-1]&&weight_ifmap_loop==WEIGHT_IFMP_LOOP_i)?$signed(`TOTAL_BIT'd0):$signed(ofmap_temp_19);
  
  assign ofmap_temp_16 = (ofmap_temp_0 + ofmap_temp_4) + (ofmap_temp_8  + ofmap_temp_12);
  assign ofmap_temp_17 = (ofmap_temp_1 + ofmap_temp_5) + (ofmap_temp_9  + ofmap_temp_13);
  assign ofmap_temp_18 = (ofmap_temp_2 + ofmap_temp_6) + (ofmap_temp_10 + ofmap_temp_14);
  assign ofmap_temp_19 = (ofmap_temp_3 + ofmap_temp_7) + (ofmap_temp_11 + ofmap_temp_15);
  
  controller controller(.clk_i                  (clk_i),
                        .rst_ni                 (rst_ni),
                        .PE_ARRAY_COL_i         (PE_ARRAY_COL_i),
                        .PE_COL_ROW_i           (PE_COL_ROW_i),
                        .WEIGHT_LOOP_i          (WEIGHT_LOOP_i),
                        .WEIGHT_IFMP_LOOP_i     (WEIGHT_IFMP_LOOP_i),
                        .PE_ARRAY_FINISH_i      (PE_ARRAY_FINISH_i),
                        .PE_ARRAY_FINISH_SIZE_i (PE_ARRAY_FINISH_SIZE_i),
                        .PE_ARRAY_FINISH_SIZE_M_i (PE_ARRAY_FINISH_SIZE_M_i),
                        .THREE_ROW_WEIGHT_SIZE_i(THREE_ROW_WEIGHT_SIZE_i),
                        .EIGHT_ROW_IFMAP_SIZE_i (EIGHT_ROW_IFMAP_SIZE_i),
                        .valid_o                (valid_o_temp),
                        .weight_ifmap_loop      (weight_ifmap_loop),
                        .weight_index_o         (weight_index_o),
                        .ifmap_index_o          (ifmap_index_o),
                        .write_addr_o           (write_addr_o_temp),
                        .read_addr_o            (read_addr_o),
                        .done_o                 (done_o_temp),
                        .counter                (counter));
  
  /////////////////////////////////////first PE array/////////////////////////////////////
  wire signed [`TOTAL_BIT-1:0] psum0 = (weight_ifmap_loop>1)?$signed(add_i1):$signed(`TOTAL_BIT'd0);
  wire signed [`TOTAL_BIT-1:0] psum1 = (weight_ifmap_loop>1)?$signed(add_i2):$signed(`TOTAL_BIT'd0);
  wire signed [`TOTAL_BIT-1:0] psum2 = (weight_ifmap_loop>1)?$signed(add_i3):$signed(`TOTAL_BIT'd0);
  wire signed [`TOTAL_BIT-1:0] psum3 = (weight_ifmap_loop>1)?$signed(add_i4):$signed(`TOTAL_BIT'd0);
  
  PE PE0(.clk_i    (clk_i),
         .weight_en(w_en[0]),
         .weight_i ($signed(weight0)),
         .ifmap_i  ($signed(ifmap0_reg)),
         .psum_i   (psum0),
         .ofmap_o  (ofmap_0));
  
  PE PE1(.clk_i    (clk_i),
         .weight_en(w_en[1]),
         .weight_i ($signed(weight0)),
         .ifmap_i  ($signed(ifmap1_reg)),
         .psum_i   (ofmap_0),
         .ofmap_o  (ofmap_1));
  
  PE PE2(.clk_i    (clk_i),
         .weight_en(w_en[2]),
         .weight_i ($signed(weight0)),
         .ifmap_i  ($signed(ifmap2_reg)),
         .psum_i   (ofmap_1),
         .ofmap_o  (ofmap_2));
  
  PE PE3(.clk_i    (clk_i),
         .weight_en(w_en[3]),
         .weight_i ($signed(weight0)),
         .ifmap_i  ($signed(ifmap3_reg)),
         .psum_i   (ofmap_2),
         .ofmap_o  (ofmap_temp_0));
  
  PE PE4(.clk_i    (clk_i),
         .weight_en(w_en[0]),
         .weight_i ($signed(weight1)),
         .ifmap_i  ($signed(ifmap0_reg)),
         .psum_i   (psum1),
         .ofmap_o  (ofmap_4));
  
  PE PE5(.clk_i    (clk_i),
         .weight_en(w_en[1]),
         .weight_i ($signed(weight1)),
         .ifmap_i  ($signed(ifmap1_reg)),
         .psum_i   (ofmap_4),
         .ofmap_o  (ofmap_5));
  
  PE PE6(.clk_i    (clk_i),
         .weight_en(w_en[2]),
         .weight_i ($signed(weight1)),
         .ifmap_i  ($signed(ifmap2_reg)),
         .psum_i   (ofmap_5),
         .ofmap_o  (ofmap_6));
  
  PE PE7(.clk_i    (clk_i),
         .weight_en(w_en[3]),
         .weight_i ($signed(weight1)),
         .ifmap_i  ($signed(ifmap3_reg)),
         .psum_i   (ofmap_6),
         .ofmap_o  (ofmap_temp_1));
  
  PE PE8(.clk_i    (clk_i),
         .weight_en(w_en[0]),
         .weight_i ($signed(weight2)),
         .ifmap_i  ($signed(ifmap0_reg)),
         .psum_i   (psum2),
         .ofmap_o  (ofmap_8));
  
  PE PE9(.clk_i    (clk_i),
         .weight_en(w_en[1]),
         .weight_i ($signed(weight2)),
         .ifmap_i  ($signed(ifmap1_reg)),
         .psum_i   (ofmap_8),
         .ofmap_o  (ofmap_9));
  
  PE PE10(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight2)),
          .ifmap_i  ($signed(ifmap2_reg)),
          .psum_i   (ofmap_9),
          .ofmap_o  (ofmap_10));
  
  PE PE11(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight2)),
          .ifmap_i  ($signed(ifmap3_reg)),
          .psum_i   (ofmap_10),
          .ofmap_o  (ofmap_temp_2));
  
  PE PE12(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight3)),
          .ifmap_i  ($signed(ifmap0_reg)),
          .psum_i   (psum3),
          .ofmap_o  (ofmap_12));
  
  PE PE13(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight3)),
          .ifmap_i  ($signed(ifmap1_reg)),
          .psum_i   (ofmap_12),
          .ofmap_o  (ofmap_13));
  
  PE PE14(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight3)),
          .ifmap_i  ($signed(ifmap2_reg)),
          .psum_i   (ofmap_13),
          .ofmap_o  (ofmap_14));
  
  PE PE15(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight3)),
          .ifmap_i  ($signed(ifmap3_reg)),
          .psum_i   (ofmap_14),
          .ofmap_o  (ofmap_temp_3));
  
  /////////////////////////////////////second PE array/////////////////////////////////////
  PE PE16(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight4)),
          .ifmap_i  ($signed(ifmap4_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_16));
  
  PE PE17(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight4)),
          .ifmap_i  ($signed(ifmap5_reg)),
          .psum_i   (ofmap_16),
          .ofmap_o  (ofmap_17));
  
  PE PE18(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight4)),
          .ifmap_i  ($signed(ifmap6_reg)),
          .psum_i   (ofmap_17),
          .ofmap_o  (ofmap_18));
  
  PE PE19(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight4)),
          .ifmap_i  ($signed(ifmap7_reg)),
          .psum_i   (ofmap_18),
          .ofmap_o  (ofmap_temp_4));
  
  PE PE20(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight5)),
          .ifmap_i  ($signed(ifmap4_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_20));
  
  PE PE21(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight5)),
          .ifmap_i  ($signed(ifmap5_reg)),
          .psum_i   (ofmap_20),
          .ofmap_o  (ofmap_21));
  
  PE PE22(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight5)),
          .ifmap_i  ($signed(ifmap6_reg)),
          .psum_i   (ofmap_21),
          .ofmap_o  (ofmap_22));
  
  PE PE23(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight5)),
          .ifmap_i  ($signed(ifmap7_reg)),
          .psum_i   (ofmap_22),
          .ofmap_o  (ofmap_temp_5));
  
  PE PE24(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight6)),
          .ifmap_i  ($signed(ifmap4_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_24));
  
  PE PE25(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight6)),
          .ifmap_i  ($signed(ifmap5_reg)),
          .psum_i   (ofmap_24),
          .ofmap_o  (ofmap_25));
  
  PE PE26(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight6)),
          .ifmap_i  ($signed(ifmap6_reg)),
          .psum_i   (ofmap_25),
          .ofmap_o  (ofmap_26));
  
  PE PE27(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight6)),
          .ifmap_i  ($signed(ifmap7_reg)),
          .psum_i   (ofmap_26),
          .ofmap_o  (ofmap_temp_6));
  
  PE PE28(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight7)),
          .ifmap_i  ($signed(ifmap4_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_28));
  
  PE PE29(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight7)),
          .ifmap_i  ($signed(ifmap5_reg)),
          .psum_i   (ofmap_28),
          .ofmap_o  (ofmap_29));
  
  PE PE30(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight7)),
          .ifmap_i  ($signed(ifmap6_reg)),
          .psum_i   (ofmap_29),
          .ofmap_o  (ofmap_30));
  
  PE PE31(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight7)),
          .ifmap_i  ($signed(ifmap7_reg)),
          .psum_i   (ofmap_30),
          .ofmap_o  (ofmap_temp_7));
  
  /////////////////////////////////////third PE array/////////////////////////////////////
  PE PE32(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight8)),
          .ifmap_i  ($signed(ifmap8_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_32));
  
  PE PE33(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight8)),
          .ifmap_i  ($signed(ifmap9_reg)),
          .psum_i   (ofmap_32),
          .ofmap_o  (ofmap_33));
  
  PE PE34(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight8)),
          .ifmap_i  ($signed(ifmap10_reg)),
          .psum_i   (ofmap_33),
          .ofmap_o  (ofmap_34));
  
  PE PE35(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight8)),
          .ifmap_i  ($signed(ifmap11_reg)),
          .psum_i   (ofmap_34),
          .ofmap_o  (ofmap_temp_8));
  
  PE PE36(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight9)),
          .ifmap_i  ($signed(ifmap8_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_36));
  
  PE PE37(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight9)),
          .ifmap_i  ($signed(ifmap9_reg)),
          .psum_i   (ofmap_36),
          .ofmap_o  (ofmap_37));
  
  PE PE38(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight9)),
          .ifmap_i  ($signed(ifmap10_reg)),
          .psum_i   (ofmap_37),
          .ofmap_o  (ofmap_38));
  
  PE PE39(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight9)),
          .ifmap_i  ($signed(ifmap11_reg)),
          .psum_i   (ofmap_38),
          .ofmap_o  (ofmap_temp_9));
  
  PE PE40(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight10)),
          .ifmap_i  ($signed(ifmap8_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_40));
  
  PE PE41(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight10)),
          .ifmap_i  ($signed(ifmap9_reg)),
          .psum_i   (ofmap_40),
          .ofmap_o  (ofmap_41));
  
  PE PE42(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight10)),
          .ifmap_i  ($signed(ifmap10_reg)),
          .psum_i   (ofmap_41),
          .ofmap_o  (ofmap_42));
  
  PE PE43(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight10)),
          .ifmap_i  ($signed(ifmap11_reg)),
          .psum_i   (ofmap_42),
          .ofmap_o  (ofmap_temp_10));
  
  PE PE44(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight11)),
          .ifmap_i  ($signed(ifmap8_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_44));
  
  PE PE45(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight11)),
          .ifmap_i  ($signed(ifmap9_reg)),
          .psum_i   (ofmap_44),
          .ofmap_o  (ofmap_45));
  
  PE PE46(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight11)),
          .ifmap_i  ($signed(ifmap10_reg)),
          .psum_i   (ofmap_45),
          .ofmap_o  (ofmap_46));
  
  PE PE47(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight11)),
          .ifmap_i  ($signed(ifmap11_reg)),
          .psum_i   (ofmap_46),
          .ofmap_o  (ofmap_temp_11));
  
  /////////////////////////////////////forth PE array/////////////////////////////////////
  PE PE48(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight12)),
          .ifmap_i  ($signed(ifmap12_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_48));
  
  PE PE49(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight12)),
          .ifmap_i  ($signed(ifmap13_reg)),
          .psum_i   (ofmap_48),
          .ofmap_o  (ofmap_49));
  
  PE PE50(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight12)),
          .ifmap_i  ($signed(ifmap14_reg)),
          .psum_i   (ofmap_49),
          .ofmap_o  (ofmap_50));
  
  PE PE51(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight12)),
          .ifmap_i  ($signed(ifmap15_reg)),
          .psum_i   (ofmap_50),
          .ofmap_o  (ofmap_temp_12));
  
  PE PE52(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight13)),
          .ifmap_i  ($signed(ifmap12_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_52));
  
  PE PE53(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight13)),
          .ifmap_i  ($signed(ifmap13_reg)),
          .psum_i   (ofmap_52),
          .ofmap_o  (ofmap_53));
  
  PE PE54(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight13)),
          .ifmap_i  ($signed(ifmap14_reg)),
          .psum_i   (ofmap_53),
          .ofmap_o  (ofmap_54));
  
  PE PE55(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight13)),
          .ifmap_i  ($signed(ifmap15_reg)),
          .psum_i   (ofmap_54),
          .ofmap_o  (ofmap_temp_13));
  
  PE PE56(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight14)),
          .ifmap_i  ($signed(ifmap12_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_56));
  
  PE PE57(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight14)),
          .ifmap_i  ($signed(ifmap13_reg)),
          .psum_i   (ofmap_56),
          .ofmap_o  (ofmap_57));
  
  PE PE58(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight14)),
          .ifmap_i  ($signed(ifmap14_reg)),
          .psum_i   (ofmap_57),
          .ofmap_o  (ofmap_58));
  
  PE PE59(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight14)),
          .ifmap_i  ($signed(ifmap15_reg)),
          .psum_i   (ofmap_58),
          .ofmap_o  (ofmap_temp_14));
  
  PE PE60(.clk_i    (clk_i),
          .weight_en(w_en[0]),
          .weight_i ($signed(weight15)),
          .ifmap_i  ($signed(ifmap12_reg)),
          .psum_i   ($signed(`TOTAL_BIT'd0)),
          .ofmap_o  (ofmap_60));
  
  PE PE61(.clk_i    (clk_i),
          .weight_en(w_en[1]),
          .weight_i ($signed(weight15)),
          .ifmap_i  ($signed(ifmap13_reg)),
          .psum_i   (ofmap_60),
          .ofmap_o  (ofmap_61));
  
  PE PE62(.clk_i    (clk_i),
          .weight_en(w_en[2]),
          .weight_i ($signed(weight15)),
          .ifmap_i  ($signed(ifmap14_reg)),
          .psum_i   (ofmap_61),
          .ofmap_o  (ofmap_62));
  
  PE PE63(.clk_i    (clk_i),
          .weight_en(w_en[3]),
          .weight_i ($signed(weight15)),
          .ifmap_i  ($signed(ifmap15_reg)),
          .psum_i   (ofmap_62),
          .ofmap_o  (ofmap_temp_15));
  
endmodule
