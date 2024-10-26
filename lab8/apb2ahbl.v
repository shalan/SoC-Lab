/*
	Copyright 2020 Mohamed Shalan
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
*/

`timescale               1ns/1ps
`default_nettype         none

/*
    A simple AHB-lite to APB Bridge
*/
module apb2ahbl (
    input   wire            HCLK,
    input   wire            HRESETn,
    
    input   wire            HSEL,
    input   wire [31:0]     HADDR,
    input   wire [1:0]      HTRANS,
    input   wire            HWRITE,
    input   wire            HREADY,
    input   wire [31:0]     HWDATA,
    input   wire [2:0]      HSIZE,
    output  wire            HREADYOUT,
    output  wire [31:0]     HRDATA,

    // APB Master Port
    output  wire            PCLK,
    output  wire            PRESETn,
    input   wire [31:0]     PRDATA,
    input   wire            PREADY,
    output  wire [31:0]     PWDATA,
    output  reg             PENABLE,
    output  reg  [31:0]     PADDR,
    output  reg             PWRITE
);
  
    localparam      ST_IDLE     = 3'h0,
                    ST_WAIT     = 3'h1,
                    ST_SETUP    = 3'h2,
                    ST_ACCESS   = 3'h3;       
          
    wire            Transfer    = HSEL & HREADY & HTRANS[1];
    wire            PCLKEN      =   1'b1;

    assign          PCLK        =   HCLK;
    assign          PRESETn     = HRESETn;

    wire  [31:0]    HADDR_Mux;

    reg   [2:0]     state;
    reg   [2:0]     nstate;

    reg             HREADY_next;  
    wire            PWRITE_next;
    wire            PENABLE_next;
    wire            APBEn;
  

    
    reg             last_HSEL; 
    reg [31:0]      last_HADDR; 
    reg             last_HWRITE; 
    reg [1:0]       last_HTRANS;
    
    always@ (posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			last_HSEL       <= 0;
			last_HADDR      <= 0;
			last_HWRITE     <= 0;
			last_HTRANS     <= 0;
		end else if(HREADY) begin
			last_HSEL       <= HSEL;
			last_HADDR      <= HADDR;
			last_HWRITE     <= HWRITE;
			last_HTRANS     <= HTRANS;
		end
	end
    
    //wire rd_enable = last_HSEL & (~last_HWRITE) & last_HTRANS[1]; 
    //wire wr_enable = last_HSEL & (last_HWRITE) & last_HTRANS[1];
  
    // State Machine
    always @ * 
        case (state)
            ST_IDLE:    if(Transfer & PCLKEN) nstate = ST_SETUP; 
                        else if(Transfer) nstate = ST_WAIT;
                        else nstate = ST_IDLE;      
            ST_WAIT:    if(PCLKEN) nstate = ST_SETUP;
                        else nstate = ST_WAIT;
            ST_SETUP:   if(PCLKEN) nstate = ST_ACCESS; else nstate = ST_SETUP;
            ST_ACCESS:  if(!PREADY) nstate = ST_ACCESS;
                        else begin
                            if(Transfer & PCLKEN) nstate = ST_SETUP; 
                            else if(Transfer) nstate = ST_WAIT;
                            else nstate = ST_IDLE;
                        end
            default:    nstate = ST_IDLE;
        endcase

    always @ (posedge HCLK, negedge HRESETn)
        if(!HRESETn)
            state <= ST_IDLE;
        else
            state <= nstate;
  
    //HREADYOUT
    reg hreadyout;
    always @ *
        case (nstate)
            ST_IDLE:    HREADY_next = 1'b1;
            ST_WAIT:    HREADY_next = 1'b0;
            ST_SETUP:   HREADY_next = 1'b0;
            ST_ACCESS:  HREADY_next = PREADY;
            default:    HREADY_next = 1'b1;
        endcase

    always @(posedge HCLK, negedge HRESETn)
        if(!HRESETn)
            hreadyout <= 1'b1;
        else
            hreadyout <= HREADY_next;
    
    assign HREADYOUT = hreadyout;

    //APBen
    assign APBEn = (state == ST_IDLE) && (nstate == ST_SETUP) || (nstate == ST_WAIT) ;

    // HADDRMux
    assign HADDR_Mux = (APBEn ? HADDR : last_HADDR);

    //PADDR
    always @ (posedge HCLK, negedge HRESETn)
    if (!HRESETn)
        PADDR <= 'h0;
    else if (APBEn)
        PADDR <= HADDR_Mux;

    //PWDATA
    assign PWDATA = HWDATA;

    //PENABLE
    assign PENABLE_next = (nstate == ST_ACCESS);
    always @ (posedge HCLK, negedge HRESETn)
        if(!HRESETn)
            PENABLE <= 1'b0;
        else
            PENABLE <= PENABLE_next;

    //PWRITE
    assign PWRITE_next = (APBEn ? HWRITE : last_HWRITE);
    always @ (posedge HCLK, negedge HRESETn)
    if(!HRESETn)
        PWRITE <= 1'b0;
    else if (APBEn)
        PWRITE <= PWRITE_next;

    //HRDATA
    assign HRDATA = PRDATA;

endmodule