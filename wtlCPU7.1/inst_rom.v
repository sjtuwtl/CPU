`include "defines.v"

module inst_rom(

//	input	wire										clk,
	input wire                    ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]					inst
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];
	reg[31:0] inster;
	reg[31:0] reinst;
	initial $readmemh ( "inst_rom.data", inst_mem );

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  //inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		  inster <= inst_mem[addr[`InstMemNumLog2+1:2]];
		  reinst[31:24] <= inster[7:0];
		  reinst[23:16] <= inster[15:8];
		  reinst[15:8] <= inster[23:16];
		  reinst[7:0] <= inster[31:24];
		  inst <= reinst;
		end
	end

endmodule