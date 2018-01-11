`include "defines.v"

module openmips_min_sopc(

	input	wire										clk,
	input wire										rst
	
	//output reg[`RegBus]  regs[0:`RegNum-1]
);

	//����ָ��洢��
	wire[`InstAddrBus] inst_addr;
	wire[`InstBus] inst;
	wire rom_ce;
	wire mem_we_i;
	wire[`RegBus] mem_addr_i;
	wire[`RegBus] mem_data_i;
	wire[`RegBus] mem_data_o;
	wire[3:0] mem_sel_i;  
	wire mem_ce_i;  
 

 openmips openmips0(
		.clk(clk),
		.rst(rst),
	
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),
		
		.ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_data_ready(mem_data_ready),
		.ram_ce_o(mem_ce_i)	
		//.regs[0:`RegNum-1](regs[0:`RegNum-1])
	);
	
	ram_rom ram_rom0(
		.rom_addr(inst_addr),
		.rom_inst(inst),
		.rom_ce(rom_ce),
		
		.ram_clk(clk),
		.ram_we(mem_we_i),
		.ram_addr(mem_addr_i),
		.ram_sel(mem_sel_i),
		.ram_data_i(mem_data_i),
		.ram_data_o(mem_data_o),
		.data_ready(mem_data_ready),
		.ram_ce(mem_ce_i)	
	);
	
/*	inst_rom inst_rom0(
		.addr(inst_addr),
		.inst(inst),
		.ce(rom_ce)	
	);
	
	data_ram data_ram0(
		.clk(clk),
		.we(mem_we_i),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o),
		.ce(mem_ce_i)		
	);
*/
endmodule