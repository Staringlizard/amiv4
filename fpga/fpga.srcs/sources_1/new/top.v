`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2020 08:38:24 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
        input wire sysclk,
        input wire rst,
        input wire btn,
        output wire tempa,
        output wire tempb,
        output wire tmds_red_p,
        output wire tmds_red_n,
        output wire tmds_green_p,
        output wire tmds_green_n,
        output wire tmds_blue_p,
        output wire tmds_blue_n,
        output wire tmds_clk_p,
        output wire tmds_clk_n,
        input wire [7:0] ad9984a_red,
        input wire [7:0] ad9984a_green,
        input wire [7:0] ad9984a_blue,
        input wire ad9984a_hs,
        input wire ad9984a_vs,
        input wire ad9984a_oe,
        input wire ad9984a_pixel_clk,
        output wire [18:0] sram_addr,
        inout wire [7:0] sram_data,
        output wire sram_n_oe,
        output wire sram_n_we,
        output wire sram_n_ce
);
reg rst_n = 1;

wire [7:0] sram_read_red;
wire [7:0] sram_read_green;
wire [7:0] sram_read_blue;
wire sram_pixel_read;
wire sram_pixel_write;
wire sram_pixel_read_done;
wire sram_pixel_write_done;
wire sram_read_mode;
wire [18:0] pixel_addr_read;
wire [18:0] pixel_addr_write;
wire [15:0] sram_data_write;
wire hdmi_clk;
wire hdmi_clk_hs;
wire sram_clk;
wire btn;

always @(posedge hdmi_clk)
begin
    rst_n <= !rst;
end

clk_gen clk_gen_inst (
	.clk_out1(hdmi_clk),
	.clk_out2(hdmi_clk_hs),
	.clk_out3(sram_clk),
	.resetn(rst_n),
	.clk_in1(sysclk)
	);

hdmi hdmi_inst (
    .i_pixclk(hdmi_clk),
    .i_pixclk_hs(hdmi_clk_hs),
    .i_pixclk_sram(sram_clk),
    .i_rst_n(rst_n),
    .i_btn(btn),
	.i_red(sram_read_red),
	.i_green(sram_read_green),
	.i_blue(sram_read_blue),
	.o_pixel_addr(pixel_addr_read),
	.o_sram_pixel_read(sram_pixel_read),
	.i_sram_pixel_read_done(sram_pixel_read_done),
    .o_tmds_red_p(tmds_red_p),
    .o_tmds_red_n(tmds_red_n),
    .o_tmds_green_p(tmds_green_p),
    .o_tmds_green_n(tmds_green_n),
    .o_tmds_blue_p(tmds_blue_p),
    .o_tmds_blue_n(tmds_blue_n),
    .o_tmds_clk_p(tmds_clk_p),
    .o_tmds_clk_n(tmds_clk_n),
    .o_sram_read_mode(sram_read_mode),
    .o_temp(tempb)
);

ad9984a ad9984a_inst (
    .i_fifo_clk(sram_clk),
    .i_red(ad9984a_red),
    .i_green(ad9984a_green),
    .i_blue(ad9984a_blue),
    .i_hs(ad9984a_hs),
    .i_vs(ad9984a_vs),
    .i_oe(ad9984a_oe),
    .i_pixel_clk(ad9984a_pixel_clk),
    .o_pixel_write(sram_pixel_write),
    .i_pixel_write_done(sram_pixel_write_done),
    .o_pixel_addr_write(pixel_addr_write),
    .o_data_write(sram_data_write),
    .i_sram_read_mode(sram_read_mode),
    .o_temp(tempa)
);

sram sram_inst (
    .i_clk(sram_clk),
    //.i_btn(btn),
    .o_addr(sram_addr),
    .io_data(sram_data),
    .o_oe_n(sram_n_oe),
    .o_we_n(sram_n_we),
    .o_ce_n(sram_n_ce),
    .i_pixel_read(sram_pixel_read),
    .i_pixel_write(sram_pixel_write),
    .o_pixel_read_done(sram_pixel_read_done),
    .o_pixel_write_done(sram_pixel_write_done),
    .i_data_write(sram_data_write),
    .o_red(sram_read_red),
    .o_green(sram_read_green),
    .o_blue(sram_read_blue),
    .i_pixel_addr_read(pixel_addr_read),
    .i_pixel_addr_write(pixel_addr_write),
    .i_read_mode(sram_read_mode)//,
    //.o_temp(tempb)
);

endmodule
