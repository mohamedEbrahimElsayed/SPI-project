module SPI_Wrapper_tb1();

	// signal declaration
	reg clk, rst_n, MOSI, SS_n;
	wire MISO_DUT;
	reg MOSI_temp[9:0];
	// DUT instantiation
	SPI_Wrapper DUT(clk, rst_n, MOSI, MISO_DUT, SS_n);
	// clk generation block
	initial begin
		clk = 0;
		forever
			#1 clk = ~clk;
	end
	// test stimulus
	integer i;
	initial begin
		// test restart operation
		rst_n = 0;
		SS_n = 1;
		MOSI = 0;
		#50;
		// test write address operation
		rst_n = 1;
		SS_n = 0;
		@(negedge clk)
		MOSI = 0;
		@(negedge clk)
		MOSI = 0;  // din[9]
		@(negedge clk)
		MOSI = 0;  // din[8]
		@(negedge clk);
		for (i=0; i<8; i=i+1) begin
			@(negedge clk)
			MOSI = $random;
			MOSI_temp[i] = MOSI;
		end
		SS_n = 1;
		// test write data operation
		@(negedge clk)
		SS_n = 0;
		@(negedge clk)
		MOSI = 0;
		@(negedge clk)
		MOSI = 0;  // din[9]
		@(negedge clk)
		MOSI = 1;  // din[8]
		for (i=0; i<8; i=i+1) begin
			@(negedge clk)
			MOSI = $random;
		end
		SS_n = 1;
		// test read address operation
		@(negedge clk)
		SS_n = 0;
		@(negedge clk)
		MOSI = 1;
		@(negedge clk)
		MOSI = 1;  // din[9]
		@(negedge clk)
		MOSI = 0;  // din[8]
		for (i=0; i<8; i=i+1) begin
			@(negedge clk)
			MOSI = MOSI_temp[i];
		end
		SS_n = 1;
		// test read data operation
		@(negedge clk)
		SS_n = 0;
		@(negedge clk)
		MOSI = 1;
		@(negedge clk)
		MOSI = 1;  // din[9]
		@(negedge clk)
		MOSI = 1;  // din[8]
		for (i=0; i<8; i=i+1) begin
			@(negedge clk)
			MOSI = $random;
		end
		#10 $stop;
	end


endmodule