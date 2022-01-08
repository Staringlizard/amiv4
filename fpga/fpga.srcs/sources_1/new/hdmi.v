`timescale 1ns / 1ns
module hdmi(
	input wire i_pixclk,
	input wire i_pixclk_hs,
	input wire i_pixclk_sram,
	input wire i_rst_n,
	input wire i_btn,
	input wire [7:0] i_red,
	input wire [7:0] i_green,
	input wire [7:0] i_blue,
	output wire [18:0] o_pixel_addr,
	output wire o_sram_pixel_read,
	input wire i_sram_pixel_read_done,
    output wire o_tmds_red_p,
    output wire o_tmds_red_n,
    output wire o_tmds_green_p,
    output wire o_tmds_green_n,
    output wire o_tmds_blue_p,
    output wire o_tmds_blue_n,
    output wire o_tmds_clk_p,
    output wire o_tmds_clk_n,
    output wire o_sram_read_mode,
    output wire o_temp
);

localparam SRAM_WIDTH = 'd640;
localparam SRAM_HEIGHT = 'd580;
localparam OFFSET = 'd2;

wire [9:0] tmds_red;
wire [9:0] tmds_green;
wire [9:0] tmds_blue;
wire ser_red;
wire ser_green;
wire ser_blue;
wire ser_clk;

reg [18:0] pixel_addr;
reg [18:0] pixel_addr_next;
reg [9:0] counter_x;
reg [9:0] counter_y;
reg [3:0] divider;
reg sram_read_mode;
reg sram_read_mode_next;
reg draw_area;
reg test_area;
reg pixel_read;
reg hs;
reg vs;

reg [7:0] red;
reg [7:0] green;
reg [7:0] blue;

reg [7:0] red_next;
reg [7:0] green_next;
reg [7:0] blue_next;

reg button;
reg button_next;
reg button_prev;
reg button_prev_next;

reg [9:0] offset;
reg [9:0] offset_next;

reg t;
reg t_next;

serializer serializer_red_inst(
    .pixclk(i_pixclk),
    .pixclk_hs(i_pixclk_hs),
    .data(tmds_red),
    .rst_n(i_rst_n),
    .ser_dat(ser_red)
);

serializer serializer_green_inst(
    .pixclk(i_pixclk),
    .pixclk_hs(i_pixclk_hs),
    .data(tmds_green),
    .rst_n(i_rst_n),
    .ser_dat(ser_green)
);

serializer serializer_blue_inst(
    .pixclk(i_pixclk),
    .pixclk_hs(i_pixclk_hs),
    .data(tmds_blue),
    .rst_n(i_rst_n),
    .ser_dat(ser_blue)
);

serializer serializer_clk_inst(
    .pixclk(i_pixclk),
    .pixclk_hs(i_pixclk_hs),
    .data(10'b11111_00000),
    .rst_n(i_rst_n),
    .ser_dat(ser_clk)
);

always @(posedge i_pixclk_sram)
begin
    red <= red_next;
    green <= green_next;
    blue <= blue_next;
    
    button <= button_next;
    button_prev <= button;
    offset <= offset_next;

    if(divider == 9) begin
        draw_area <= (counter_x < 640) && (counter_y < 480);
        test_area <= (counter_x < SRAM_WIDTH) && (counter_y < SRAM_HEIGHT/2);
        counter_x <= (counter_x == 799) ? 0 : counter_x + 1;
        if(counter_x == 799) counter_y <= (counter_y == 524) ? 0 : counter_y + 1;
        hs <= (counter_x >= 656) && (counter_x < 752);
        vs <= (counter_y >= 490) && (counter_y < 492);
        pixel_addr <= pixel_addr_next;
        sram_read_mode <= sram_read_mode_next;
        pixel_read <= 1'b1;
        divider <= 0;
        t <= 1'b1;

    end else begin
        divider <= divider + 1;
        if(i_sram_pixel_read_done == 1'b1) begin
            pixel_read <= 1'b0;
            t <= 1'b0;
        end
    end
    
    
end

always @*
begin
    red_next = red;
    green_next = green;
    blue_next = blue;
    button_next = button;
    button_prev_next = button_prev;
    offset_next = offset;
    
    if(button == 1'b0 && i_btn == 1'b1) begin
        button_next = 1'b1;
    end
    
    if(button == 1'b1 && i_btn == 1'b0) begin
        offset_next = offset + 1;
        button_next = 1'b0;
    end

    if(test_area == 1'b1) begin
        //pixel_addr_next = counter_x + (counter_y * (SRAM_WIDTH + OFFSET) + OFFSET);
        pixel_addr_next = counter_x + (counter_y * (SRAM_WIDTH/* + offset*/)/* + offset*/);
        sram_read_mode_next = 1'b1;
        
        red_next = i_red;
        green_next = i_green;
        blue_next = i_blue;
    end else begin
        pixel_addr_next = 0;
        sram_read_mode_next = 1'b0;
        red_next = 0;
        green_next = 0;
        blue_next = 0;
    end
end

TMDS_encoder encode_R(.clk(i_pixclk), .VD( red ), .CD(2'b00)    , .VDE(draw_area), .TMDS(tmds_red));
TMDS_encoder encode_G(.clk(i_pixclk), .VD( green ), .CD(2'b00)    , .VDE(draw_area), .TMDS(tmds_green));
TMDS_encoder encode_B(.clk(i_pixclk), .VD( blue ), .CD({vs, hs}) , .VDE(draw_area), .TMDS(tmds_blue));

OBUFDS OBUFDS_red  (.I(ser_red),   .O(o_tmds_red_p),   .OB(o_tmds_red_n));
OBUFDS OBUFDS_green(.I(ser_green), .O(o_tmds_green_p), .OB(o_tmds_green_n));
OBUFDS OBUFDS_blue (.I(ser_blue),  .O(o_tmds_blue_p),  .OB(o_tmds_blue_n));
OBUFDS OBUFDS_clock(.I(ser_clk),   .O(o_tmds_clk_p),   .OB(o_tmds_clk_n));

assign o_sram_pixel_read = pixel_read;
assign o_pixel_addr = pixel_addr;
assign o_sram_read_mode = sram_read_mode;

assign o_temp = t;
endmodule






////////////////////////////////////////////////////////////////////////
