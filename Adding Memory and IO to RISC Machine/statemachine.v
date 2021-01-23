//modifications
`define R 2'b01
`define W 2'b10
`define Reset 6'b100000
`define IF1 6'b100001
`define IF2 6'b100010
`define UpdatePC 6'b100011

				/*state encodings are done in 5 bit binary (needed to encode all states uniquely. */
`define decode 6'b100100
`define CMP1 6'b100101			/*After moving values in the registers - which in turn is done using the MOVSIGN1 states, we describe 3 compare states required to do one row of operations in the table.  */
`define CMP2 6'b100110
`define CMP3 6'b100111

`define MOVSIGN1 6'b101000		/*state encoding for moving a value imm8 into the desired register*/

`define MOVSHIFT1 6'b101010			/*MOVSHIFT operation: Writing a value to Rm, shifting it, reading it to Rm (3 states)*/
`define MOVSHIFT2 6'b101011
`define MOVSHIFT3 6'b101100

`define AND1 6'b101101			/*Reading a value to Rm, reading a value to Rn, shifting the Rm value and AND'ing with Rn (instruction set), reading it to Rd (4 cycles)*/
`define AND2 6'b101110
`define AND3 6'b110000
`define AND4 6'b110001

`define MVN1 6'b110010				/*Reading to Rm, shifting and NOT'ing it (instruction set), reading to Rd (3 cycles = 3 states )*/
`define MVN2 6'b110011
`define MVN3 6'b110100

`define ADD1 6'b110101				/*Similar procedure to AND operation hence 4 cycles i.e. need 4 states to encode this operation.*/
`define ADD2 6'b110110
`define ADD3 6'b110111
`define ADD4 6'b111000

`define LDR1 6'b111001
`define LDR2 6'b111010
`define LDR3 6'b111011
`define LDR4 6'b111100
`define LDR5 6'b111101
`define LDR6 6'b111110

`define STR1 6'b111111
`define STR2 6'b010000
`define STR3 6'b010001
`define STR4 6'b010010
`define STR5 6'b010011
`define STR6 6'b010100

`define HALT 6'b010101
module statemachine(opcode, op, reset, clk,

nsel,
vsel,
mdata,
PC,

write, 

loada,
loadb,

bsel,
asel,

loadc,
loads,

//modifications
load_ir,
load_pc,
reset_pc,
addr_sel,
m_cmd,
load_addr

);
	
	//modifications

	output reg load_pc;
	output reg reset_pc;
	output reg [1:0] m_cmd;
	output reg addr_sel;
	output reg load_ir;
	output reg load_addr;

	input [2:0] opcode; //assume 101 = ALU
	input [1:0] op;// assume 00 = ADD
	//input s;
	input reset;
	input clk;
	
	reg [5:0] present_state;		/*keep track of current state we are in to progress*/

	output reg [2:0] nsel;
	output reg [3:0] vsel; //9
	output reg [15:0] mdata;
	
	output reg [7:0] PC;

	output reg write;
	
	output reg loada; //3

	output reg loadb; //3

	output reg bsel; //7

	output reg asel; //6


	output reg loadc; //5

	output reg loads; //10


always @(posedge clk) begin
if(reset == 1) begin			/*synchronous reset*/
	present_state = `Reset;
end else begin
	case(present_state)		/*First case statement handles transitions */
	`Reset: present_state = `IF1;
	
	`IF1: present_state = `IF2;
	
	`IF2: present_state = `UpdatePC;
	
	`UpdatePC: present_state = `decode;
	
	`decode: 					/*many types of operations branch out from the decode state depending on opcode and op: the next state depends on these and as a result so do subsequent states.*/
		if(opcode == 3'b101 && op == 2'b00) begin
			present_state = `ADD1;
		end else if(opcode == 3'b101 && op == 2'b01) begin
			present_state = `CMP1;
		end else if(opcode == 3'b101 && op == 2'b10) begin
			present_state = `AND1; 
		end else if(opcode == 3'b101 && op == 2'b11) begin
			present_state = `MVN1;
		end
		
			else if(opcode == 3'b110 && op == 2'b10) begin
			present_state = `MOVSIGN1;
		end else if (opcode == 3'b110 && op == 2'b00) begin
			present_state = `MOVSHIFT1;
		end 
		else if (opcode == 3'b011 && op == 2'b00) begin
			present_state = `LDR1;
		end else if (opcode == 3'b100 && op == 2'b00) begin
			present_state = `STR1;
		end else begin 
			present_state = `HALT;
			end
		
	`ADD1: present_state = `ADD2;		/*Once ADD state begins, proceed to complete the whole ADD cycle before returning back to Wait.*/
	`ADD2: present_state = `ADD3;
	`ADD3: present_state = `ADD4;
	`ADD4: present_state = `IF1;
	
	`CMP1: present_state = `CMP2;		/*similar for all other states once a path is inititated.*/
	`CMP2: present_state = `CMP3;
	`CMP3: present_state = `IF1;

	`MOVSIGN1: present_state = `IF1;
	
	`MOVSHIFT1: present_state = `MOVSHIFT2;
	`MOVSHIFT2: present_state = `MOVSHIFT3;
	`MOVSHIFT3: present_state = `IF1;
    
  	`AND1: present_state = `AND2;
 	`AND2: present_state =`AND3;
  	`AND3: present_state = `AND4;
  	`AND4: present_state = `IF1; 

  	`MVN1: present_state = `MVN2;
  	`MVN2: present_state = `MVN3; 
  	`MVN3: present_state = `IF1;

	`LDR1: present_state = `LDR2;
	`LDR2: present_state = `LDR3;
	`LDR3: present_state = `LDR4;
	`LDR4: present_state = `LDR5;
	`LDR5: present_state = `LDR6;
	`LDR6: present_state = `IF1;
	
	`STR1: present_state = `STR2;
	`STR2: present_state = `STR3;
	`STR3: present_state = `STR4;
	`STR4: present_state = `STR5;
	`STR5: present_state = `STR6;
	`STR6: present_state = `IF1;

 	`HALT: present_state = `HALT; 
	default: present_state = 6'bxxxxxx;
	endcase
end
	case(present_state)				/*The second case statement describes the outputs associated with each state - good FSM coding practice. */ 
		`Reset: begin				/*w = 1 for autograder, everything else set to inactive state.*/				
	nsel = 0;
	vsel = 0;
	loada = 0;
        loadb = 0;	
        asel = 0;
        bsel = 0;
        loadc = 0;
        loads = 0;
        write = 0; 
	PC = 0;
	//new	
	reset_pc = 1;
	load_pc = 1;
	load_ir = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_addr = 0;
	
end


		`IF1: begin
	load_ir = 0;
	load_pc = 0;
	reset_pc = 0;
	addr_sel  = 0;
	m_cmd = `R;
	addr_sel = 1;
	load_addr = 0;
	nsel = 0;
	vsel = 0;
	loada = 0;
        loadb = 0;	
        asel = 0;
        bsel = 0;
        loadc = 0;
        loads = 0;
        write = 0; 
	PC = 0;
	
end
		`IF2: begin

	load_ir = 1;
	load_pc = 0;
	reset_pc = 0;
	m_cmd = `R;
	addr_sel = 1;
	load_addr = 0;
	nsel = 0;
	vsel = 0;
	loada = 0;
        loadb = 0;	
        asel = 0;
        bsel = 0;
        loadc = 0;
        loads = 0;
        write = 0; 
	mdata = 0;
	PC = 0;
end
		`UpdatePC: begin

	load_ir = 0;
	load_pc = 1;
	reset_pc = 0;
	m_cmd = 2'b00;
	addr_sel = 0;
	load_addr = 0;
	nsel = 0;
	vsel = 0;
	loada = 0;
        loadb = 0;	
        asel = 0;
        bsel = 0;
        loadc = 0;
        loads = 0;
        write = 0; 
	mdata = 0;
	PC = 0;
end
	
		`decode: begin			/*w is set to 0*/
				nsel = 0;
				vsel = 0;
				loada = 0;
        			loadb = 0;	
        			asel = 1;
        			bsel = 1;
        			loadc = 0;
        			loads = 0;
        			write = 0; 
				mdata = 0;
				PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;

end
	
		`CMP1: begin		/*Rm is selected with nsel, and written into load b in datapath.*/
			nsel = 3'b001;
			vsel = 0;
			loada = 0;
       			loadb = 1;	
        		asel = 1;
        		bsel = 1;
        		loadc = 0;
        		loads = 0;
        		write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
			end	
		`CMP2: begin     /*Rn is selected with nsel, and written into load a in datapath.*/
      
				
		nsel = 3'b100;
		vsel = 0;
		loada = 1;
        	loadb = 0;	
        	asel = 1;
        	bsel = 1;
        	loadc = 0;
        	loads = 0;
        	write = 0; 
		mdata = 0;
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
		end
	
		`CMP3: begin		/*Rn is selected with nsel, and load s is ACTIVATED to get Z,V,and N signals out from datapath (special to CMP operation)*/
		
		nsel = 3'b100;
		vsel = 0;
		loada = 0;
        	loadb = 0;	
        	asel = 0;
        	bsel = 0;
        	loadc = 0;				
        	loads = 1;
        	write = 0; 
		mdata = 0;
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end 

	`AND1: begin			/*Rm is copeied into load b which will then pass onto the shifter for succesfully finishing sh<Rm>*/
      

		nsel = 3'b001;
		vsel = 0;
		loada = 0;
        	loadb = 1;	
        	asel = 1;
        	bsel = 1;
        	loadc = 0;
        	loads = 0;
        	write = 0; 
		mdata = 0;
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
   end
      
		`AND2: begin	/*Rn copied into load a.*/
      
      nsel = 3'b100;
			vsel = 0;
			loada = 1;
      loadb = 0;	
      asel = 1;
      bsel = 1;
      loadc = 0;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
      
    end
      
      `AND3: begin		/*load c activated to store the result of the AND operation in datapath*/
      
      nsel = 0;
	vsel = 0;
	loada = 0;
      loadb = 0;	
      asel = 0;
      bsel = 0;
      loadc = 1;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
			
      end
    
    	`AND4: begin	/*write is set to 1 to write the result to Rd and vsel is set to 4'b0001 to make sure the output from the calculation is fed back into the mux to go into desired register. */
        
      nsel = 3'b010;
			vsel = 4'b0001;
			loada = 0;
      loadb = 0;	
      asel = 1;
      bsel = 1;
      loadc = 0;
      loads = 0;
      write = 1; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
			
      end
    
    `MVN1: begin /*Rm is copied onto load b.*/
      
      nsel = 3'b001;
			vsel = 0;
			loada = 0;
      loadb = 1;	
      asel = 1;
      bsel = 1;
      loadc = 0;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
      
    end
      
    `MVN2: begin	/*load c is activated to let through the not-shifted Rm value*/
      
      nsel = 3'b001;
			vsel = 0;
			loada = 0;
      loadb = 0;	
      asel = 1;
      bsel = 0;
      loadc = 1;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
        
      end
    
        `MVN3: begin	/*writing the result onto Rd, vsel is chosen as 0001 to choose the C output to feedback into the mux so that it can go into our desired register. */
      
      
      nsel = 3'b010;
			vsel = 4'b0001;
			loada = 0;
      loadb = 0;	
      asel = 1;
      bsel = 1;
      loadc = 0;
      loads = 0;
      write = 1; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
      
    end

	`MOVSIGN1: begin	/*the input value is written onto Rn (selected from nsel and write = 1)*/
      
      nsel = 3'b100;
      vsel = 4'b0100;
      loada = 0;
      loadb = 0;	
      asel = 1;
      bsel = 0;
      loadc = 1;
      loads = 0;
      write = 1; 
      mdata = 0;
      PC = 0;
      reset_pc = 0;
      load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 0;
	load_ir = 0;
	load_addr = 0;

	end

	`MOVSHIFT1: begin		/*Rm is fed into load b for shifting and bitwise notting.*/
      
   
      nsel = 3'b001;
			vsel = 0;
			loada = 0;
      			loadb = 1;	
      			asel = 1;
      			bsel = 1;
      loadc = 0;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				load_pc = 0;
				reset_pc = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end

	`MOVSHIFT2: begin	/*load c is activated to return the result of the operations done on Rm. */
      
           nsel = 3'b001;
		vsel = 0;
		loada = 0;
      		loadb = 0;	
      		asel = 1;
      		bsel = 0;
      loadc = 1;
      loads = 0;
      write = 0; 
			mdata = 0;
			PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;	
				reset_pc = 0;
				m_cmd = 2'b00;
				load_addr = 0;

	end

	`MOVSHIFT3: begin	/*This value is written onto Rd by looping it back through the multiplexer (write = 1 and vsel = 0001).*/
      
      nsel = 3'b010;
			vsel = 4'b0001;
			loada = 0;
      			loadb = 0;	
      			asel = 1;
      			bsel = 1;
      loadc = 0;
      loads = 0;
      write = 1; 
			mdata = 0;
			PC = 0;

				reset_pc = 0;
				load_pc  = 0;
				addr_sel  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;

	end
        
	`ADD1: begin		/*Rn copied onto load a.*/

 		// register operand fetch stage

                nsel = 3'b100;
		vsel = 0;
                loada = 1;
                loadb = 0;	

                // computation stage (sometimes called "execute")
                asel = 1;
                bsel = 1;
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                
                write = 0; 
     

		//modification
		mdata = 0;
		
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				addr_sel  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end
	`ADD2: begin		/*Rm copied to load b for shifting purposes. */

		
		nsel = 3'b001;
		vsel = 0;
                loada = 0;
                loadb = 1;	
		

                // computation stage (sometimes called "execute")
           
                asel = 1;
                bsel = 1;
               
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
            
                write = 0; 
          
		//modification
		mdata = 0;
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				addr_sel  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end 
	`ADD3:	begin	/*load c activated to yield the addition result*/
	
		
		nsel = 0;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
             
                asel = 0;
                bsel = 0;
              
                loadc = 1;
                loads = 0;

                // set when "writing back" to register file
             
                write = 0; 
            

		//modification
		mdata = 0;
		
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				addr_sel  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end
	`ADD4: 	begin		/*result is written onto Rd*/

		nsel = 3'b010;
		vsel = 4'b0001;
                loada = 0;
                loadb = 0;	
		

                // computation stage (sometimes called "execute")
             
                asel = 1;
                bsel = 1;
              
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
              
                write = 1; 
             
		//modification
		mdata = 0;
		PC = 0;
				reset_pc = 0;
				load_pc  = 0;
				addr_sel  = 0;
				m_cmd = 2'b00;
				addr_sel = 0;
				load_ir = 0;
				load_addr = 0;
	end

`LDR1: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 0;
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 1; //mod
    loadb = 0;	
    asel = 1;
    bsel = 1;
    loadc = 0;
    loads = 0;
    write = 0; 
	mdata = 0;
	PC = 0;
end
`LDR2: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 0;
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 0;
    	bsel = 1;
    	loadc = 1; //mod
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`LDR3:  begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 1; //mod
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`LDR4: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = `R;
	addr_sel = 0; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`LDR5: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = `R;
	addr_sel = 0; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`LDR6: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 0; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b010; //Rn = 100 Rd = 010 Rm = 001
	vsel = 4'b1000; //reading from mdata
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
   	loadc = 0;
    	loads = 0;
    	write = 1; 
	mdata = 0;
	PC = 0;
	
end	
`STR1: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 0;
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 1; //mod
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`STR2: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 0;
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 0;
    	bsel = 1;
    	loadc = 1; //mod
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`STR3: begin
	reset_pc = 0;
	load_pc  = 0;
	m_cmd = 2'b00;
	addr_sel = 1;
	load_ir = 0;
	load_addr = 1; //mod
	nsel = 3'b100; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0;
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 0; 
	mdata = 0;
	PC = 0;
end	
`STR4: begin
	reset_pc = 0;
	load_pc  = 0;
	addr_sel  = 1;
	m_cmd = 2'b00;
	addr_sel = 1; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b010; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0; //mod
	loada = 0;
    	loadb = 1;	
    	asel = 1;
    	bsel = 1;
    	loadc = 0;
    	loads = 0;
    	write = 1; 
	mdata = 0;
	PC = 0;
end	
`STR5: begin
	reset_pc = 0;
	load_pc  = 0;
	addr_sel  = 1;
	m_cmd = 2'b00;
	addr_sel = 1; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b010; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0; //mod
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 0;
    	loadc = 1;
    	loads = 0;
    	write = 1; 
	mdata = 0;
	PC = 0;
end	
`STR6: begin
	reset_pc = 0;
	load_pc  = 0;
	addr_sel  = 0;
	m_cmd = `W; //mod
	addr_sel = 0; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b010; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0; //mod
	loada = 0;
    	loadb = 0;	
    	asel = 1;
    	bsel = 0;
    	loadc = 1;
    	loads = 0;
    	write = 1; 
	mdata = 0;
	PC = 0;
end


	`HALT: begin
	
	reset_pc = 1;		//mod
	load_pc  = 0;
	m_cmd = `R; //mod
	addr_sel = 0; //mod
	load_ir = 0;
	load_addr = 0; //mod
	nsel = 3'b010; //Rn = 100 Rd = 010 Rm = 001
	vsel = 0; //mod
	loada = 0;
    loadb = 0;	
    asel = 1;
    bsel = 0;
    loadc = 0;
    loads = 0;
    write = 0; 
	mdata = 0;
	PC = 0;
end

	

endcase

end

endmodule
      
		

	
		

