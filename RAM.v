module RAM(clk, rst_n, din, rx_valid, dout, tx_valid);
	
	parameter MEM_DEPTH = 256;
	parameter ADDR_SIZE = 8;
	input clk, rst_n, rx_valid;
	input [9:0] din;
	output reg tx_valid;
	output reg [7:0] dout;
	reg [ADDR_SIZE-1:0] wr_add, rd_add;
	reg [7:0] mem [MEM_DEPTH-1:0];
	always @(posedge clk or negedge rst_n) begin
		tx_valid <= 0;
		if (~rst_n) 
			dout <= 0;
		else begin
			if (rx_valid) begin
				case (din[9:8])
					2'b00 : wr_add <= din[7:0];
					2'b01 : mem[wr_add] <= din[7:0];
					2'b10 : begin rd_add <= din[7:0]; tx_valid <= 1; end
					2'b11 : begin dout <= mem[rd_add]; tx_valid <= 1; end
				endcase
			end
		end
	end


endmodule