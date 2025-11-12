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

        // Write operation
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h0;
        PWDATA = 32'h12345678;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Read operation
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h0;
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
