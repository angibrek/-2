// Модуль APB slave
module apb_slave (
    input logic PCLK,           // Тактовый сигнал
    input logic PRESETn,        // Сброс (активный низкий уровень)
    input logic PSEL,           // Выбор slave (активный высокий уровень)
    input logic PENABLE,        // Сигнал разрешения (активный высокий уровень)
    input logic PWRITE,         // Направление передачи: 1 - запись, 0 - чтение
    input logic [31:0] PADDR,   // Адрес шины
    input logic [31:0] PWDATA,  // Данные для записи
    output logic [31:0] PRDATA, // Данные для чтения
    output logic PREADY         // Сигнал готовности
);

    // Внутренняя память 256 слов по 32 бита
    logic [31:0] memory [0:255];

    // Регистр для хранения данных на чтение
    logic [31:0] read_data;

    // Управляющие сигналы для записи и чтения
    logic write_enable;
    logic read_enable;

    // По умолчанию slave всегда готов (PREADY = 1)
    assign PREADY = 1'b1;

    // Формирование сигналов разрешения записи и чтения
    // Запись: когда slave выбран, передача разрешена и направление - запись
    assign write_enable = PSEL && PENABLE && PWRITE;
    // Чтение: когда slave выбран, передача разрешена и направление - чтение
    assign read_enable = PSEL && PENABLE && !PWRITE;

    // Процесс записи в память
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Сброс памяти: обнуляем все ячейки
            foreach (memory[i]) memory[i] <= 32'h0;
        end else if (write_enable) begin
            // Если разрешена запись, записываем данные по адресу PADDR
            memory[PADDR] <= PWDATA;
            // Вывод отладочного сообщения о записи
            $display("Write operation: Address = 0x%0h, Data = 0x%0h", PADDR, PWDATA);
        end
    end

    // Процесс чтения из памяти
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Сброс данных для чтения
            read_data <= 32'h0;
        end else if (read_enable) begin
            // Если разрешено чтение, считываем данные по адресу PADDR
            read_data <= memory[PADDR];
            // Вывод отладочного сообщения о чтении
            $display("Read operation: Address = 0x%0h, Data = 0x%0h", PADDR, memory[PADDR]);
        end
    end

    // Назначение выходных данных для чтения
    assign PRDATA = read_data;

endmodule
