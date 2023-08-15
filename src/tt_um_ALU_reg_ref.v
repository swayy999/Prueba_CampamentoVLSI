`timescale 1ns / 1ps

/*
Universidad técnica Federico Santa María, Valparaíso
Autor: Patricio Henriquez
*/

module tt_um_ALU_reg_ref#(
    parameter N = 4
) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire reset, load_A, load_B, load_Op, updateRes;
    wire [N-1 : 0] data_in;
    reg [N-1:0] result;
    reg [4:0] flags;

    assign uio_oe = 8'b1111_1111; //todos output
    assign {data_in, load_A, load_B, load_Op, updateRes} = ui_in;
    assign uo_out={result, flags[3:0]};
    assign uio_out = {flags[4], 7'd0};
    assign reset = ~rst_n;

    reg [N-1:0] A, B, Result_next;//, Result;
    reg [4:0] Status_next, Status;
    reg [1:0] OpCode;
    
    //assign display = Result;
    
    always @(posedge clk) begin 
        {A, B, OpCode, flags, result} <= {A, B, OpCode, flags, result};
        
        if(reset)
            {A, B, OpCode, flags, result} <= 'd0;
        else begin
            if(updateRes)
                {flags, result} <= {Status_next, Result_next}; 
            if(load_A)
                A <= data_in;
            if(load_B)
                B <= data_in;
            if(load_Op)
                OpCode <= data_in[1:0];
       end     
    end
    

    reg Neg, Z, C, V, P;
    
    always @(*) begin
		case(OpCode)
			2'd0: begin
                // NOR
				Result_next = ~(A | B);
				C = 1'b0;
				V = 1'b0;
			end

			2'd1: begin
                // NAND
				Result_next = ~(A & B);
				C = 1'b0;
				V = 1'b0;
			end

			2'd2: begin
                // SUMA
                {C, Result_next} = A + B;
				V = (Result_next[N-1] & ~A[N-1] & ~B[N-1]) | (~Result_next[N-1] & A[N-1] & B[N-1]);
			end

			2'd3: begin
                // RESTA
                {C, Result_next} = A - B;
				V = (Result_next[N-1] & ~A[N-1] & B[N-1]) | (~Result_next[N-1] & A[N-1] & ~B[N-1]);	
			end
		endcase

		Neg = Result_next[N-1];
		Z = (Result_next == '0);
        P = ~^Result_next;

		Status_next = {V, C, Z, Neg, P};
	end

endmodule
