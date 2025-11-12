
```systemverilog
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
