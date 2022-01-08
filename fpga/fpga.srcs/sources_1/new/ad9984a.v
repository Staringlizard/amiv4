`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2021 12:14:22 PM
// Design Name: 
// Module Name: AD9984A
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


module ad9984a(
    input wire i_fifo_clk,
    input wire [7:0] i_red,
    input wire [7:0] i_green,
    input wire [7:0] i_blue,
    input wire i_hs,
    input wire i_vs,
    input wire i_oe,
    input wire i_pixel_clk,
    output wire o_pixel_write,
    input wire i_pixel_write_done,
    output wire [18:0] o_pixel_addr_write,
    output wire [15:0] o_data_write,
    input wire i_sram_read_mode,
    output wire o_temp
    );

localparam IN_FRAME_PER_SECOND = 'd50;
localparam IN_HORIZONTAL_BLANKING = 'd170;
//localparam IN_HORIZONTAL_BLANKING = 'd0;
localparam IN_VERTICAL_BLANKING = 'd30;
localparam IN_HORIZONTAL_BLANKING_OFFSET = 'd40;
localparam IN_VERTICAL_BLANKING_OFFSET = 'd15;
localparam SRAM_WIDTH = 'd640;
localparam SRAM_HEIGHT = 'd580;

reg [3:0] state;
reg [3:0] state_next;
reg [15:0] fifo_to_sram_data_temp;

reg sram_pixel_write;
reg sram_pixel_write_next;

reg [9:0] counter_x;
reg [9:0] counter_x_next;
reg [9:0] counter_y;
reg [9:0] counter_y_next;


reg bram_ena;
reg bram_ena_next;
reg [0:0] bram_wea;
reg [0:0] bram_wea_next;
reg [18:0] bram_addra;
reg [18:0] bram_addra_next;

reg [15:0] bram_dina;
reg [15:0] bram_dina_next;
reg bram_enb = 1'b1;
reg [18:0] bram_addrb;
reg [18:0] bram_addrb_next;
reg [15:0] bram_doutb;
reg [15:0] bram_doutb_next;

reg sram_pixel_saved;
reg sram_pixel_saved_next;

reg pixel_waiting;
reg pixel_waiting_next;

reg pixel_clk;
reg pixel_clk_next;

reg pixel_clk_prev;
reg pixel_clk_prev_next;

reg hs;

reg t;
reg t_next;

localparam [3:0] state_0 = 3'b000,
				 state_1 = 3'b001,
				 state_2 = 3'b010,
				 state_3 = 3'b011,
				 state_4 = 3'b100,
				 state_5 = 3'b101,
				 state_6 = 3'b110,
				 state_7 = 3'b111;

/* Keep track of pixels */
always @ (posedge i_pixel_clk)
begin
    counter_x <= counter_x_next;
    bram_dina <= bram_dina_next;
    bram_addrb <= bram_addrb_next;
end

always @*
begin
    counter_x_next = counter_x;
    bram_addrb_next = bram_addrb;

    if(i_hs == 1'b0) begin
        counter_x_next = 0;
    end else begin
        counter_x_next = counter_x + 1;
    end
    
    /*bram_dina_next[15:11] = i_red[7:3];
    bram_dina_next[10:5] = i_green[7:2];
    bram_dina_next[4:0] = i_blue[7:3];*/
    bram_dina_next[15:13] = i_red[7:5];
    bram_dina_next[12:11] = i_green[7:6];
    bram_dina_next[10:8] = i_blue[7:5];
    
    if(counter_x >= IN_HORIZONTAL_BLANKING && counter_x < (SRAM_WIDTH + IN_HORIZONTAL_BLANKING) &&
       counter_y >= IN_VERTICAL_BLANKING && counter_y < (SRAM_HEIGHT/2) + IN_VERTICAL_BLANKING) begin
        bram_addrb_next = (counter_y - IN_VERTICAL_BLANKING) * (SRAM_WIDTH) + counter_x - IN_HORIZONTAL_BLANKING;
    end else begin
        bram_addrb_next = 0;
    end
    
end

always @ (posedge i_hs)
begin
	counter_y <= counter_y_next;
	t <= t_next;
end

always @*
begin
        t_next = t;
        counter_y_next = counter_y;

        if(i_vs == 1'b0) begin
            counter_y_next = 0;
        end else begin
            counter_y_next = counter_y + 1'b1;
        end

end

/* Read out pixel from fifo and store it in sram */
always @ (posedge i_fifo_clk)
begin
    state <= state_next;
    //bram_addra <= bram_addra_next;
    
    bram_doutb <= bram_doutb_next;
    sram_pixel_write <= sram_pixel_write_next;
    pixel_clk <= i_pixel_clk;
    pixel_clk_prev <= pixel_clk;
    
    if(pixel_clk == 1'b1 && pixel_clk != pixel_clk_prev && sram_pixel_saved == 0) begin
        sram_pixel_saved <= 1'b1;
        t_next = 1'b1;
    end else begin
        sram_pixel_saved <= sram_pixel_saved_next;
        t_next = 1'b0;
    end
    
end

always @*
begin
    state_next = state;
    sram_pixel_write_next = sram_pixel_write;

    //bram_addra_next = bram_addra;
    bram_doutb_next = bram_doutb;
    sram_pixel_saved_next = sram_pixel_saved;

    case(state)
	state_0:
	begin
        if(sram_pixel_saved == 1'b1) begin
            sram_pixel_saved_next = 1'b0;
            sram_pixel_write_next = 1'b1;
            bram_doutb_next = bram_dina;
            state_next = state_1;
       end
    end
	state_1:
	begin
	   if(i_pixel_write_done == 1'b1) begin
            state_next = state_0;
            sram_pixel_write_next = 1'b0;
       end
    end
	state_2:
	begin
        state_next = state_0;
    end
	default:
		begin
		end
	endcase
end

/*
BRAM BRAM_inst (
    .clka(i_fifo_clk),
    .wea(1'b1),
    .addra(bram_addra),
    .dina(bram_dina),
    .clkb(i_fifo_clk),
    .addrb(bram_addrb),
    .doutb(bram_doutb)
);*/

assign o_pixel_write = sram_pixel_write;
assign o_pixel_addr_write = bram_addrb;
assign o_data_write = bram_doutb; /* fifo_to_sram_data;*/
assign o_temp = t;
endmodule




/* 

AMIV_I2C_WR_Reg(0x1, 0x36); 
		AMIV_I2C_WR_Reg(0x2, 0x00); 
		AMIV_I2C_WR_Reg(0x3, 0x00);
		AMIV_I2C_WR_Reg(0x4, 0x78); 

	
		AMIV_I2C_WR_Reg(0x5, 0x00);
		AMIV_I2C_WR_Reg(0x6, 0x80);
		AMIV_I2C_WR_Reg(0x7, 0x00);
		AMIV_I2C_WR_Reg(0x8, 0x80);
		AMIV_I2C_WR_Reg(0x9, 0x00);
		AMIV_I2C_WR_Reg(0xA, 0x80);


		AMIV_I2C_WR_Reg(0xB, 0x00);
		AMIV_I2C_WR_Reg(0xC, 0x80);
		AMIV_I2C_WR_Reg(0xD, 0x00);
		AMIV_I2C_WR_Reg(0xE, 0x80);
		AMIV_I2C_WR_Reg(0xF, 0x00);
		AMIV_I2C_WR_Reg(0x10, 0x80);


		AMIV_I2C_WR_Reg(0x11, 0x20);
		AMIV_I2C_WR_Reg(0x12, 0x80);
		AMIV_I2C_WR_Reg(0x13, 0x20);
		AMIV_I2C_WR_Reg(0x14, 0x80);
		AMIV_I2C_WR_Reg(0x15, 0x0A);
		AMIV_I2C_WR_Reg(0x16, 0x00);
		AMIV_I2C_WR_Reg(0x17, 0x00);
		AMIV_I2C_WR_Reg(0x18, 0x80);
		AMIV_I2C_WR_Reg(0x19, 0x08);
		AMIV_I2C_WR_Reg(0x1A, 0x20);


		AMIV_I2C_WR_Reg(0x1B, 0xF7);


		AMIV_I2C_WR_Reg(0x1C, 0xFF);
		AMIV_I2C_WR_Reg(0x1D, 0x79);
		AMIV_I2C_WR_Reg(0x1E, 0x34);


		AMIV_I2C_WR_Reg(0x1F, 0x90);


		AMIV_I2C_WR_Reg(0x20, 0x07);


		AMIV_I2C_WR_Reg(0x21, 0x20);
		AMIV_I2C_WR_Reg(0x22, 0x32);
		AMIV_I2C_WR_Reg(0x23, 0x14);
		AMIV_I2C_WR_Reg(0x24, 0x08);
		AMIV_I2C_WR_Reg(0x25, 0x7F);
		AMIV_I2C_WR_Reg(0x26, 0x10);
		AMIV_I2C_WR_Reg(0x27, 0x70);
		AMIV_I2C_WR_Reg(0x28, 0xBF);
		AMIV_I2C_WR_Reg(0x29, 0x02);
		AMIV_I2C_WR_Reg(0x2A, 0x00);
		AMIV_I2C_WR_Reg(0x2B, 0x00);
		AMIV_I2C_WR_Reg(0x2C, 0x00);
		AMIV_I2C_WR_Reg(0x2D, 0xE8);
		AMIV_I2C_WR_Reg(0x2E, 0xE0);
		AMIV_I2C_WR_Reg(0x36, 0x01);


		AMIV_I2C_WR_Reg(0x3C, 0x00);
		
		*/