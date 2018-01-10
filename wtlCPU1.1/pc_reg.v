`include "defines.v"

module pc_reg(

	input	wire										clk,
	input wire										rst,
	
	input wire[5:0]               stall,
	
	output reg[`InstAddrBus]			pc,
	output reg                    ce
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;
		end else if(stall[0] == `NoStop) begin
	 		pc <= pc + 4'h4;
		end
	end
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule