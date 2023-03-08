module controller(
  input clk_i,
  input rst_ni,
  input [ 2:0]  PE_ARRAY_COL_i,
  input [ 4:0]  PE_COL_ROW_i,
  input [ 5:0]  WEIGHT_LOOP_i,
  input [ 5:0]  WEIGHT_IFMP_LOOP_i,
  input [10:0]  PE_ARRAY_FINISH_i,
  input [11:0]  PE_ARRAY_FINISH_SIZE_i,
  input [11:0]  PE_ARRAY_FINISH_SIZE_M_i,
  input [10:0]  THREE_ROW_WEIGHT_SIZE_i,
  input [13:0]  EIGHT_ROW_IFMAP_SIZE_i,
  
  output reg valid_o,
  output reg [ 5:0] weight_ifmap_loop,
  output reg [11:0] weight_index_o,
  output reg [14:0] ifmap_index_o,
  output reg [12:0] write_addr_o,
  output reg [12:0] read_addr_o,
  output reg done_o,
  output reg [10:0] counter
);
  ////////////////////////////////////configuration  register////////////////////////////////
  reg [ 2:0]  PE_ARRAY_COL;
  reg [ 4:0]  PE_COL_ROW;
  reg [ 5:0]  WEIGHT_LOOP;
  reg [ 5:0]  WEIGHT_IFMP_LOOP;
  reg [10:0]  PE_ARRAY_FINISH;
  reg [11:0]  PE_ARRAY_FINISH_SIZE;
  reg [11:0]  PE_ARRAY_FINISH_SIZE_M;
  reg [10:0]  THREE_ROW_WEIGHT_SIZE;
  reg [13:0]  EIGHT_ROW_IFMAP_SIZE;
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      PE_ARRAY_COL               <= PE_ARRAY_COL_i;
      PE_COL_ROW                 <= PE_COL_ROW_i;
      WEIGHT_LOOP                <= WEIGHT_LOOP_i;
      WEIGHT_IFMP_LOOP           <= WEIGHT_IFMP_LOOP_i;
      PE_ARRAY_FINISH            <= PE_ARRAY_FINISH_i;
      PE_ARRAY_FINISH_SIZE       <= PE_ARRAY_FINISH_SIZE_i;
      PE_ARRAY_FINISH_SIZE_M       <= PE_ARRAY_FINISH_SIZE_M_i;
      THREE_ROW_WEIGHT_SIZE      <= THREE_ROW_WEIGHT_SIZE_i;
      EIGHT_ROW_IFMAP_SIZE       <= EIGHT_ROW_IFMAP_SIZE_i;
    end else begin
      PE_ARRAY_COL               <= PE_ARRAY_COL;
      PE_COL_ROW                 <= PE_COL_ROW;
      WEIGHT_LOOP                <= WEIGHT_LOOP;
      WEIGHT_IFMP_LOOP           <= WEIGHT_IFMP_LOOP;
      PE_ARRAY_FINISH            <= PE_ARRAY_FINISH;
      PE_ARRAY_FINISH_SIZE       <= PE_ARRAY_FINISH_SIZE;
      PE_ARRAY_FINISH_SIZE_M     <= PE_ARRAY_FINISH_SIZE_M;
      THREE_ROW_WEIGHT_SIZE      <= THREE_ROW_WEIGHT_SIZE;
      EIGHT_ROW_IFMAP_SIZE       <= EIGHT_ROW_IFMAP_SIZE;
    end
  end
  //////////////////////////////////////////////////////////////////////////////////////////
  parameter   RST     = 2'b00,
              EXECUTE = 2'b01,
              WAIT    = 2'b11,
              DONE    = 2'b10;
  
  reg valid_o_test;
  reg [12:0] write_addr_o_test;
  
  reg [5:0] weight_loop;
  reg [1:0] state;
  reg [1:0] n_state;
  //reg [10:0] counter;
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      state <= RST;
    end else begin
      state <= n_state;
    end
  end
  
  always@(*)begin
    case(state)
      RST:begin
        done_o = 1'b0;
        n_state = EXECUTE;
      end
      WAIT:begin
        done_o = 1'b0;
        n_state = RST;
      end
      EXECUTE:begin
        done_o = 1'b0;
        n_state = (counter==PE_ARRAY_FINISH && weight_loop==WEIGHT_LOOP && weight_ifmap_loop==WEIGHT_IFMP_LOOP)?DONE:
                  (counter==PE_ARRAY_FINISH)?WAIT:
                  EXECUTE;
      end
      DONE:begin
        done_o = 1'b1;
        n_state = RST;
      end
      default:begin
        done_o = 1'b0;
        n_state = RST;
      end
    endcase
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      counter <= 11'd0;
    end else if(n_state==RST)begin
      counter <= 11'd0;
    end else begin
      counter <= counter + 11'd1;
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      weight_loop       <= 6'd0;
	    weight_ifmap_loop <= 6'd1;
    end else if(state==RST)begin
      if(weight_loop==WEIGHT_LOOP && weight_ifmap_loop<WEIGHT_IFMP_LOOP)begin
        weight_loop <= 6'd1;
        weight_ifmap_loop <= weight_ifmap_loop + 6'd1;
      end else begin
        weight_loop <= weight_loop + 6'd1;
        weight_ifmap_loop <= weight_ifmap_loop;
      end
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      weight_index_o <= 12'd0;
    end else if(counter>PE_ARRAY_FINISH)begin//end else if(counter==PE_ARRAY_FINISH)begin
      if(weight_loop==WEIGHT_LOOP)begin
        weight_index_o <= PE_COL_ROW * weight_ifmap_loop;
      end else begin
        weight_index_o <= weight_loop * THREE_ROW_WEIGHT_SIZE + (weight_ifmap_loop-1)*PE_COL_ROW;
      end
    end else begin
      weight_index_o <= weight_index_o + 12'd1;
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      ifmap_index_o <= 15'd0;
    end else if(counter>PE_ARRAY_FINISH)begin//end else if(counter==PE_ARRAY_FINISH)begin
      if(weight_loop==WEIGHT_LOOP)begin
        ifmap_index_o <= weight_ifmap_loop * EIGHT_ROW_IFMAP_SIZE;
      end else begin
        ifmap_index_o <= (weight_ifmap_loop-1) * EIGHT_ROW_IFMAP_SIZE;
      end
    end else begin
      ifmap_index_o <= ifmap_index_o + 15'd1;
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      valid_o <= 1'b0;
    end else if(weight_ifmap_loop==WEIGHT_IFMP_LOOP && PE_ARRAY_FINISH!=11'd5)begin
      valid_o <= (counter[1:0]==2'b11&&counter!=11'd3&&counter<PE_ARRAY_FINISH_SIZE_M+12'd5)?1'b1:1'b0;
    end else begin
      valid_o <= (counter>=PE_ARRAY_COL && counter<PE_ARRAY_FINISH)?1'b1:1'b0;
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      write_addr_o <= 13'd0;
    end else if(valid_o)begin//end else if(counter<PE_ARRAY_FINISH && valid_o)begin
      write_addr_o <= write_addr_o + 13'd1;
    end else if(counter==11'd1)begin
      if(weight_ifmap_loop!=WEIGHT_IFMP_LOOP)begin
        write_addr_o <= (weight_loop-4'd1) * PE_ARRAY_FINISH_SIZE;
      end else begin
        write_addr_o <= (weight_loop-4'd1) * PE_ARRAY_FINISH_SIZE_M;
      end
    end
  end
  
  always@(posedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
      read_addr_o <= 13'd0;
    end else if(weight_loop==WEIGHT_LOOP && weight_ifmap_loop<WEIGHT_IFMP_LOOP && state==RST)begin
      read_addr_o <= 13'd0;
    end else if(state==RST)begin
      read_addr_o <= weight_loop * PE_ARRAY_FINISH_SIZE;
    end else begin
      read_addr_o <= read_addr_o + 13'd1;
    end
  end
  
endmodule