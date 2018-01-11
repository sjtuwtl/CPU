`include "defines.v"

module cache(
    
    input wire                 rst,
    input wire                 clk,

    //from MEM
    input wire[`RegBus]        mem_addr_i,
    input wire                 mem_we_i,
    input wire[3:0]            mem_sel_i,
    input wire[`RegBus]        mem_data_i,
    input wire                 mem_ce_i,

    //from RAM
    input wire[`RegBus]        ram_data_i,
    input wire                 ram_data_ready,
    //to RAM
    output reg[`RegBus]        ram_addr_o,
    output reg                 ram_we_o,
    output reg[3:0]            ram_sel_o,
    output reg[`RegBus]        ram_data_o,
    output reg                 ram_ce_o,
    
    //to MEM
    output reg[`RegBus]        mem_data_o,

    //to ctrl
    output wire                stallreq
);
    
    wire set_select;
    reg[62:0] cache0, cache1, cache2, cache3;
    reg hit;
    reg ready;
    reg[62:0] write_buffer;

    assign set_select = mem_addr_i[3:2];

    always @ (*) begin
        if (rst == `RstEnable) begin
            hit <= `NotHit;
        end else begin
            case (set_select)
                2'b00: begin
                    hit <= (cache0[`ValidBit] == `Valid &&
                            cache0[`CacheTag] == mem_addr_i[`DataAddrTagBit]);
                end
                2'b01: begin
                    hit <= (cache1[`ValidBit] == `Valid &&
                            cache1[`CacheTag] == mem_addr_i[`DataAddrTagBit]);
                end
                2'b10: begin
                    hit <= (cache2[`ValidBit] == `Valid &&
                            cache2[`CacheTag] == mem_addr_i[`DataAddrTagBit]);
                end
                2'b11: begin
                    hit <= (cache3[`ValidBit] == `Valid &&
                            cache3[`CacheTag] == mem_addr_i[`DataAddrTagBit]);
                end
            endcase
        end
    end //always

    always @ (*) begin
        ready <= 1'b0;
        if (rst == `RstEnable) begin
            ram_addr_o <= `ZeroWord;
            ram_we_o <= `WriteDisable;
            ram_sel_o <= 4'b0;
            ram_data_o <= `ZeroWord;
            ram_ce_o <= `ChipDisable;
            mem_data_o <= `ZeroWord;
            ready <= 1'b1;
        end else if (mem_ce_i == `ChipDisable) begin
            if (write_buffer[`ValidBit] == 1'b0) begin
                ram_addr_o <= `ZeroWord;
                ram_we_o <= `WriteDisable;
                ram_sel_o <= 4'b0;
                ram_data_o <= `ZeroWord;
                ram_ce_o <= `ChipDisable;
                ready <= 1'b1;
            end else begin
                ram_addr_o <= {write_buffer[`CacheTag], 2'b0};
                ram_we_o <= `WriteEnable;
                ram_sel_o <= 4'b1111;
                ram_data_o <= write_buffer[`DataStorage];
                ram_ce_o <= `ChipEnable;
                write_buffer[`ValidBit] = `Invalid;
            end
        end else if (hit == 1'b0) begin
                ram_addr_o <= mem_addr_i;
                ram_we_o <= `WriteDisable;
                ram_sel_o <= 4'b1;
                ram_data_o <= `ZeroWord;
                ram_ce_o <= mem_ce_i;
        end else begin
            ram_addr_o <= `ZeroWord;
            ram_we_o <= `WriteDisable;
            ram_sel_o <= 4'b0;
            ram_data_o <= `ZeroWord;
            ram_ce_o <= `ChipDisable;
            if (mem_we_i == `WriteDisable) begin
                case (set_select)
                    2'b00: begin
                        mem_data_o <= cache0[`DataStorage];
                    end
                    2'b01: begin
                        mem_data_o <= cache1[`DataStorage];
                    end
                    2'b10: begin
                        mem_data_o <= cache2[`DataStorage];
                    end
                    2'b11: begin
                        mem_data_o <= cache3[`DataStorage];
                    end
                endcase
                ready <= 1'b1;
            end else begin
                case (set_select)
                    2'b00: begin
                        if (mem_sel_i[3] == 1'b1) begin
                            cache0[31:24] <= mem_data_i[31:24];
                        end
                        if (mem_sel_i[2] == 1'b1) begin
                            cache0[23:16] <= mem_data_i[23:16];
                        end
                        if (mem_sel_i[1] == 1'b1) begin
                            cache0[15:8] <= mem_data_i[15:8];
                        end
                        if (mem_sel_i[0] == 1'b1) begin
                            cache0[7:0] <= mem_data_i[7:0];
                        end	
                    end
                    2'b01: begin
                         if (mem_sel_i[3] == 1'b1) begin
                            cache1[31:24] <= mem_data_i[31:24];
                        end
                        if (mem_sel_i[2] == 1'b1) begin
                            cache1[23:16] <= mem_data_i[23:16];
                        end
                        if (mem_sel_i[1] == 1'b1) begin
                            cache1[15:8] <= mem_data_i[15:8];
                        end
                        if (mem_sel_i[0] == 1'b1) begin
                            cache1[7:0] <= mem_data_i[7:0];
                        end	
                    end
                    2'b10: begin
                         if (mem_sel_i[3] == 1'b1) begin
                            cache2[31:24] <= mem_data_i[31:24];
                        end
                        if (mem_sel_i[2] == 1'b1) begin
                            cache2[23:16] <= mem_data_i[23:16];
                        end
                        if (mem_sel_i[1] == 1'b1) begin
                            cache2[15:8] <= mem_data_i[15:8];
                        end
                        if (mem_sel_i[0] == 1'b1) begin
                            cache2[7:0] <= mem_data_i[7:0];
                        end	
                    end
                    2'b11: begin
                         if (mem_sel_i[3] == 1'b1) begin
                            cache3[31:24] <= mem_data_i[31:24];
                        end
                        if (mem_sel_i[2] == 1'b1) begin
                            cache3[23:16] <= mem_data_i[23:16];
                        end
                        if (mem_sel_i[1] == 1'b1) begin
                            cache3[15:8] <= mem_data_i[15:8];
                        end
                        if (mem_sel_i[0] == 1'b1) begin
                            cache3[7:0] <= mem_data_i[7:0];
                        end	
                    end
                endcase
                ready <= 1'b1;
            end
        end
    end //always

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            write_buffer <= 65'b0;
            cache0 <= `CacheNOP;
            cache1 <= `CacheNOP;
            cache2 <= `CacheNOP;
            cache3 <= `CacheNOP;
        end else if (ready == 1'b0 && ram_data_ready == 1'b1) begin
            case (set_select)
                2'b00: begin
                    if (cache0[`ValidBit] == 1'b1) begin
                        write_buffer <= cache0[62:0];
                    end else begin
                        cache0 <= {1'b1, mem_addr_i[`DataAddrTagBit], ram_data_i[31:0]};
                    end
                end
                2'b01: begin
                    if (cache1[`ValidBit] == 1'b1) begin
                        write_buffer <= cache1[62:0];
                    end else begin
                        cache1 <= {1'b1, mem_addr_i[`DataAddrTagBit], ram_data_i[31:0]};
                    end
                end
                2'b10: begin
                    if (cache2[`ValidBit] == 1'b1) begin
                        write_buffer <= cache2[62:0];
                    end else begin
                        cache2 <= {1'b1, mem_addr_i[`DataAddrTagBit], ram_data_i[31:0]};
                    end
                end
                2'b11: begin
                   if (cache3[`ValidBit] == 1'b1) begin
                        write_buffer <= cache3[62:0];
                    end else begin
                        cache3 <= {1'b1, mem_addr_i[`DataAddrTagBit], ram_data_i[31:0]};
                    end
                end
            endcase
        end
    end //always

    assign stallreq = !ready;

endmodule