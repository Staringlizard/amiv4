`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2021 01:21:06 PM
// Design Name: 
// Module Name: SRAM
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


module sram(
    input wire i_clk,
    //input wire i_btn,
    output wire [18:0] o_addr,
    inout wire [7:0] io_data,
    output wire o_oe_n,
    output wire o_we_n,
    output wire o_ce_n,
    input wire i_pixel_read,
    input wire i_pixel_write,
    output wire o_pixel_read_done,
    output wire o_pixel_write_done,
    input wire [15:0] i_data_write,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    input wire [18:0] i_pixel_addr_read,
    input wire [18:0] i_pixel_addr_write,
    input wire i_read_mode//,
    //output wire o_temp
    );

localparam [4:0] state_0 = 3'b000,
				 state_1 = 3'b001,
				 state_2 = 3'b010,
				 state_3 = 3'b011,
				 state_4 = 3'b100,
				 state_5 = 3'b101,
				 state_6 = 3'b110,
				 state_7 = 3'b111;

reg [4:0] state;
reg [4:0] state_next;
reg [7:0] data_red;
reg [7:0] data_green;
reg [7:0] data_blue;
reg [7:0] data_red_next;
reg [7:0] data_green_next;
reg [7:0] data_blue_next;

reg [7:0] byte_first;
reg [7:0] byte_first_next;
reg [7:0] byte_second;
reg [7:0] byte_second_next;
reg [7:0] byte_to_write;
reg [7:0] byte_to_write_next;
reg reading_in_progress;
reg reading_in_progress_next;

reg [18:0] addr_write;
reg [18:0] addr_write_next;
reg [18:0] addr_read;
reg [18:0] addr_read_next;

reg [18:0] addr;
reg [18:0] addr_next;

reg we_n;
reg we_n_next;

reg pixel_read_done;
reg pixel_read_done_next;

reg pixel_write_done;
reg pixel_write_done_next;

reg t;
reg t_next;

reg pixel_read;
reg pixel_read_next;


always @ (posedge i_clk)
begin
    state <= state_next;
    byte_first <= byte_first_next;
    byte_second <= byte_second_next;
    data_red <= data_red_next;
    data_green <= data_green_next;
    data_blue <= data_blue_next;
    byte_to_write <= byte_to_write_next;
    addr_write <= addr_write_next;
    addr_read <= addr_read_next;
    we_n <= we_n_next;
    pixel_read_done <= pixel_read_done_next;
    pixel_write_done <= pixel_write_done_next;
    addr <= addr_next;
    t <= t_next;
    //pixel_read <= i_pixel_read;
end


always @*
begin
    state_next = state_0;
    byte_first_next = byte_first;
    byte_second_next = byte_second;
    data_red_next = data_red;
    data_green_next = data_green;
    data_blue_next = data_blue;
    addr_write_next = addr_write;
    addr_read_next = addr_read;
    we_n_next = 1'b1;
    byte_to_write_next = byte_to_write;
    pixel_read_done_next = 1'b0;
    pixel_write_done_next = 1'b0;
    addr_next = addr;
    t_next = t;

    case(state)
	state_0:
    begin
        if(i_pixel_read == 1'b1) begin
            state_next = state_1;
            addr_next = i_pixel_addr_read;
        end else if(i_pixel_write == 1'b1/* && i_btn == 1'b0*/) begin
            state_next = state_3;
            we_n_next = 1'b0;
            t_next = 1'b1;
            addr_next = i_pixel_addr_write;
        end
    end
	state_1:
	begin
        state_next = state_2;
    end
	state_2:
    begin
        state_next = state_0;
        data_red_next[7:5] = io_data[7:5];
        data_red_next[4:0] = 0;
        data_green_next[7:6] = io_data[4:3];
        data_green_next[5:0] = 0;
        data_blue_next[7:5] = io_data[2:0];
        data_blue_next[4:0] = 0;
        pixel_read_done_next = 1'b1;
    end
    state_3:
    begin
        state_next = state_4;
        we_n_next = 1'b0;
        byte_to_write_next[7:0] = i_data_write[15:8];

    end
	state_4:
    begin
        state_next = state_5;
    end
	state_5:
    begin
        state_next = state_0;
        pixel_write_done_next = 1'b1;
    end
	default:
		begin
		end
	endcase
end

assign o_red = (i_read_mode == 1'b1) ? data_red : 0;
assign o_green = (i_read_mode == 1'b1) ? data_green : 0;
assign o_blue = (i_read_mode == 1'b1) ? data_blue : 0;
assign o_addr = addr;/*(!o_we_n) ? addr_write_next : addr_read_next;*/
assign o_ce_n = 1'b0;
assign o_oe_n = 1'b0;
assign o_we_n = we_n;
assign io_data = (!o_we_n) ? byte_to_write : 8'hZZ;
assign o_pixel_read_done = pixel_read_done;
assign o_pixel_write_done = pixel_write_done;

//assign o_temp = t;

endmodule
