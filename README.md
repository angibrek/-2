module apb_slave (
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PWRITE,
    input logic [31:0] PADDR,
    input logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic PREADY
);

    // Внутренняя память
    logic [31:0] memory [0:255];

    // Регистр для хранения данных на запись
    logic [31:0] write_data;
    logic [31:0] read_data;

    // Управляющие сигналы
    logic write_enable;
    logic read_enable;

    // PREADY по умолчанию 1
    assign PREADY = 1'b1;

    // Определение операций записи и чтения
    assign write_enable = PSEL && PENABLE && PWRITE;
    assign read_enable = PSEL && PENABLE && !PWRITE;

    // Операция записи
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Сброс памяти
            foreach (memory[i]) memory[i] <= 32'h0;
        end else if (write_enable) begin
            memory[PADDR] <= PWDATA;
            $display("Write operation: Address = 0x%0h, Data = 0x%0h", PADDR, PWDATA);
        end
    end

    // Операция чтения
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            read_data <= 32'h0;
        end else if (read_enable) begin
            read_data <= memory[PADDR];
            $display("Read operation: Address = 0x%0h, Data = 0x%0h", PADDR, memory[PADDR]);
        end
    end

    assign PRDATA = read_data;

endmodule
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
