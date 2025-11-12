// Модуль тестбенча
module testbench;

    // Объявление сигналов, совместимых с портами APB slave
    logic PCLK;
    logic PRESETn;
    logic PSEL;
    logic PENABLE;
    logic PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic PREADY;

    // Экземпляр тестируемого устройства (APB slave)
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

    // Генерация тактового сигнала
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; // Период 10 единиц времени
    end

    // Последовательность тестирования
    initial begin
        // Инициализация сигналов
        PRESETn = 0;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 32'h0;
        PWDATA = 32'h0;
        #20; // Удержание сброса в течение 20 единиц времени
        PRESETn = 1; // Снятие сброса

        // Операция записи по адресу 0x0 (номер в списке группы)
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h0;
        PWDATA = 32'd15; // Пример: номер в списке группы = 15
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Операция записи по адресу 0x4 (дата в формате дд.мм.гггг в виде целого числа)
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h4;
        PWDATA = 32'd25122023; // Пример: 25.12.2023
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Операция записи по адресу 0x8 (первые 4 буквы фамилии в ASCII)
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'h8;
        PWDATA = 32'h4976616E; // Пример: "Ivan"
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Операция записи по адресу 0xC (первые 4 буквы имени в ASCII)
        #10;
        PSEL = 1;
        PWRITE = 1;
        PADDR = 32'hC;
        PWDATA = 32'h50657472; // Пример: "Petr"
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Чтение из всех записанных адресов для проверки
        // Чтение из 0x0
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h0;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Чтение из 0x4
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h4;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Чтение из 0x8
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'h8;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Чтение из 0xC
        #10;
        PSEL = 1;
        PWRITE = 0;
        PADDR = 32'hC;
        #10;
        PENABLE = 1;
        #10;
        PSEL = 0;
        PENABLE = 0;

        // Завершение симуляции
        #100;
        $finish;
    end

    // Мониторинг сигналов
    initial begin
        $monitor("Time = %0t, PADDR = 0x%0h, PWDATA = 0x%0h, PRDATA = 0x%0h, PREADY = %b", 
                 $time, PADDR, PWDATA, PRDATA, PREADY);
    end

endmodule
