`timescale 1ns/100ps

`define CYCLE  20
`define SIGNED_BIT   1
`define INT_BIT      5
`define FLOAT_BIT    8
                    
`define TOTAL_BIT    14

`ifdef GSIM
    `define SDFFILE     "./top_syn.sdf"   //Modify your sdf file name
`elsif POST
    `define SDFFILE     "./top_pr.sdf" //Modify your sdf file name
`endif

//`include "top.v"

module top_tb;
  /////////////////////////////one PE array size, total two PE array, one PE cube///////////////////
  parameter PE_ARRAY_ROW = 4;
  parameter PE_ARRAY_COL = 4;

  ////////////////////////////one PE cube to handle matrix size//////////////////////
  parameter PE_WEIGHT_ROW =  4;
  parameter PE_COL_ROW    = 16;
  //parameter PE_IFMAP_COL  = 3;

  ///////////////////////////to be compute matrix size//////////////////////
  ///////////////////////////all could be modified/////////////////////////
  //parameter W_ROW         =  12;// 12;//12;//   6;
  //parameter W_COL         = 192;//192;//96;//  16;
  //parameter X_ROW         = 192;//192;//96;//  16;
  //parameter X_COL         =   1;//  1;//81;// 625;
  
  reg [3:0] W_ROW;
  reg [8:0] W_COL;
  reg [8:0] X_ROW;
  reg [10:0] X_COL;
  reg [10:0] M_X_COL;
  
  wire [11:0] FINAL_ADDR_REG = W_ROW * X_COL;//10  //972  //3750, 12bits
  
  wire [2:0] PE_ARRAY_COL_REG = PE_ARRAY_COL;//4, 3bits
  wire [4:0] PE_COL_ROW_REG = PE_COL_ROW;//16, 5bits
  wire [5:0] WEIGHT_LOOP_REG      = W_ROW / PE_WEIGHT_ROW;//4  //4, 3bits  //2, 2bits
  wire [5:0] WEIGHT_IFMP_LOOP_REG = W_COL / PE_COL_ROW;//24  //12, 4bits  //2, 2bits
  
  wire [10:0]  PE_ARRAY_FINISH_REG  = PE_ARRAY_COL + X_COL;//5  //85  //629, 10bits
  wire [11:0]  PE_ARRAY_FINISH_SIZE_REG = PE_WEIGHT_ROW * X_COL;//3  //243  //1875, 12bits
  wire [11:0]  PE_ARRAY_FINISH_SIZE_M_REG = PE_WEIGHT_ROW * M_X_COL;//3  //243  //1875, 12bits
  
  wire [10:0] THREE_ROW_WEIGHT_SIZE_REG = PE_WEIGHT_ROW * W_COL;//576  //288, 9bits //48, 6bits
  wire [13:0] EIGHT_ROW_IFMAP_SIZE_REG = PE_COL_ROW * X_COL;//8  //648  //5000, 13bits

  reg clk;
  reg rst;
  reg [5:0] w_en = 6'b000001;
  
  reg signed [`TOTAL_BIT-1:0] ifmap0;
  reg signed [`TOTAL_BIT-1:0] ifmap1;
  reg signed [`TOTAL_BIT-1:0] ifmap2;
  reg signed [`TOTAL_BIT-1:0] ifmap3;
  reg signed [`TOTAL_BIT-1:0] ifmap4;
  reg signed [`TOTAL_BIT-1:0] ifmap5;
  reg signed [`TOTAL_BIT-1:0] ifmap6;
  reg signed [`TOTAL_BIT-1:0] ifmap7;
  reg signed [`TOTAL_BIT-1:0] ifmap8;
  reg signed [`TOTAL_BIT-1:0] ifmap9;
  reg signed [`TOTAL_BIT-1:0] ifmap10;
  reg signed [`TOTAL_BIT-1:0] ifmap11;
  reg signed [`TOTAL_BIT-1:0] ifmap12;
  reg signed [`TOTAL_BIT-1:0] ifmap13;
  reg signed [`TOTAL_BIT-1:0] ifmap14;
  reg signed [`TOTAL_BIT-1:0] ifmap15;
  
  reg signed [`TOTAL_BIT-1:0] weight0;
  reg signed [`TOTAL_BIT-1:0] weight1;
  reg signed [`TOTAL_BIT-1:0] weight2;
  reg signed [`TOTAL_BIT-1:0] weight3;
  reg signed [`TOTAL_BIT-1:0] weight4;
  reg signed [`TOTAL_BIT-1:0] weight5;
  reg signed [`TOTAL_BIT-1:0] weight6;
  reg signed [`TOTAL_BIT-1:0] weight7;
  reg signed [`TOTAL_BIT-1:0] weight8;
  reg signed [`TOTAL_BIT-1:0] weight9;
  reg signed [`TOTAL_BIT-1:0] weight10;
  reg signed [`TOTAL_BIT-1:0] weight11;
  reg signed [`TOTAL_BIT-1:0] weight12;
  reg signed [`TOTAL_BIT-1:0] weight13;
  reg signed [`TOTAL_BIT-1:0] weight14;
  reg signed [`TOTAL_BIT-1:0] weight15;
  
  wire signed [`TOTAL_BIT-1:0] ofmap0;
  wire signed [`TOTAL_BIT-1:0] ofmap1;
  wire signed [`TOTAL_BIT-1:0] ofmap2;
  wire signed [`TOTAL_BIT-1:0] ofmap3;
  
  reg signed [`TOTAL_BIT-1:0] add_i1;
  reg signed [`TOTAL_BIT-1:0] add_i2;
  reg signed [`TOTAL_BIT-1:0] add_i3;
  reg signed [`TOTAL_BIT-1:0] add_i4;
  
  wire valid;
  wire [11:0] index_for_PE_weight;
  wire [14:0] index_for_PE_ifmap;
  wire [12:0] write_addr;
  wire [12:0] read_addr;
  wire done;
  wire [5:0] weight_ifmap_loop;
  wire [10:0] counter;
  
  top top(.clk_i                   (clk),
          .rst_ni                  (rst),
          .PE_ARRAY_COL_i          (PE_ARRAY_COL_REG),
          .PE_COL_ROW_i            (PE_COL_ROW_REG),
          .WEIGHT_LOOP_i           (WEIGHT_LOOP_REG),
          .WEIGHT_IFMP_LOOP_i      (WEIGHT_IFMP_LOOP_REG),
          .PE_ARRAY_FINISH_i       (PE_ARRAY_FINISH_REG),
          .PE_ARRAY_FINISH_SIZE_i  (PE_ARRAY_FINISH_SIZE_REG),
          .PE_ARRAY_FINISH_SIZE_M_i(PE_ARRAY_FINISH_SIZE_M_REG),
          .THREE_ROW_WEIGHT_SIZE_i (THREE_ROW_WEIGHT_SIZE_REG),
          .EIGHT_ROW_IFMAP_SIZE_i  (EIGHT_ROW_IFMAP_SIZE_REG),
          .w_en                    (w_en[5:2]),
          .weight0                 (weight0 ),
          .weight1                 (weight1 ),
          .weight2                 (weight2 ),
          .weight3                 (weight3 ),
          .weight4                 (weight4 ),
          .weight5                 (weight5 ),
          .weight6                 (weight6 ),
          .weight7                 (weight7 ),
          .weight8                 (weight8 ),
          .weight9                 (weight9 ),
          .weight10                (weight10),
          .weight11                (weight11),
          .weight12                (weight12),
          .weight13                (weight13),
          .weight14                (weight14),
          .weight15                (weight15),
          .ifmap0                  (ifmap0 ),
          .ifmap1                  (ifmap1 ),
          .ifmap2                  (ifmap2 ),
          .ifmap3                  (ifmap3 ),
          .ifmap4                  (ifmap4 ),
          .ifmap5                  (ifmap5 ),
          .ifmap6                  (ifmap6 ),
          .ifmap7                  (ifmap7 ),
          .ifmap8                  (ifmap8 ),
          .ifmap9                  (ifmap9 ),
          .ifmap10                 (ifmap10),
          .ifmap11                 (ifmap11),
          .ifmap12                 (ifmap12),
          .ifmap13                 (ifmap13),
          .ifmap14                 (ifmap14),
          .ifmap15                 (ifmap15),
          .add_i1                  (add_i1),
          .add_i2                  (add_i2),
          .add_i3                  (add_i3),
          .add_i4                  (add_i4),
          .ofmap_o_0               (ofmap0),
          .ofmap_o_1               (ofmap1),
          .ofmap_o_2               (ofmap2),
          .ofmap_o_3               (ofmap3),
          .valid_o                 (valid),
          .weight_index_o          (index_for_PE_weight),
          .ifmap_index_o           (index_for_PE_ifmap),
          .write_addr_o            (write_addr),
          .read_addr_o             (read_addr),
          .done_o                  (done),
          .weight_ifmap_loop       (weight_ifmap_loop),
          .counter                 (counter));
  
  always #(`CYCLE/2) clk = ~clk;
  /*
  initial begin
    $fsdbDumpfile("top_post.fsdb");
    $fsdbDumpvars(0,top_tb,"+mda"); //This command is for dumping 2D array
    $fsdbDumpvars;
    //$dumpfile("top.vcd");
    //$dumpvars;
  end
  */
  always@(negedge clk)begin
    if(done)begin
      w_en <= 6'b000010;
    end else if(w_en==6'd0)begin
      @(posedge clk)begin
        w_en <= (counter==X_COL+5)?6'b000010:w_en;
      end
    end else begin
      w_en <= w_en << 1;
    end
  end
  
  reg signed [`TOTAL_BIT-1:0] WEIGHT_MEM [0:2352-1];
  reg signed [`TOTAL_BIT-1:0] IFMAP_MEM_t [0:10000-1];
  reg signed [`TOTAL_BIT-1:0] IFMAP_MEM [0:10000-1];
  reg signed [`TOTAL_BIT-1:0] MAX_MEM [0:864-1];
  reg signed [`TOTAL_BIT-1:0] RAM [0:3750-1];
  reg signed [3:0] GOLDEN [0:199];
  
  reg [`TOTAL_BIT-1:0] max_t1;
  reg [`TOTAL_BIT-1:0] max_t2;
  reg [`TOTAL_BIT-1:0] max;
  reg [3:0] index;
  integer i1, i, j, k, fp_w, fw, addr, temp, count;
  
  `ifdef SDF
     initial       $sdf_annotate(`SDFFILE, top);
  `endif
  
  initial begin
  count = 0;
  clk = 1'b0;
  rst = 1'b1;
  $readmemh("../golden/golden.txt", GOLDEN);
  while(count<=199)begin
    $readmemb("../signed_bin_data/cnn1_wb.txt", WEIGHT_MEM);
    $readmemb($sformatf("../signed_bin_data/image_wb_%0d.txt", count), MAX_MEM);
    ///////////////////////////////////////im2col/////////////////////////////////////////
    k = 0;
    addr = -1;
    temp = -1;
    for(i=0;i<16;i=i+1)begin
      if(i%4==0 && i!=0) temp = temp + 25;
      else temp = temp + 1;
      addr = temp;
      for(j=1;j<626;j=j+1)begin
        IFMAP_MEM_t[k] = MAX_MEM[addr];
        k = k + 1;
        if(j%25==0 && j!=0) addr = addr + 4;
        else addr = addr + 1;
      end
    end
    
    for(i=0;i<16;i=i+1)begin
      IFMAP_MEM[i*625+0  ] = IFMAP_MEM_t[i*625+0  ];
      IFMAP_MEM[i*625+1  ] = IFMAP_MEM_t[i*625+1  ];
      IFMAP_MEM[i*625+2  ] = IFMAP_MEM_t[i*625+25 ];
      IFMAP_MEM[i*625+3  ] = IFMAP_MEM_t[i*625+26 ];
      IFMAP_MEM[i*625+4  ] = IFMAP_MEM_t[i*625+2  ];
      IFMAP_MEM[i*625+5  ] = IFMAP_MEM_t[i*625+3  ];
      IFMAP_MEM[i*625+6  ] = IFMAP_MEM_t[i*625+27 ];
      IFMAP_MEM[i*625+7  ] = IFMAP_MEM_t[i*625+28 ];
      IFMAP_MEM[i*625+8  ] = IFMAP_MEM_t[i*625+4  ];
      IFMAP_MEM[i*625+9  ] = IFMAP_MEM_t[i*625+5  ];
      IFMAP_MEM[i*625+10 ] = IFMAP_MEM_t[i*625+29 ];
      IFMAP_MEM[i*625+11 ] = IFMAP_MEM_t[i*625+30 ];
      IFMAP_MEM[i*625+12 ] = IFMAP_MEM_t[i*625+6  ];
      IFMAP_MEM[i*625+13 ] = IFMAP_MEM_t[i*625+7  ];
      IFMAP_MEM[i*625+14 ] = IFMAP_MEM_t[i*625+31 ];
      IFMAP_MEM[i*625+15 ] = IFMAP_MEM_t[i*625+32 ];
      IFMAP_MEM[i*625+16 ] = IFMAP_MEM_t[i*625+8  ];
      IFMAP_MEM[i*625+17 ] = IFMAP_MEM_t[i*625+9  ];
      IFMAP_MEM[i*625+18 ] = IFMAP_MEM_t[i*625+33 ];
      IFMAP_MEM[i*625+19 ] = IFMAP_MEM_t[i*625+34 ];
      IFMAP_MEM[i*625+20 ] = IFMAP_MEM_t[i*625+10 ];
      IFMAP_MEM[i*625+21 ] = IFMAP_MEM_t[i*625+11 ];
      IFMAP_MEM[i*625+22 ] = IFMAP_MEM_t[i*625+35 ];
      IFMAP_MEM[i*625+23 ] = IFMAP_MEM_t[i*625+36 ];
      IFMAP_MEM[i*625+24 ] = IFMAP_MEM_t[i*625+12 ];
      IFMAP_MEM[i*625+25 ] = IFMAP_MEM_t[i*625+13 ];
      IFMAP_MEM[i*625+26 ] = IFMAP_MEM_t[i*625+37 ];
      IFMAP_MEM[i*625+27 ] = IFMAP_MEM_t[i*625+38 ];
      IFMAP_MEM[i*625+28 ] = IFMAP_MEM_t[i*625+14 ];
      IFMAP_MEM[i*625+29 ] = IFMAP_MEM_t[i*625+15 ];
      IFMAP_MEM[i*625+30 ] = IFMAP_MEM_t[i*625+39 ];
      IFMAP_MEM[i*625+31 ] = IFMAP_MEM_t[i*625+40 ];
      IFMAP_MEM[i*625+32 ] = IFMAP_MEM_t[i*625+16 ];
      IFMAP_MEM[i*625+33 ] = IFMAP_MEM_t[i*625+17 ];
      IFMAP_MEM[i*625+34 ] = IFMAP_MEM_t[i*625+41 ];
      IFMAP_MEM[i*625+35 ] = IFMAP_MEM_t[i*625+42 ];
      IFMAP_MEM[i*625+36 ] = IFMAP_MEM_t[i*625+18 ];
      IFMAP_MEM[i*625+37 ] = IFMAP_MEM_t[i*625+19 ];
      IFMAP_MEM[i*625+38 ] = IFMAP_MEM_t[i*625+43 ];
      IFMAP_MEM[i*625+39 ] = IFMAP_MEM_t[i*625+44 ];
      IFMAP_MEM[i*625+40 ] = IFMAP_MEM_t[i*625+20 ];
      IFMAP_MEM[i*625+41 ] = IFMAP_MEM_t[i*625+21 ];
      IFMAP_MEM[i*625+42 ] = IFMAP_MEM_t[i*625+45 ];
      IFMAP_MEM[i*625+43 ] = IFMAP_MEM_t[i*625+46 ];
      IFMAP_MEM[i*625+44 ] = IFMAP_MEM_t[i*625+22 ];
      IFMAP_MEM[i*625+45 ] = IFMAP_MEM_t[i*625+23 ];
      IFMAP_MEM[i*625+46 ] = IFMAP_MEM_t[i*625+47 ];
      IFMAP_MEM[i*625+47 ] = IFMAP_MEM_t[i*625+48 ];
      IFMAP_MEM[i*625+48 ] = IFMAP_MEM_t[i*625+50 ];
      IFMAP_MEM[i*625+49 ] = IFMAP_MEM_t[i*625+51 ];
      IFMAP_MEM[i*625+50 ] = IFMAP_MEM_t[i*625+75 ];
      IFMAP_MEM[i*625+51 ] = IFMAP_MEM_t[i*625+76 ];
      IFMAP_MEM[i*625+52 ] = IFMAP_MEM_t[i*625+52 ];
      IFMAP_MEM[i*625+53 ] = IFMAP_MEM_t[i*625+53 ];
      IFMAP_MEM[i*625+54 ] = IFMAP_MEM_t[i*625+77 ];
      IFMAP_MEM[i*625+55 ] = IFMAP_MEM_t[i*625+78 ];
      IFMAP_MEM[i*625+56 ] = IFMAP_MEM_t[i*625+54 ];
      IFMAP_MEM[i*625+57 ] = IFMAP_MEM_t[i*625+55 ];
      IFMAP_MEM[i*625+58 ] = IFMAP_MEM_t[i*625+79 ];
      IFMAP_MEM[i*625+59 ] = IFMAP_MEM_t[i*625+80 ];
      IFMAP_MEM[i*625+60 ] = IFMAP_MEM_t[i*625+56 ];
      IFMAP_MEM[i*625+61 ] = IFMAP_MEM_t[i*625+57 ];
      IFMAP_MEM[i*625+62 ] = IFMAP_MEM_t[i*625+81 ];
      IFMAP_MEM[i*625+63 ] = IFMAP_MEM_t[i*625+82 ];
      IFMAP_MEM[i*625+64 ] = IFMAP_MEM_t[i*625+58 ];
      IFMAP_MEM[i*625+65 ] = IFMAP_MEM_t[i*625+59 ];
      IFMAP_MEM[i*625+66 ] = IFMAP_MEM_t[i*625+83 ];
      IFMAP_MEM[i*625+67 ] = IFMAP_MEM_t[i*625+84 ];
      IFMAP_MEM[i*625+68 ] = IFMAP_MEM_t[i*625+60 ];
      IFMAP_MEM[i*625+69 ] = IFMAP_MEM_t[i*625+61 ];
      IFMAP_MEM[i*625+70 ] = IFMAP_MEM_t[i*625+85 ];
      IFMAP_MEM[i*625+71 ] = IFMAP_MEM_t[i*625+86 ];
      IFMAP_MEM[i*625+72 ] = IFMAP_MEM_t[i*625+62 ];
      IFMAP_MEM[i*625+73 ] = IFMAP_MEM_t[i*625+63 ];
      IFMAP_MEM[i*625+74 ] = IFMAP_MEM_t[i*625+87 ];
      IFMAP_MEM[i*625+75 ] = IFMAP_MEM_t[i*625+88 ];
      IFMAP_MEM[i*625+76 ] = IFMAP_MEM_t[i*625+64 ];
      IFMAP_MEM[i*625+77 ] = IFMAP_MEM_t[i*625+65 ];
      IFMAP_MEM[i*625+78 ] = IFMAP_MEM_t[i*625+89 ];
      IFMAP_MEM[i*625+79 ] = IFMAP_MEM_t[i*625+90 ];
      IFMAP_MEM[i*625+80 ] = IFMAP_MEM_t[i*625+66 ];
      IFMAP_MEM[i*625+81 ] = IFMAP_MEM_t[i*625+67 ];
      IFMAP_MEM[i*625+82 ] = IFMAP_MEM_t[i*625+91 ];
      IFMAP_MEM[i*625+83 ] = IFMAP_MEM_t[i*625+92 ];
      IFMAP_MEM[i*625+84 ] = IFMAP_MEM_t[i*625+68 ];
      IFMAP_MEM[i*625+85 ] = IFMAP_MEM_t[i*625+69 ];
      IFMAP_MEM[i*625+86 ] = IFMAP_MEM_t[i*625+93 ];
      IFMAP_MEM[i*625+87 ] = IFMAP_MEM_t[i*625+94 ];
      IFMAP_MEM[i*625+88 ] = IFMAP_MEM_t[i*625+70 ];
      IFMAP_MEM[i*625+89 ] = IFMAP_MEM_t[i*625+71 ];
      IFMAP_MEM[i*625+90 ] = IFMAP_MEM_t[i*625+95 ];
      IFMAP_MEM[i*625+91 ] = IFMAP_MEM_t[i*625+96 ];
      IFMAP_MEM[i*625+92 ] = IFMAP_MEM_t[i*625+72 ];
      IFMAP_MEM[i*625+93 ] = IFMAP_MEM_t[i*625+73 ];
      IFMAP_MEM[i*625+94 ] = IFMAP_MEM_t[i*625+97 ];
      IFMAP_MEM[i*625+95 ] = IFMAP_MEM_t[i*625+98 ];
      IFMAP_MEM[i*625+96 ] = IFMAP_MEM_t[i*625+100];
      IFMAP_MEM[i*625+97 ] = IFMAP_MEM_t[i*625+101];
      IFMAP_MEM[i*625+98 ] = IFMAP_MEM_t[i*625+125];
      IFMAP_MEM[i*625+99 ] = IFMAP_MEM_t[i*625+126];
      IFMAP_MEM[i*625+100] = IFMAP_MEM_t[i*625+102];
      IFMAP_MEM[i*625+101] = IFMAP_MEM_t[i*625+103];
      IFMAP_MEM[i*625+102] = IFMAP_MEM_t[i*625+127];
      IFMAP_MEM[i*625+103] = IFMAP_MEM_t[i*625+128];
      IFMAP_MEM[i*625+104] = IFMAP_MEM_t[i*625+104];
      IFMAP_MEM[i*625+105] = IFMAP_MEM_t[i*625+105];
      IFMAP_MEM[i*625+106] = IFMAP_MEM_t[i*625+129];
      IFMAP_MEM[i*625+107] = IFMAP_MEM_t[i*625+130];
      IFMAP_MEM[i*625+108] = IFMAP_MEM_t[i*625+106];
      IFMAP_MEM[i*625+109] = IFMAP_MEM_t[i*625+107];
      IFMAP_MEM[i*625+110] = IFMAP_MEM_t[i*625+131];
      IFMAP_MEM[i*625+111] = IFMAP_MEM_t[i*625+132];
      IFMAP_MEM[i*625+112] = IFMAP_MEM_t[i*625+108];
      IFMAP_MEM[i*625+113] = IFMAP_MEM_t[i*625+109];
      IFMAP_MEM[i*625+114] = IFMAP_MEM_t[i*625+133];
      IFMAP_MEM[i*625+115] = IFMAP_MEM_t[i*625+134];
      IFMAP_MEM[i*625+116] = IFMAP_MEM_t[i*625+110];
      IFMAP_MEM[i*625+117] = IFMAP_MEM_t[i*625+111];
      IFMAP_MEM[i*625+118] = IFMAP_MEM_t[i*625+135];
      IFMAP_MEM[i*625+119] = IFMAP_MEM_t[i*625+136];
      IFMAP_MEM[i*625+120] = IFMAP_MEM_t[i*625+112];
      IFMAP_MEM[i*625+121] = IFMAP_MEM_t[i*625+113];
      IFMAP_MEM[i*625+122] = IFMAP_MEM_t[i*625+137];
      IFMAP_MEM[i*625+123] = IFMAP_MEM_t[i*625+138];
      IFMAP_MEM[i*625+124] = IFMAP_MEM_t[i*625+114];
      IFMAP_MEM[i*625+125] = IFMAP_MEM_t[i*625+115];
      IFMAP_MEM[i*625+126] = IFMAP_MEM_t[i*625+139];
      IFMAP_MEM[i*625+127] = IFMAP_MEM_t[i*625+140];
      IFMAP_MEM[i*625+128] = IFMAP_MEM_t[i*625+116];
      IFMAP_MEM[i*625+129] = IFMAP_MEM_t[i*625+117];
      IFMAP_MEM[i*625+130] = IFMAP_MEM_t[i*625+141];
      IFMAP_MEM[i*625+131] = IFMAP_MEM_t[i*625+142];
      IFMAP_MEM[i*625+132] = IFMAP_MEM_t[i*625+118];
      IFMAP_MEM[i*625+133] = IFMAP_MEM_t[i*625+119];
      IFMAP_MEM[i*625+134] = IFMAP_MEM_t[i*625+143];
      IFMAP_MEM[i*625+135] = IFMAP_MEM_t[i*625+144];
      IFMAP_MEM[i*625+136] = IFMAP_MEM_t[i*625+120];
      IFMAP_MEM[i*625+137] = IFMAP_MEM_t[i*625+121];
      IFMAP_MEM[i*625+138] = IFMAP_MEM_t[i*625+145];
      IFMAP_MEM[i*625+139] = IFMAP_MEM_t[i*625+146];
      IFMAP_MEM[i*625+140] = IFMAP_MEM_t[i*625+122];
      IFMAP_MEM[i*625+141] = IFMAP_MEM_t[i*625+123];
      IFMAP_MEM[i*625+142] = IFMAP_MEM_t[i*625+147];
      IFMAP_MEM[i*625+143] = IFMAP_MEM_t[i*625+148];
      IFMAP_MEM[i*625+144] = IFMAP_MEM_t[i*625+150];
      IFMAP_MEM[i*625+145] = IFMAP_MEM_t[i*625+151];
      IFMAP_MEM[i*625+146] = IFMAP_MEM_t[i*625+175];
      IFMAP_MEM[i*625+147] = IFMAP_MEM_t[i*625+176];
      IFMAP_MEM[i*625+148] = IFMAP_MEM_t[i*625+152];
      IFMAP_MEM[i*625+149] = IFMAP_MEM_t[i*625+153];
      IFMAP_MEM[i*625+150] = IFMAP_MEM_t[i*625+177];
      IFMAP_MEM[i*625+151] = IFMAP_MEM_t[i*625+178];
      IFMAP_MEM[i*625+152] = IFMAP_MEM_t[i*625+154];
      IFMAP_MEM[i*625+153] = IFMAP_MEM_t[i*625+155];
      IFMAP_MEM[i*625+154] = IFMAP_MEM_t[i*625+179];
      IFMAP_MEM[i*625+155] = IFMAP_MEM_t[i*625+180];
      IFMAP_MEM[i*625+156] = IFMAP_MEM_t[i*625+156];
      IFMAP_MEM[i*625+157] = IFMAP_MEM_t[i*625+157];
      IFMAP_MEM[i*625+158] = IFMAP_MEM_t[i*625+181];
      IFMAP_MEM[i*625+159] = IFMAP_MEM_t[i*625+182];
      IFMAP_MEM[i*625+160] = IFMAP_MEM_t[i*625+158];
      IFMAP_MEM[i*625+161] = IFMAP_MEM_t[i*625+159];
      IFMAP_MEM[i*625+162] = IFMAP_MEM_t[i*625+183];
      IFMAP_MEM[i*625+163] = IFMAP_MEM_t[i*625+184];
      IFMAP_MEM[i*625+164] = IFMAP_MEM_t[i*625+160];
      IFMAP_MEM[i*625+165] = IFMAP_MEM_t[i*625+161];
      IFMAP_MEM[i*625+166] = IFMAP_MEM_t[i*625+185];
      IFMAP_MEM[i*625+167] = IFMAP_MEM_t[i*625+186];
      IFMAP_MEM[i*625+168] = IFMAP_MEM_t[i*625+162];
      IFMAP_MEM[i*625+169] = IFMAP_MEM_t[i*625+163];
      IFMAP_MEM[i*625+170] = IFMAP_MEM_t[i*625+187];
      IFMAP_MEM[i*625+171] = IFMAP_MEM_t[i*625+188];
      IFMAP_MEM[i*625+172] = IFMAP_MEM_t[i*625+164];
      IFMAP_MEM[i*625+173] = IFMAP_MEM_t[i*625+165];
      IFMAP_MEM[i*625+174] = IFMAP_MEM_t[i*625+189];
      IFMAP_MEM[i*625+175] = IFMAP_MEM_t[i*625+190];
      IFMAP_MEM[i*625+176] = IFMAP_MEM_t[i*625+166];
      IFMAP_MEM[i*625+177] = IFMAP_MEM_t[i*625+167];
      IFMAP_MEM[i*625+178] = IFMAP_MEM_t[i*625+191];
      IFMAP_MEM[i*625+179] = IFMAP_MEM_t[i*625+192];
      IFMAP_MEM[i*625+180] = IFMAP_MEM_t[i*625+168];
      IFMAP_MEM[i*625+181] = IFMAP_MEM_t[i*625+169];
      IFMAP_MEM[i*625+182] = IFMAP_MEM_t[i*625+193];
      IFMAP_MEM[i*625+183] = IFMAP_MEM_t[i*625+194];
      IFMAP_MEM[i*625+184] = IFMAP_MEM_t[i*625+170];
      IFMAP_MEM[i*625+185] = IFMAP_MEM_t[i*625+171];
      IFMAP_MEM[i*625+186] = IFMAP_MEM_t[i*625+195];
      IFMAP_MEM[i*625+187] = IFMAP_MEM_t[i*625+196];
      IFMAP_MEM[i*625+188] = IFMAP_MEM_t[i*625+172];
      IFMAP_MEM[i*625+189] = IFMAP_MEM_t[i*625+173];
      IFMAP_MEM[i*625+190] = IFMAP_MEM_t[i*625+197];
      IFMAP_MEM[i*625+191] = IFMAP_MEM_t[i*625+198];
      IFMAP_MEM[i*625+192] = IFMAP_MEM_t[i*625+200];
      IFMAP_MEM[i*625+193] = IFMAP_MEM_t[i*625+201];
      IFMAP_MEM[i*625+194] = IFMAP_MEM_t[i*625+225];
      IFMAP_MEM[i*625+195] = IFMAP_MEM_t[i*625+226];
      IFMAP_MEM[i*625+196] = IFMAP_MEM_t[i*625+202];
      IFMAP_MEM[i*625+197] = IFMAP_MEM_t[i*625+203];
      IFMAP_MEM[i*625+198] = IFMAP_MEM_t[i*625+227];
      IFMAP_MEM[i*625+199] = IFMAP_MEM_t[i*625+228];
      IFMAP_MEM[i*625+200] = IFMAP_MEM_t[i*625+204];
      IFMAP_MEM[i*625+201] = IFMAP_MEM_t[i*625+205];
      IFMAP_MEM[i*625+202] = IFMAP_MEM_t[i*625+229];
      IFMAP_MEM[i*625+203] = IFMAP_MEM_t[i*625+230];
      IFMAP_MEM[i*625+204] = IFMAP_MEM_t[i*625+206];
      IFMAP_MEM[i*625+205] = IFMAP_MEM_t[i*625+207];
      IFMAP_MEM[i*625+206] = IFMAP_MEM_t[i*625+231];
      IFMAP_MEM[i*625+207] = IFMAP_MEM_t[i*625+232];
      IFMAP_MEM[i*625+208] = IFMAP_MEM_t[i*625+208];
      IFMAP_MEM[i*625+209] = IFMAP_MEM_t[i*625+209];
      IFMAP_MEM[i*625+210] = IFMAP_MEM_t[i*625+233];
      IFMAP_MEM[i*625+211] = IFMAP_MEM_t[i*625+234];
      IFMAP_MEM[i*625+212] = IFMAP_MEM_t[i*625+210];
      IFMAP_MEM[i*625+213] = IFMAP_MEM_t[i*625+211];
      IFMAP_MEM[i*625+214] = IFMAP_MEM_t[i*625+235];
      IFMAP_MEM[i*625+215] = IFMAP_MEM_t[i*625+236];
      IFMAP_MEM[i*625+216] = IFMAP_MEM_t[i*625+212];
      IFMAP_MEM[i*625+217] = IFMAP_MEM_t[i*625+213];
      IFMAP_MEM[i*625+218] = IFMAP_MEM_t[i*625+237];
      IFMAP_MEM[i*625+219] = IFMAP_MEM_t[i*625+238];
      IFMAP_MEM[i*625+220] = IFMAP_MEM_t[i*625+214];
      IFMAP_MEM[i*625+221] = IFMAP_MEM_t[i*625+215];
      IFMAP_MEM[i*625+222] = IFMAP_MEM_t[i*625+239];
      IFMAP_MEM[i*625+223] = IFMAP_MEM_t[i*625+240];
      IFMAP_MEM[i*625+224] = IFMAP_MEM_t[i*625+216];
      IFMAP_MEM[i*625+225] = IFMAP_MEM_t[i*625+217];
      IFMAP_MEM[i*625+226] = IFMAP_MEM_t[i*625+241];
      IFMAP_MEM[i*625+227] = IFMAP_MEM_t[i*625+242];
      IFMAP_MEM[i*625+228] = IFMAP_MEM_t[i*625+218];
      IFMAP_MEM[i*625+229] = IFMAP_MEM_t[i*625+219];
      IFMAP_MEM[i*625+230] = IFMAP_MEM_t[i*625+243];
      IFMAP_MEM[i*625+231] = IFMAP_MEM_t[i*625+244];
      IFMAP_MEM[i*625+232] = IFMAP_MEM_t[i*625+220];
      IFMAP_MEM[i*625+233] = IFMAP_MEM_t[i*625+221];
      IFMAP_MEM[i*625+234] = IFMAP_MEM_t[i*625+245];
      IFMAP_MEM[i*625+235] = IFMAP_MEM_t[i*625+246];
      IFMAP_MEM[i*625+236] = IFMAP_MEM_t[i*625+222];
      IFMAP_MEM[i*625+237] = IFMAP_MEM_t[i*625+223];
      IFMAP_MEM[i*625+238] = IFMAP_MEM_t[i*625+247];
      IFMAP_MEM[i*625+239] = IFMAP_MEM_t[i*625+248];
      IFMAP_MEM[i*625+240] = IFMAP_MEM_t[i*625+250];
      IFMAP_MEM[i*625+241] = IFMAP_MEM_t[i*625+251];
      IFMAP_MEM[i*625+242] = IFMAP_MEM_t[i*625+275];
      IFMAP_MEM[i*625+243] = IFMAP_MEM_t[i*625+276];
      IFMAP_MEM[i*625+244] = IFMAP_MEM_t[i*625+252];
      IFMAP_MEM[i*625+245] = IFMAP_MEM_t[i*625+253];
      IFMAP_MEM[i*625+246] = IFMAP_MEM_t[i*625+277];
      IFMAP_MEM[i*625+247] = IFMAP_MEM_t[i*625+278];
      IFMAP_MEM[i*625+248] = IFMAP_MEM_t[i*625+254];
      IFMAP_MEM[i*625+249] = IFMAP_MEM_t[i*625+255];
      IFMAP_MEM[i*625+250] = IFMAP_MEM_t[i*625+279];
      IFMAP_MEM[i*625+251] = IFMAP_MEM_t[i*625+280];
      IFMAP_MEM[i*625+252] = IFMAP_MEM_t[i*625+256];
      IFMAP_MEM[i*625+253] = IFMAP_MEM_t[i*625+257];
      IFMAP_MEM[i*625+254] = IFMAP_MEM_t[i*625+281];
      IFMAP_MEM[i*625+255] = IFMAP_MEM_t[i*625+282];
      IFMAP_MEM[i*625+256] = IFMAP_MEM_t[i*625+258];
      IFMAP_MEM[i*625+257] = IFMAP_MEM_t[i*625+259];
      IFMAP_MEM[i*625+258] = IFMAP_MEM_t[i*625+283];
      IFMAP_MEM[i*625+259] = IFMAP_MEM_t[i*625+284];
      IFMAP_MEM[i*625+260] = IFMAP_MEM_t[i*625+260];
      IFMAP_MEM[i*625+261] = IFMAP_MEM_t[i*625+261];
      IFMAP_MEM[i*625+262] = IFMAP_MEM_t[i*625+285];
      IFMAP_MEM[i*625+263] = IFMAP_MEM_t[i*625+286];
      IFMAP_MEM[i*625+264] = IFMAP_MEM_t[i*625+262];
      IFMAP_MEM[i*625+265] = IFMAP_MEM_t[i*625+263];
      IFMAP_MEM[i*625+266] = IFMAP_MEM_t[i*625+287];
      IFMAP_MEM[i*625+267] = IFMAP_MEM_t[i*625+288];
      IFMAP_MEM[i*625+268] = IFMAP_MEM_t[i*625+264];
      IFMAP_MEM[i*625+269] = IFMAP_MEM_t[i*625+265];
      IFMAP_MEM[i*625+270] = IFMAP_MEM_t[i*625+289];
      IFMAP_MEM[i*625+271] = IFMAP_MEM_t[i*625+290];
      IFMAP_MEM[i*625+272] = IFMAP_MEM_t[i*625+266];
      IFMAP_MEM[i*625+273] = IFMAP_MEM_t[i*625+267];
      IFMAP_MEM[i*625+274] = IFMAP_MEM_t[i*625+291];
      IFMAP_MEM[i*625+275] = IFMAP_MEM_t[i*625+292];
      IFMAP_MEM[i*625+276] = IFMAP_MEM_t[i*625+268];
      IFMAP_MEM[i*625+277] = IFMAP_MEM_t[i*625+269];
      IFMAP_MEM[i*625+278] = IFMAP_MEM_t[i*625+293];
      IFMAP_MEM[i*625+279] = IFMAP_MEM_t[i*625+294];
      IFMAP_MEM[i*625+280] = IFMAP_MEM_t[i*625+270];
      IFMAP_MEM[i*625+281] = IFMAP_MEM_t[i*625+271];
      IFMAP_MEM[i*625+282] = IFMAP_MEM_t[i*625+295];
      IFMAP_MEM[i*625+283] = IFMAP_MEM_t[i*625+296];
      IFMAP_MEM[i*625+284] = IFMAP_MEM_t[i*625+272];
      IFMAP_MEM[i*625+285] = IFMAP_MEM_t[i*625+273];
      IFMAP_MEM[i*625+286] = IFMAP_MEM_t[i*625+297];
      IFMAP_MEM[i*625+287] = IFMAP_MEM_t[i*625+298];
      IFMAP_MEM[i*625+288] = IFMAP_MEM_t[i*625+300];
      IFMAP_MEM[i*625+289] = IFMAP_MEM_t[i*625+301];
      IFMAP_MEM[i*625+290] = IFMAP_MEM_t[i*625+325];
      IFMAP_MEM[i*625+291] = IFMAP_MEM_t[i*625+326];
      IFMAP_MEM[i*625+292] = IFMAP_MEM_t[i*625+302];
      IFMAP_MEM[i*625+293] = IFMAP_MEM_t[i*625+303];
      IFMAP_MEM[i*625+294] = IFMAP_MEM_t[i*625+327];
      IFMAP_MEM[i*625+295] = IFMAP_MEM_t[i*625+328];
      IFMAP_MEM[i*625+296] = IFMAP_MEM_t[i*625+304];
      IFMAP_MEM[i*625+297] = IFMAP_MEM_t[i*625+305];
      IFMAP_MEM[i*625+298] = IFMAP_MEM_t[i*625+329];
      IFMAP_MEM[i*625+299] = IFMAP_MEM_t[i*625+330];
      IFMAP_MEM[i*625+300] = IFMAP_MEM_t[i*625+306];
      IFMAP_MEM[i*625+301] = IFMAP_MEM_t[i*625+307];
      IFMAP_MEM[i*625+302] = IFMAP_MEM_t[i*625+331];
      IFMAP_MEM[i*625+303] = IFMAP_MEM_t[i*625+332];
      IFMAP_MEM[i*625+304] = IFMAP_MEM_t[i*625+308];
      IFMAP_MEM[i*625+305] = IFMAP_MEM_t[i*625+309];
      IFMAP_MEM[i*625+306] = IFMAP_MEM_t[i*625+333];
      IFMAP_MEM[i*625+307] = IFMAP_MEM_t[i*625+334];
      IFMAP_MEM[i*625+308] = IFMAP_MEM_t[i*625+310];
      IFMAP_MEM[i*625+309] = IFMAP_MEM_t[i*625+311];
      IFMAP_MEM[i*625+310] = IFMAP_MEM_t[i*625+335];
      IFMAP_MEM[i*625+311] = IFMAP_MEM_t[i*625+336];
      IFMAP_MEM[i*625+312] = IFMAP_MEM_t[i*625+312];
      IFMAP_MEM[i*625+313] = IFMAP_MEM_t[i*625+313];
      IFMAP_MEM[i*625+314] = IFMAP_MEM_t[i*625+337];
      IFMAP_MEM[i*625+315] = IFMAP_MEM_t[i*625+338];
      IFMAP_MEM[i*625+316] = IFMAP_MEM_t[i*625+314];
      IFMAP_MEM[i*625+317] = IFMAP_MEM_t[i*625+315];
      IFMAP_MEM[i*625+318] = IFMAP_MEM_t[i*625+339];
      IFMAP_MEM[i*625+319] = IFMAP_MEM_t[i*625+340];
      IFMAP_MEM[i*625+320] = IFMAP_MEM_t[i*625+316];
      IFMAP_MEM[i*625+321] = IFMAP_MEM_t[i*625+317];
      IFMAP_MEM[i*625+322] = IFMAP_MEM_t[i*625+341];
      IFMAP_MEM[i*625+323] = IFMAP_MEM_t[i*625+342];
      IFMAP_MEM[i*625+324] = IFMAP_MEM_t[i*625+318];
      IFMAP_MEM[i*625+325] = IFMAP_MEM_t[i*625+319];
      IFMAP_MEM[i*625+326] = IFMAP_MEM_t[i*625+343];
      IFMAP_MEM[i*625+327] = IFMAP_MEM_t[i*625+344];
      IFMAP_MEM[i*625+328] = IFMAP_MEM_t[i*625+320];
      IFMAP_MEM[i*625+329] = IFMAP_MEM_t[i*625+321];
      IFMAP_MEM[i*625+330] = IFMAP_MEM_t[i*625+345];
      IFMAP_MEM[i*625+331] = IFMAP_MEM_t[i*625+346];
      IFMAP_MEM[i*625+332] = IFMAP_MEM_t[i*625+322];
      IFMAP_MEM[i*625+333] = IFMAP_MEM_t[i*625+323];
      IFMAP_MEM[i*625+334] = IFMAP_MEM_t[i*625+347];
      IFMAP_MEM[i*625+335] = IFMAP_MEM_t[i*625+348];
      IFMAP_MEM[i*625+336] = IFMAP_MEM_t[i*625+350];
      IFMAP_MEM[i*625+337] = IFMAP_MEM_t[i*625+351];
      IFMAP_MEM[i*625+338] = IFMAP_MEM_t[i*625+375];
      IFMAP_MEM[i*625+339] = IFMAP_MEM_t[i*625+376];
      IFMAP_MEM[i*625+340] = IFMAP_MEM_t[i*625+352];
      IFMAP_MEM[i*625+341] = IFMAP_MEM_t[i*625+353];
      IFMAP_MEM[i*625+342] = IFMAP_MEM_t[i*625+377];
      IFMAP_MEM[i*625+343] = IFMAP_MEM_t[i*625+378];
      IFMAP_MEM[i*625+344] = IFMAP_MEM_t[i*625+354];
      IFMAP_MEM[i*625+345] = IFMAP_MEM_t[i*625+355];
      IFMAP_MEM[i*625+346] = IFMAP_MEM_t[i*625+379];
      IFMAP_MEM[i*625+347] = IFMAP_MEM_t[i*625+380];
      IFMAP_MEM[i*625+348] = IFMAP_MEM_t[i*625+356];
      IFMAP_MEM[i*625+349] = IFMAP_MEM_t[i*625+357];
      IFMAP_MEM[i*625+350] = IFMAP_MEM_t[i*625+381];
      IFMAP_MEM[i*625+351] = IFMAP_MEM_t[i*625+382];
      IFMAP_MEM[i*625+352] = IFMAP_MEM_t[i*625+358];
      IFMAP_MEM[i*625+353] = IFMAP_MEM_t[i*625+359];
      IFMAP_MEM[i*625+354] = IFMAP_MEM_t[i*625+383];
      IFMAP_MEM[i*625+355] = IFMAP_MEM_t[i*625+384];
      IFMAP_MEM[i*625+356] = IFMAP_MEM_t[i*625+360];
      IFMAP_MEM[i*625+357] = IFMAP_MEM_t[i*625+361];
      IFMAP_MEM[i*625+358] = IFMAP_MEM_t[i*625+385];
      IFMAP_MEM[i*625+359] = IFMAP_MEM_t[i*625+386];
      IFMAP_MEM[i*625+360] = IFMAP_MEM_t[i*625+362];
      IFMAP_MEM[i*625+361] = IFMAP_MEM_t[i*625+363];
      IFMAP_MEM[i*625+362] = IFMAP_MEM_t[i*625+387];
      IFMAP_MEM[i*625+363] = IFMAP_MEM_t[i*625+388];
      IFMAP_MEM[i*625+364] = IFMAP_MEM_t[i*625+364];
      IFMAP_MEM[i*625+365] = IFMAP_MEM_t[i*625+365];
      IFMAP_MEM[i*625+366] = IFMAP_MEM_t[i*625+389];
      IFMAP_MEM[i*625+367] = IFMAP_MEM_t[i*625+390];
      IFMAP_MEM[i*625+368] = IFMAP_MEM_t[i*625+366];
      IFMAP_MEM[i*625+369] = IFMAP_MEM_t[i*625+367];
      IFMAP_MEM[i*625+370] = IFMAP_MEM_t[i*625+391];
      IFMAP_MEM[i*625+371] = IFMAP_MEM_t[i*625+392];
      IFMAP_MEM[i*625+372] = IFMAP_MEM_t[i*625+368];
      IFMAP_MEM[i*625+373] = IFMAP_MEM_t[i*625+369];
      IFMAP_MEM[i*625+374] = IFMAP_MEM_t[i*625+393];
      IFMAP_MEM[i*625+375] = IFMAP_MEM_t[i*625+394];
      IFMAP_MEM[i*625+376] = IFMAP_MEM_t[i*625+370];
      IFMAP_MEM[i*625+377] = IFMAP_MEM_t[i*625+371];
      IFMAP_MEM[i*625+378] = IFMAP_MEM_t[i*625+395];
      IFMAP_MEM[i*625+379] = IFMAP_MEM_t[i*625+396];
      IFMAP_MEM[i*625+380] = IFMAP_MEM_t[i*625+372];
      IFMAP_MEM[i*625+381] = IFMAP_MEM_t[i*625+373];
      IFMAP_MEM[i*625+382] = IFMAP_MEM_t[i*625+397];
      IFMAP_MEM[i*625+383] = IFMAP_MEM_t[i*625+398];
      IFMAP_MEM[i*625+384] = IFMAP_MEM_t[i*625+400];
      IFMAP_MEM[i*625+385] = IFMAP_MEM_t[i*625+401];
      IFMAP_MEM[i*625+386] = IFMAP_MEM_t[i*625+425];
      IFMAP_MEM[i*625+387] = IFMAP_MEM_t[i*625+426];
      IFMAP_MEM[i*625+388] = IFMAP_MEM_t[i*625+402];
      IFMAP_MEM[i*625+389] = IFMAP_MEM_t[i*625+403];
      IFMAP_MEM[i*625+390] = IFMAP_MEM_t[i*625+427];
      IFMAP_MEM[i*625+391] = IFMAP_MEM_t[i*625+428];
      IFMAP_MEM[i*625+392] = IFMAP_MEM_t[i*625+404];
      IFMAP_MEM[i*625+393] = IFMAP_MEM_t[i*625+405];
      IFMAP_MEM[i*625+394] = IFMAP_MEM_t[i*625+429];
      IFMAP_MEM[i*625+395] = IFMAP_MEM_t[i*625+430];
      IFMAP_MEM[i*625+396] = IFMAP_MEM_t[i*625+406];
      IFMAP_MEM[i*625+397] = IFMAP_MEM_t[i*625+407];
      IFMAP_MEM[i*625+398] = IFMAP_MEM_t[i*625+431];
      IFMAP_MEM[i*625+399] = IFMAP_MEM_t[i*625+432];
      IFMAP_MEM[i*625+400] = IFMAP_MEM_t[i*625+408];
      IFMAP_MEM[i*625+401] = IFMAP_MEM_t[i*625+409];
      IFMAP_MEM[i*625+402] = IFMAP_MEM_t[i*625+433];
      IFMAP_MEM[i*625+403] = IFMAP_MEM_t[i*625+434];
      IFMAP_MEM[i*625+404] = IFMAP_MEM_t[i*625+410];
      IFMAP_MEM[i*625+405] = IFMAP_MEM_t[i*625+411];
      IFMAP_MEM[i*625+406] = IFMAP_MEM_t[i*625+435];
      IFMAP_MEM[i*625+407] = IFMAP_MEM_t[i*625+436];
      IFMAP_MEM[i*625+408] = IFMAP_MEM_t[i*625+412];
      IFMAP_MEM[i*625+409] = IFMAP_MEM_t[i*625+413];
      IFMAP_MEM[i*625+410] = IFMAP_MEM_t[i*625+437];
      IFMAP_MEM[i*625+411] = IFMAP_MEM_t[i*625+438];
      IFMAP_MEM[i*625+412] = IFMAP_MEM_t[i*625+414];
      IFMAP_MEM[i*625+413] = IFMAP_MEM_t[i*625+415];
      IFMAP_MEM[i*625+414] = IFMAP_MEM_t[i*625+439];
      IFMAP_MEM[i*625+415] = IFMAP_MEM_t[i*625+440];
      IFMAP_MEM[i*625+416] = IFMAP_MEM_t[i*625+416];
      IFMAP_MEM[i*625+417] = IFMAP_MEM_t[i*625+417];
      IFMAP_MEM[i*625+418] = IFMAP_MEM_t[i*625+441];
      IFMAP_MEM[i*625+419] = IFMAP_MEM_t[i*625+442];
      IFMAP_MEM[i*625+420] = IFMAP_MEM_t[i*625+418];
      IFMAP_MEM[i*625+421] = IFMAP_MEM_t[i*625+419];
      IFMAP_MEM[i*625+422] = IFMAP_MEM_t[i*625+443];
      IFMAP_MEM[i*625+423] = IFMAP_MEM_t[i*625+444];
      IFMAP_MEM[i*625+424] = IFMAP_MEM_t[i*625+420];
      IFMAP_MEM[i*625+425] = IFMAP_MEM_t[i*625+421];
      IFMAP_MEM[i*625+426] = IFMAP_MEM_t[i*625+445];
      IFMAP_MEM[i*625+427] = IFMAP_MEM_t[i*625+446];
      IFMAP_MEM[i*625+428] = IFMAP_MEM_t[i*625+422];
      IFMAP_MEM[i*625+429] = IFMAP_MEM_t[i*625+423];
      IFMAP_MEM[i*625+430] = IFMAP_MEM_t[i*625+447];
      IFMAP_MEM[i*625+431] = IFMAP_MEM_t[i*625+448];
      IFMAP_MEM[i*625+432] = IFMAP_MEM_t[i*625+450];
      IFMAP_MEM[i*625+433] = IFMAP_MEM_t[i*625+451];
      IFMAP_MEM[i*625+434] = IFMAP_MEM_t[i*625+475];
      IFMAP_MEM[i*625+435] = IFMAP_MEM_t[i*625+476];
      IFMAP_MEM[i*625+436] = IFMAP_MEM_t[i*625+452];
      IFMAP_MEM[i*625+437] = IFMAP_MEM_t[i*625+453];
      IFMAP_MEM[i*625+438] = IFMAP_MEM_t[i*625+477];
      IFMAP_MEM[i*625+439] = IFMAP_MEM_t[i*625+478];
      IFMAP_MEM[i*625+440] = IFMAP_MEM_t[i*625+454];
      IFMAP_MEM[i*625+441] = IFMAP_MEM_t[i*625+455];
      IFMAP_MEM[i*625+442] = IFMAP_MEM_t[i*625+479];
      IFMAP_MEM[i*625+443] = IFMAP_MEM_t[i*625+480];
      IFMAP_MEM[i*625+444] = IFMAP_MEM_t[i*625+456];
      IFMAP_MEM[i*625+445] = IFMAP_MEM_t[i*625+457];
      IFMAP_MEM[i*625+446] = IFMAP_MEM_t[i*625+481];
      IFMAP_MEM[i*625+447] = IFMAP_MEM_t[i*625+482];
      IFMAP_MEM[i*625+448] = IFMAP_MEM_t[i*625+458];
      IFMAP_MEM[i*625+449] = IFMAP_MEM_t[i*625+459];
      IFMAP_MEM[i*625+450] = IFMAP_MEM_t[i*625+483];
      IFMAP_MEM[i*625+451] = IFMAP_MEM_t[i*625+484];
      IFMAP_MEM[i*625+452] = IFMAP_MEM_t[i*625+460];
      IFMAP_MEM[i*625+453] = IFMAP_MEM_t[i*625+461];
      IFMAP_MEM[i*625+454] = IFMAP_MEM_t[i*625+485];
      IFMAP_MEM[i*625+455] = IFMAP_MEM_t[i*625+486];
      IFMAP_MEM[i*625+456] = IFMAP_MEM_t[i*625+462];
      IFMAP_MEM[i*625+457] = IFMAP_MEM_t[i*625+463];
      IFMAP_MEM[i*625+458] = IFMAP_MEM_t[i*625+487];
      IFMAP_MEM[i*625+459] = IFMAP_MEM_t[i*625+488];
      IFMAP_MEM[i*625+460] = IFMAP_MEM_t[i*625+464];
      IFMAP_MEM[i*625+461] = IFMAP_MEM_t[i*625+465];
      IFMAP_MEM[i*625+462] = IFMAP_MEM_t[i*625+489];
      IFMAP_MEM[i*625+463] = IFMAP_MEM_t[i*625+490];
      IFMAP_MEM[i*625+464] = IFMAP_MEM_t[i*625+466];
      IFMAP_MEM[i*625+465] = IFMAP_MEM_t[i*625+467];
      IFMAP_MEM[i*625+466] = IFMAP_MEM_t[i*625+491];
      IFMAP_MEM[i*625+467] = IFMAP_MEM_t[i*625+492];
      IFMAP_MEM[i*625+468] = IFMAP_MEM_t[i*625+468];
      IFMAP_MEM[i*625+469] = IFMAP_MEM_t[i*625+469];
      IFMAP_MEM[i*625+470] = IFMAP_MEM_t[i*625+493];
      IFMAP_MEM[i*625+471] = IFMAP_MEM_t[i*625+494];
      IFMAP_MEM[i*625+472] = IFMAP_MEM_t[i*625+470];
      IFMAP_MEM[i*625+473] = IFMAP_MEM_t[i*625+471];
      IFMAP_MEM[i*625+474] = IFMAP_MEM_t[i*625+495];
      IFMAP_MEM[i*625+475] = IFMAP_MEM_t[i*625+496];
      IFMAP_MEM[i*625+476] = IFMAP_MEM_t[i*625+472];
      IFMAP_MEM[i*625+477] = IFMAP_MEM_t[i*625+473];
      IFMAP_MEM[i*625+478] = IFMAP_MEM_t[i*625+497];
      IFMAP_MEM[i*625+479] = IFMAP_MEM_t[i*625+498];
      IFMAP_MEM[i*625+480] = IFMAP_MEM_t[i*625+500];
      IFMAP_MEM[i*625+481] = IFMAP_MEM_t[i*625+501];
      IFMAP_MEM[i*625+482] = IFMAP_MEM_t[i*625+525];
      IFMAP_MEM[i*625+483] = IFMAP_MEM_t[i*625+526];
      IFMAP_MEM[i*625+484] = IFMAP_MEM_t[i*625+502];
      IFMAP_MEM[i*625+485] = IFMAP_MEM_t[i*625+503];
      IFMAP_MEM[i*625+486] = IFMAP_MEM_t[i*625+527];
      IFMAP_MEM[i*625+487] = IFMAP_MEM_t[i*625+528];
      IFMAP_MEM[i*625+488] = IFMAP_MEM_t[i*625+504];
      IFMAP_MEM[i*625+489] = IFMAP_MEM_t[i*625+505];
      IFMAP_MEM[i*625+490] = IFMAP_MEM_t[i*625+529];
      IFMAP_MEM[i*625+491] = IFMAP_MEM_t[i*625+530];
      IFMAP_MEM[i*625+492] = IFMAP_MEM_t[i*625+506];
      IFMAP_MEM[i*625+493] = IFMAP_MEM_t[i*625+507];
      IFMAP_MEM[i*625+494] = IFMAP_MEM_t[i*625+531];
      IFMAP_MEM[i*625+495] = IFMAP_MEM_t[i*625+532];
      IFMAP_MEM[i*625+496] = IFMAP_MEM_t[i*625+508];
      IFMAP_MEM[i*625+497] = IFMAP_MEM_t[i*625+509];
      IFMAP_MEM[i*625+498] = IFMAP_MEM_t[i*625+533];
      IFMAP_MEM[i*625+499] = IFMAP_MEM_t[i*625+534];
      IFMAP_MEM[i*625+500] = IFMAP_MEM_t[i*625+510];
      IFMAP_MEM[i*625+501] = IFMAP_MEM_t[i*625+511];
      IFMAP_MEM[i*625+502] = IFMAP_MEM_t[i*625+535];
      IFMAP_MEM[i*625+503] = IFMAP_MEM_t[i*625+536];
      IFMAP_MEM[i*625+504] = IFMAP_MEM_t[i*625+512];
      IFMAP_MEM[i*625+505] = IFMAP_MEM_t[i*625+513];
      IFMAP_MEM[i*625+506] = IFMAP_MEM_t[i*625+537];
      IFMAP_MEM[i*625+507] = IFMAP_MEM_t[i*625+538];
      IFMAP_MEM[i*625+508] = IFMAP_MEM_t[i*625+514];
      IFMAP_MEM[i*625+509] = IFMAP_MEM_t[i*625+515];
      IFMAP_MEM[i*625+510] = IFMAP_MEM_t[i*625+539];
      IFMAP_MEM[i*625+511] = IFMAP_MEM_t[i*625+540];
      IFMAP_MEM[i*625+512] = IFMAP_MEM_t[i*625+516];
      IFMAP_MEM[i*625+513] = IFMAP_MEM_t[i*625+517];
      IFMAP_MEM[i*625+514] = IFMAP_MEM_t[i*625+541];
      IFMAP_MEM[i*625+515] = IFMAP_MEM_t[i*625+542];
      IFMAP_MEM[i*625+516] = IFMAP_MEM_t[i*625+518];
      IFMAP_MEM[i*625+517] = IFMAP_MEM_t[i*625+519];
      IFMAP_MEM[i*625+518] = IFMAP_MEM_t[i*625+543];
      IFMAP_MEM[i*625+519] = IFMAP_MEM_t[i*625+544];
      IFMAP_MEM[i*625+520] = IFMAP_MEM_t[i*625+520];
      IFMAP_MEM[i*625+521] = IFMAP_MEM_t[i*625+521];
      IFMAP_MEM[i*625+522] = IFMAP_MEM_t[i*625+545];
      IFMAP_MEM[i*625+523] = IFMAP_MEM_t[i*625+546];
      IFMAP_MEM[i*625+524] = IFMAP_MEM_t[i*625+522];
      IFMAP_MEM[i*625+525] = IFMAP_MEM_t[i*625+523];
      IFMAP_MEM[i*625+526] = IFMAP_MEM_t[i*625+547];
      IFMAP_MEM[i*625+527] = IFMAP_MEM_t[i*625+548];
      IFMAP_MEM[i*625+528] = IFMAP_MEM_t[i*625+550];
      IFMAP_MEM[i*625+529] = IFMAP_MEM_t[i*625+551];
      IFMAP_MEM[i*625+530] = IFMAP_MEM_t[i*625+575];
      IFMAP_MEM[i*625+531] = IFMAP_MEM_t[i*625+576];
      IFMAP_MEM[i*625+532] = IFMAP_MEM_t[i*625+552];
      IFMAP_MEM[i*625+533] = IFMAP_MEM_t[i*625+553];
      IFMAP_MEM[i*625+534] = IFMAP_MEM_t[i*625+577];
      IFMAP_MEM[i*625+535] = IFMAP_MEM_t[i*625+578];
      IFMAP_MEM[i*625+536] = IFMAP_MEM_t[i*625+554];
      IFMAP_MEM[i*625+537] = IFMAP_MEM_t[i*625+555];
      IFMAP_MEM[i*625+538] = IFMAP_MEM_t[i*625+579];
      IFMAP_MEM[i*625+539] = IFMAP_MEM_t[i*625+580];
      IFMAP_MEM[i*625+540] = IFMAP_MEM_t[i*625+556];
      IFMAP_MEM[i*625+541] = IFMAP_MEM_t[i*625+557];
      IFMAP_MEM[i*625+542] = IFMAP_MEM_t[i*625+581];
      IFMAP_MEM[i*625+543] = IFMAP_MEM_t[i*625+582];
      IFMAP_MEM[i*625+544] = IFMAP_MEM_t[i*625+558];
      IFMAP_MEM[i*625+545] = IFMAP_MEM_t[i*625+559];
      IFMAP_MEM[i*625+546] = IFMAP_MEM_t[i*625+583];
      IFMAP_MEM[i*625+547] = IFMAP_MEM_t[i*625+584];
      IFMAP_MEM[i*625+548] = IFMAP_MEM_t[i*625+560];
      IFMAP_MEM[i*625+549] = IFMAP_MEM_t[i*625+561];
      IFMAP_MEM[i*625+550] = IFMAP_MEM_t[i*625+585];
      IFMAP_MEM[i*625+551] = IFMAP_MEM_t[i*625+586];
      IFMAP_MEM[i*625+552] = IFMAP_MEM_t[i*625+562];
      IFMAP_MEM[i*625+553] = IFMAP_MEM_t[i*625+563];
      IFMAP_MEM[i*625+554] = IFMAP_MEM_t[i*625+587];
      IFMAP_MEM[i*625+555] = IFMAP_MEM_t[i*625+588];
      IFMAP_MEM[i*625+556] = IFMAP_MEM_t[i*625+564];
      IFMAP_MEM[i*625+557] = IFMAP_MEM_t[i*625+565];
      IFMAP_MEM[i*625+558] = IFMAP_MEM_t[i*625+589];
      IFMAP_MEM[i*625+559] = IFMAP_MEM_t[i*625+590];
      IFMAP_MEM[i*625+560] = IFMAP_MEM_t[i*625+566];
      IFMAP_MEM[i*625+561] = IFMAP_MEM_t[i*625+567];
      IFMAP_MEM[i*625+562] = IFMAP_MEM_t[i*625+591];
      IFMAP_MEM[i*625+563] = IFMAP_MEM_t[i*625+592];
      IFMAP_MEM[i*625+564] = IFMAP_MEM_t[i*625+568];
      IFMAP_MEM[i*625+565] = IFMAP_MEM_t[i*625+569];
      IFMAP_MEM[i*625+566] = IFMAP_MEM_t[i*625+593];
      IFMAP_MEM[i*625+567] = IFMAP_MEM_t[i*625+594];
      IFMAP_MEM[i*625+568] = IFMAP_MEM_t[i*625+570];
      IFMAP_MEM[i*625+569] = IFMAP_MEM_t[i*625+571];
      IFMAP_MEM[i*625+570] = IFMAP_MEM_t[i*625+595];
      IFMAP_MEM[i*625+571] = IFMAP_MEM_t[i*625+596];
      IFMAP_MEM[i*625+572] = IFMAP_MEM_t[i*625+572];
      IFMAP_MEM[i*625+573] = IFMAP_MEM_t[i*625+573];
      IFMAP_MEM[i*625+574] = IFMAP_MEM_t[i*625+597];
      IFMAP_MEM[i*625+575] = IFMAP_MEM_t[i*625+598];
      IFMAP_MEM[i*625+576] = IFMAP_MEM_t[i*625+24 ];
      IFMAP_MEM[i*625+577] = IFMAP_MEM_t[i*625+49 ];
      IFMAP_MEM[i*625+578] = IFMAP_MEM_t[i*625+74 ];
      IFMAP_MEM[i*625+579] = IFMAP_MEM_t[i*625+99 ];
      IFMAP_MEM[i*625+580] = IFMAP_MEM_t[i*625+124];
      IFMAP_MEM[i*625+581] = IFMAP_MEM_t[i*625+149];
      IFMAP_MEM[i*625+582] = IFMAP_MEM_t[i*625+174];
      IFMAP_MEM[i*625+583] = IFMAP_MEM_t[i*625+199];
      IFMAP_MEM[i*625+584] = IFMAP_MEM_t[i*625+224];
      IFMAP_MEM[i*625+585] = IFMAP_MEM_t[i*625+249];
      IFMAP_MEM[i*625+586] = IFMAP_MEM_t[i*625+274];
      IFMAP_MEM[i*625+587] = IFMAP_MEM_t[i*625+299];
      IFMAP_MEM[i*625+588] = IFMAP_MEM_t[i*625+324];
      IFMAP_MEM[i*625+589] = IFMAP_MEM_t[i*625+349];
      IFMAP_MEM[i*625+590] = IFMAP_MEM_t[i*625+374];
      IFMAP_MEM[i*625+591] = IFMAP_MEM_t[i*625+399];
      IFMAP_MEM[i*625+592] = IFMAP_MEM_t[i*625+424];
      IFMAP_MEM[i*625+593] = IFMAP_MEM_t[i*625+449];
      IFMAP_MEM[i*625+594] = IFMAP_MEM_t[i*625+474];
      IFMAP_MEM[i*625+595] = IFMAP_MEM_t[i*625+499];
      IFMAP_MEM[i*625+596] = IFMAP_MEM_t[i*625+524];
      IFMAP_MEM[i*625+597] = IFMAP_MEM_t[i*625+549];
      IFMAP_MEM[i*625+598] = IFMAP_MEM_t[i*625+574];
      IFMAP_MEM[i*625+599] = IFMAP_MEM_t[i*625+599];
      IFMAP_MEM[i*625+600] = IFMAP_MEM_t[i*625+600];
      IFMAP_MEM[i*625+601] = IFMAP_MEM_t[i*625+601];
      IFMAP_MEM[i*625+602] = IFMAP_MEM_t[i*625+602];
      IFMAP_MEM[i*625+603] = IFMAP_MEM_t[i*625+603];
      IFMAP_MEM[i*625+604] = IFMAP_MEM_t[i*625+604];
      IFMAP_MEM[i*625+605] = IFMAP_MEM_t[i*625+605];
      IFMAP_MEM[i*625+606] = IFMAP_MEM_t[i*625+606];
      IFMAP_MEM[i*625+607] = IFMAP_MEM_t[i*625+607];
      IFMAP_MEM[i*625+608] = IFMAP_MEM_t[i*625+608];
      IFMAP_MEM[i*625+609] = IFMAP_MEM_t[i*625+609];
      IFMAP_MEM[i*625+610] = IFMAP_MEM_t[i*625+610];
      IFMAP_MEM[i*625+611] = IFMAP_MEM_t[i*625+611];
      IFMAP_MEM[i*625+612] = IFMAP_MEM_t[i*625+612];
      IFMAP_MEM[i*625+613] = IFMAP_MEM_t[i*625+613];
      IFMAP_MEM[i*625+614] = IFMAP_MEM_t[i*625+614];
      IFMAP_MEM[i*625+615] = IFMAP_MEM_t[i*625+615];
      IFMAP_MEM[i*625+616] = IFMAP_MEM_t[i*625+616];
      IFMAP_MEM[i*625+617] = IFMAP_MEM_t[i*625+617];
      IFMAP_MEM[i*625+618] = IFMAP_MEM_t[i*625+618];
      IFMAP_MEM[i*625+619] = IFMAP_MEM_t[i*625+619];
      IFMAP_MEM[i*625+620] = IFMAP_MEM_t[i*625+620];
      IFMAP_MEM[i*625+621] = IFMAP_MEM_t[i*625+621];
      IFMAP_MEM[i*625+622] = IFMAP_MEM_t[i*625+622];
      IFMAP_MEM[i*625+623] = IFMAP_MEM_t[i*625+623];
      IFMAP_MEM[i*625+624] = IFMAP_MEM_t[i*625+624];
    end
          
    //fp_w = $fopen("../cnn1_ofmap/cnn1_ofmap.txt", "w");
    W_ROW         =   8;//6
    W_COL         =  16;
    X_ROW         =  16;
    X_COL         = 625;
    M_X_COL       = 144;
  #(`CYCLE/4)    rst = 1'b0;
	#(`CYCLE/2)    rst = 1'b1;
  ///////////////////////////////////do convolution_1//////////////////////////////
  ////////////////////////////////////////wait///////////////////////////////////
    @(negedge done)begin
      //$fwrite(fp_w, "%b\n", RAM[i1]);
      
      /////////////////////max pooling_1/////////////////////////////
      /*
      for(i=0;i<6;i=i+1)begin
        k = 0;
        for(j=0;j<576;j=j+4)begin
          max_t1 = (RAM[i*625+j]>=RAM[i*625+j+1])?RAM[i*625+j]:RAM[i*625+j+1];
          max_t2 = (RAM[i*625+j+2]>=RAM[i*625+j+3])?RAM[i*625+j+2]:RAM[i*625+j+3];
          max = (max_t1>=max_t2)?max_t1:max_t2;
          MAX_MEM[i*144+k] = max;
          k = k + 1;
        end
      end
      */
      ///////////////////////////////im2col/////////////////////////////////////////
      k = 0;
      addr = -1;
      temp = -1;
      for(i=0;i<96;i=i+1)begin
        if(i%16==0 && i!=0) temp = temp + 105;
        else if(i%4==0 && i!=0) temp = temp + 9;
        else temp = temp + 1;
        addr = temp;
        for(j=1;j<82;j=j+1)begin
          IFMAP_MEM_t[k] = MAX_MEM[addr];
          k = k + 1;
          if(j%9==0 && j!=0) addr = addr + 4;
          else addr = addr + 1;
        end
      end
    end
    
    for(i=0;i<96;i=i+1)begin
      IFMAP_MEM[i*81+0  ] = IFMAP_MEM_t[i*81+0  ];
      IFMAP_MEM[i*81+1  ] = IFMAP_MEM_t[i*81+1  ];
      IFMAP_MEM[i*81+2  ] = IFMAP_MEM_t[i*81+9  ];
      IFMAP_MEM[i*81+3  ] = IFMAP_MEM_t[i*81+10 ];
      IFMAP_MEM[i*81+4  ] = IFMAP_MEM_t[i*81+2  ];
      IFMAP_MEM[i*81+5  ] = IFMAP_MEM_t[i*81+3  ];
      IFMAP_MEM[i*81+6  ] = IFMAP_MEM_t[i*81+11 ];
      IFMAP_MEM[i*81+7  ] = IFMAP_MEM_t[i*81+12 ];
      IFMAP_MEM[i*81+8  ] = IFMAP_MEM_t[i*81+4  ];
      IFMAP_MEM[i*81+9  ] = IFMAP_MEM_t[i*81+5  ];
      IFMAP_MEM[i*81+10 ] = IFMAP_MEM_t[i*81+13 ];
      IFMAP_MEM[i*81+11 ] = IFMAP_MEM_t[i*81+14 ];
      IFMAP_MEM[i*81+12 ] = IFMAP_MEM_t[i*81+6  ];
      IFMAP_MEM[i*81+13 ] = IFMAP_MEM_t[i*81+7  ];
      IFMAP_MEM[i*81+14 ] = IFMAP_MEM_t[i*81+15 ];
      IFMAP_MEM[i*81+15 ] = IFMAP_MEM_t[i*81+16 ];
      IFMAP_MEM[i*81+16 ] = IFMAP_MEM_t[i*81+18 ];
      IFMAP_MEM[i*81+17 ] = IFMAP_MEM_t[i*81+19 ];
      IFMAP_MEM[i*81+18 ] = IFMAP_MEM_t[i*81+27 ];
      IFMAP_MEM[i*81+19 ] = IFMAP_MEM_t[i*81+28 ];
      IFMAP_MEM[i*81+20 ] = IFMAP_MEM_t[i*81+20 ];
      IFMAP_MEM[i*81+21 ] = IFMAP_MEM_t[i*81+21 ];
      IFMAP_MEM[i*81+22 ] = IFMAP_MEM_t[i*81+29 ];
      IFMAP_MEM[i*81+23 ] = IFMAP_MEM_t[i*81+30 ];
      IFMAP_MEM[i*81+24 ] = IFMAP_MEM_t[i*81+22 ];
      IFMAP_MEM[i*81+25 ] = IFMAP_MEM_t[i*81+23 ];
      IFMAP_MEM[i*81+26 ] = IFMAP_MEM_t[i*81+31 ];
      IFMAP_MEM[i*81+27 ] = IFMAP_MEM_t[i*81+32 ];
      IFMAP_MEM[i*81+28 ] = IFMAP_MEM_t[i*81+24 ];
      IFMAP_MEM[i*81+29 ] = IFMAP_MEM_t[i*81+25 ];
      IFMAP_MEM[i*81+30 ] = IFMAP_MEM_t[i*81+33 ];
      IFMAP_MEM[i*81+31 ] = IFMAP_MEM_t[i*81+34 ];
      IFMAP_MEM[i*81+32 ] = IFMAP_MEM_t[i*81+36 ];
      IFMAP_MEM[i*81+33 ] = IFMAP_MEM_t[i*81+37 ];
      IFMAP_MEM[i*81+34 ] = IFMAP_MEM_t[i*81+45 ];
      IFMAP_MEM[i*81+35 ] = IFMAP_MEM_t[i*81+46 ];
      IFMAP_MEM[i*81+36 ] = IFMAP_MEM_t[i*81+38 ];
      IFMAP_MEM[i*81+37 ] = IFMAP_MEM_t[i*81+39 ];
      IFMAP_MEM[i*81+38 ] = IFMAP_MEM_t[i*81+47 ];
      IFMAP_MEM[i*81+39 ] = IFMAP_MEM_t[i*81+48 ];
      IFMAP_MEM[i*81+40 ] = IFMAP_MEM_t[i*81+40 ];
      IFMAP_MEM[i*81+41 ] = IFMAP_MEM_t[i*81+41 ];
      IFMAP_MEM[i*81+42 ] = IFMAP_MEM_t[i*81+49 ];
      IFMAP_MEM[i*81+43 ] = IFMAP_MEM_t[i*81+50 ];
      IFMAP_MEM[i*81+44 ] = IFMAP_MEM_t[i*81+42 ];
      IFMAP_MEM[i*81+45 ] = IFMAP_MEM_t[i*81+43 ];
      IFMAP_MEM[i*81+46 ] = IFMAP_MEM_t[i*81+51 ];
      IFMAP_MEM[i*81+47 ] = IFMAP_MEM_t[i*81+52 ];
      IFMAP_MEM[i*81+48 ] = IFMAP_MEM_t[i*81+54 ];
      IFMAP_MEM[i*81+49 ] = IFMAP_MEM_t[i*81+55 ];
      IFMAP_MEM[i*81+50 ] = IFMAP_MEM_t[i*81+63 ];
      IFMAP_MEM[i*81+51 ] = IFMAP_MEM_t[i*81+64 ];
      IFMAP_MEM[i*81+52 ] = IFMAP_MEM_t[i*81+56 ];
      IFMAP_MEM[i*81+53 ] = IFMAP_MEM_t[i*81+57 ];
      IFMAP_MEM[i*81+54 ] = IFMAP_MEM_t[i*81+65 ];
      IFMAP_MEM[i*81+55 ] = IFMAP_MEM_t[i*81+66 ];
      IFMAP_MEM[i*81+56 ] = IFMAP_MEM_t[i*81+58 ];
      IFMAP_MEM[i*81+57 ] = IFMAP_MEM_t[i*81+59 ];
      IFMAP_MEM[i*81+58 ] = IFMAP_MEM_t[i*81+67 ];
      IFMAP_MEM[i*81+59 ] = IFMAP_MEM_t[i*81+68 ];
      IFMAP_MEM[i*81+60 ] = IFMAP_MEM_t[i*81+60 ];
      IFMAP_MEM[i*81+61 ] = IFMAP_MEM_t[i*81+61 ];
      IFMAP_MEM[i*81+62 ] = IFMAP_MEM_t[i*81+69 ];
      IFMAP_MEM[i*81+63 ] = IFMAP_MEM_t[i*81+70 ];
      IFMAP_MEM[i*81+64 ] = IFMAP_MEM_t[i*81+8  ];
      IFMAP_MEM[i*81+65 ] = IFMAP_MEM_t[i*81+17 ];
      IFMAP_MEM[i*81+66 ] = IFMAP_MEM_t[i*81+26 ];
      IFMAP_MEM[i*81+67 ] = IFMAP_MEM_t[i*81+35 ];
      IFMAP_MEM[i*81+68 ] = IFMAP_MEM_t[i*81+44 ];
      IFMAP_MEM[i*81+69 ] = IFMAP_MEM_t[i*81+53 ];
      IFMAP_MEM[i*81+70 ] = IFMAP_MEM_t[i*81+62 ];
      IFMAP_MEM[i*81+71 ] = IFMAP_MEM_t[i*81+71 ];
      IFMAP_MEM[i*81+72 ] = IFMAP_MEM_t[i*81+72 ];
      IFMAP_MEM[i*81+73 ] = IFMAP_MEM_t[i*81+73 ];
      IFMAP_MEM[i*81+74 ] = IFMAP_MEM_t[i*81+74 ];
      IFMAP_MEM[i*81+75 ] = IFMAP_MEM_t[i*81+75 ];
      IFMAP_MEM[i*81+76 ] = IFMAP_MEM_t[i*81+76 ];
      IFMAP_MEM[i*81+77 ] = IFMAP_MEM_t[i*81+77 ];
      IFMAP_MEM[i*81+78 ] = IFMAP_MEM_t[i*81+78 ];
      IFMAP_MEM[i*81+79 ] = IFMAP_MEM_t[i*81+79 ];
      IFMAP_MEM[i*81+80 ] = IFMAP_MEM_t[i*81+80 ];
    end

  /////////////////////////////////////////////////
  $readmemb("../signed_bin_data/cnn2_wb.txt", WEIGHT_MEM);
  //fp_w = $fopen("../cnn2_ofmap/cnn2_ofmap.txt", "w");
  W_ROW         = 12;
  W_COL         = 96;
  X_ROW         = 96;
  X_COL         = 81;
  M_X_COL       = 16;
  #(`CYCLE/4)    rst = 1'b0;
	#(`CYCLE/2)    rst = 1'b1;
  ///////////////////////////////////do convolution_2//////////////////////////////
  ////////////////////////////////////////wait///////////////////////////////////
    @(negedge done)begin
      //$fwrite(fp_w, "%b\n", RAM[i1]);
      
      /////////////////////////////max pooling_2////////////////////////////////////
      /*
      for(i=0;i<12;i=i+1)begin
        k = 0;
        for(j=0;j<64;j=j+4)begin
          max_t1 = (RAM[i*81+j]>=RAM[i*81+j+1])?RAM[i*81+j]:RAM[i*81+j+1];
          max_t2 = (RAM[i*81+j+2]>=RAM[i*81+j+3])?RAM[i*81+j+2]:RAM[i*81+j+3];
          max = (max_t1>=max_t2)?max_t1:max_t2;
          MAX_MEM[i*16+k] = max;
          k = k + 1;
        end
      end
      */
      /////////////////////////////////im2col////////////////////////////////
      for(i=0;i<192;i=i+1)begin
        IFMAP_MEM[i] = MAX_MEM[i];
      end
    end
  /////////////////////////////////////////////////
  $readmemb("../signed_bin_data/fc_wb.txt", WEIGHT_MEM);
  //fp_w = $fopen("../final/final.txt", "w");
  W_ROW         =  12;
  W_COL         = 192;
  X_ROW         = 192;
  X_COL         =   1;
  M_X_COL       =   1;
  #(`CYCLE/4)    rst = 1'b0;
	#(`CYCLE/2)    rst = 1'b1;
  ///////////////////////////////////do fully connected//////////////////////////////
  ////////////////////////////////////////wait///////////////////////////////////////
    @(negedge done)begin
      max = 0;
      index = 0;
      for(i=0;i<10;i=i+1)begin
        if(MAX_MEM[i]>max)begin
          max = MAX_MEM[i];
          index = i;
        end
      end
      
      if(index==GOLDEN[count])begin
        $display("                        image:%d --> PASS!!  golden is %d, inference is %d", $unsigned(count), $unsigned(GOLDEN[count]), $unsigned(index));
      end else begin
        $display("                        image:%d --> ERROR!! golden is %d, inference is %d", $unsigned(count), $unsigned(GOLDEN[count]), $unsigned(index));
      end
      
      count = count + 1;
    end
    
    /*
    $display("");
    $display("");
    $display("              /////////////////////////////////////////////");
    $display("              //                                         //");
    $display("              //         The answer is number %d         //", index);
    $display("              //                                         //");
    $display("              /////////////////////////////////////////////");
    $display("");
    $display("");
    $finish;*/
  end
  $finish;
  end
  
  //////////////////////////////////input weight to system//////////////////////////////////////
  always@(negedge clk)begin
    weight0  <= WEIGHT_MEM[index_for_PE_weight              ];
    weight1  <= WEIGHT_MEM[index_for_PE_weight+W_COL        ];
    weight2  <= WEIGHT_MEM[index_for_PE_weight+W_COL*2      ];
    weight3  <= WEIGHT_MEM[index_for_PE_weight+W_COL*3      ];
    weight4  <= WEIGHT_MEM[index_for_PE_weight+        8'd4 ];
    weight5  <= WEIGHT_MEM[index_for_PE_weight+W_COL  +8'd4 ];
    weight6  <= WEIGHT_MEM[index_for_PE_weight+W_COL*2+8'd4 ];
    weight7  <= WEIGHT_MEM[index_for_PE_weight+W_COL*3+8'd4 ];
    weight8  <= WEIGHT_MEM[index_for_PE_weight+        8'd8 ];
    weight9  <= WEIGHT_MEM[index_for_PE_weight+W_COL  +8'd8 ];
    weight10 <= WEIGHT_MEM[index_for_PE_weight+W_COL*2+8'd8 ];
    weight11 <= WEIGHT_MEM[index_for_PE_weight+W_COL*3+8'd8 ];
    weight12 <= WEIGHT_MEM[index_for_PE_weight+        8'd12];
    weight13 <= WEIGHT_MEM[index_for_PE_weight+W_COL  +8'd12];
    weight14 <= WEIGHT_MEM[index_for_PE_weight+W_COL*2+8'd12];
    weight15 <= WEIGHT_MEM[index_for_PE_weight+W_COL*3+8'd12];
  end
  
  //////////////////////////////////input ifmap to system//////////////////////////////////////
  always@(negedge clk)begin
    ifmap0  <= IFMAP_MEM[index_for_PE_ifmap              ];
    ifmap4  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*4      ];
    ifmap8  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*8      ];
    ifmap12 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*12     ];
    ifmap1  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*1 -8'd1];
    ifmap5  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*5 -8'd1];
    ifmap9  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*9 -8'd1];
    ifmap13 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*13-8'd1];
    ifmap2  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*2 -8'd2];
    ifmap6  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*6 -8'd2];
    ifmap10 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*10-8'd2];
    ifmap14 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*14-8'd2];
    ifmap3  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*3 -8'd3];
    ifmap7  <= IFMAP_MEM[index_for_PE_ifmap+X_COL*7 -8'd3];
    ifmap11 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*11-8'd3];
    ifmap15 <= IFMAP_MEM[index_for_PE_ifmap+X_COL*15-8'd3];
  end
  
  //////////////////////////////////output ofmap to tb//////////////////////////////////////
  always@(negedge clk)begin
    add_i1 <= RAM[read_addr        ];
    add_i2 <= RAM[read_addr+X_COL  ];
    add_i3 <= RAM[read_addr+X_COL*2];
    add_i4 <= RAM[read_addr+X_COL*3];
    if(valid)begin
      if(weight_ifmap_loop==WEIGHT_IFMP_LOOP_REG)begin
        MAX_MEM[write_addr          ] <= ofmap0;
        MAX_MEM[write_addr+M_X_COL  ] <= ofmap1;
        MAX_MEM[write_addr+M_X_COL*2] <= ofmap2;
        MAX_MEM[write_addr+M_X_COL*3] <= ofmap3;
      end else begin
        RAM[write_addr        ] <= ofmap0;
        RAM[write_addr+X_COL  ] <= ofmap1;
        RAM[write_addr+X_COL*2] <= ofmap2;
        RAM[write_addr+X_COL*3] <= ofmap3;
      end
    end
  end
  
/*
  initial begin
    wait(done);
    if(correct==3'd6)begin
      $display("");
      $display("");
      $display("              /////////////////////////////////////////////");
			$display("              //                                         //");
			$display("              //            CONGRATULATION!!             //");
			$display("              //          All data is correct!!          //");
			$display("              //                                         //");
		  $display("              /////////////////////////////////////////////");
		  $display("");
		  $display("");
    end
    else begin
      $display("");
		  $display("");
		  $display("              /////////////////////////////////////////////");
			$display("              //                                         //");
			$display("              //                 SOORY!!                 //");
			$display("              //        The result is incorrect!!        //");
			$display("              //                                         //");
		  $display("              /////////////////////////////////////////////");
		  $display("");
		  $display("");
    end
    $finish;
  end
*/
  
endmodule
