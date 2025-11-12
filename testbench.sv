module testbench;

    logic PCLK;
    logic PRESETn;
    logic PSEL;
    logic PENABLE;
    logic PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic PREADY;

    // Instantiate the DUT
    apb_slave dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // Test sequence
    initial begin
        // Reset
        PRESETn = 0;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 32'h0;
        PWDATA = 32'h0;
        #20;
        PRESETn = 1;

        // Write operation to 0x0: group number
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h0;
        PWDATA = 32'd15;  // Example group number
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Write operation to 0x4: date in DD.MM.YYYY format as integer
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h4;
        PWDATA = 32'd25122023;  // Example date: 25.12.2023
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Write operation to 0x8: first 4 letters of surname in ASCII
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h8;
        PWDATA = 32'h4976616E;  // "Ivan" in ASCII
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Write operation to 0xC: first 4 letters of name in ASCII
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'hC;
        PWDATA = 32'h50657472;  // "Petr" in ASCII
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Read back all written values to verify
        // Read from 0x0
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h0;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Read from 0x4
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h4;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Read from 0x8
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h8;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Read from 0xC
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'hC;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // End simulation
        #100;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time = %0t, PADDR = 0x%0h, PWDATA = 0x%0h, PRDATA = 0x%0h, PREADY = %b", 
                 $time, PADDR, PWDATA, PRDATA, PREADY);
    end

endmodule
