module SPI_Slave(MOSI, MISO, SS_n, clk, rst_n, rx_data, rx_valid, tx_data, tx_valid);
	// parameters for the states
	parameter IDLE = 3'b000;
	parameter CHK_CMD = 3'b001;
	parameter WRITE = 3'b010;
	parameter READ_ADD = 3'b011;
	parameter READ_DATA = 3'b100;
	// signals declaration
	input MOSI, SS_n, clk, rst_n, tx_valid;
	input [7:0] tx_data;
	output reg rx_valid, MISO;
	output reg [9:0] rx_data;
	// wires for current and next state
	reg [2:0] CS, NS;
	// wire to memorize which read stste (READ_ADD or READ_DATA) 
	reg read_add_state_n = 1'b0;
	// counter for output
	reg [3:0] counter1 = 4'd9;
	reg [2:0] counter2 = 3'd7;
	reg [9:0] temp;

	// state memory
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			CS <= IDLE; 
		else 
			CS <= NS;
	end
	// next state logic
	always @(*) begin
		read_add_state_n = 1'b0;
		case (CS)
			IDLE :
				begin
					if (SS_n)
						NS = IDLE;
					else if (~SS_n)
						NS = CHK_CMD;
				end
			CHK_CMD : 
				begin
					if (SS_n)
						NS = IDLE;
					else if (~SS_n && ~MOSI)
						NS = WRITE;
					else if (~SS_n && MOSI && ~read_add_state_n) begin
						NS = READ_ADD;
						read_add_state_n = 1'b1;
					end
					else if (~SS_n && MOSI && read_add_state_n) begin
						NS = READ_DATA;
					end
				end
			READ_ADD :
				begin
					if (SS_n)
						NS = IDLE;
					else if (~SS_n)
						NS = READ_ADD;
				end
			READ_DATA :
				begin
					if (SS_n)
						NS = IDLE;
					else if (~SS_n)
						NS = READ_DATA;
				end
			WRITE :
				begin
					if (SS_n)
						NS = IDLE;
					else if (~SS_n)
						NS = WRITE;
				end
		endcase
	end
	// output logic
	always @(posedge clk or negedge rst_n) begin
		rx_valid <= 0;
		if (~rst_n) begin
			rx_valid <= 0;
			temp <= 0;
			counter1 <= 4'd9;
		end
		
		else if ((CS == WRITE) || (CS == READ_ADD) || (CS == READ_DATA) && ~SS_n) begin
			if (counter1 >= 4'd0) begin
				temp[counter1] <= MOSI;
				if (counter1 == 4'd0) begin
					rx_valid <= 1;
					counter1 <= 4'd9;
				end
				else
					counter1 <= counter1 - 1; 
			end
		end
	end

	always @(rx_valid) begin
		if (rx_valid)
			rx_data = temp;
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			MISO <= 0; 
			counter2 <= 3'd7;
		end
		else if (tx_valid) begin
			if (counter2 >= 3'd0) begin
				MISO <= tx_data[counter2];
				if (counter2 == 3'd0) begin
					counter2 <= 3'd7;
				end
				else
					counter2 <= counter2 - 1; 
			end
		end
	end

endmodule