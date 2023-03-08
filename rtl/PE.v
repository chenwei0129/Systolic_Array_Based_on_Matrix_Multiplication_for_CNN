module PE(clk_i, weight_en, weight_i, ifmap_i, psum_i, ofmap_o);

  input clk_i;
  input weight_en;
  input signed [`TOTAL_BIT-1:0] weight_i;
  input signed [`TOTAL_BIT-1:0] ifmap_i;
  input signed [`TOTAL_BIT-1:0] psum_i;
  
  output reg signed [`TOTAL_BIT-1:0] ofmap_o;
  
  wire signed [2*`TOTAL_BIT-1:0] temp1;
  wire signed [`TOTAL_BIT-1:0] temp2;
  reg signed [`TOTAL_BIT-1:0] weight_reg;
  
  assign temp1 = ifmap_i * weight_reg;
  //wire sign = (ifmap_i!=`TOTAL_BIT'd0 && weight_reg!=`TOTAL_BIT'd0)?ifmap_i[`TOTAL_BIT-1] ^ weight_reg[`TOTAL_BIT-1]:1'b0;
  assign temp2 = {temp1[2*`TOTAL_BIT-1], temp1[`FLOAT_BIT + `TOTAL_BIT-2:`FLOAT_BIT]};
  
  always@(posedge clk_i)begin
    if(weight_en)begin
      weight_reg <= weight_i;
    end else begin
      ofmap_o <= temp2 + psum_i;
    end
  end
  
endmodule