/* memory.ld - Kịch bản liên kết cho lõi RISC-V */

/* Quy hoạch vùng nhớ phần cứng dựa theo thiết kế Verilog */
MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K   /* Instruction Memory */
    RAM (rwx) : ORIGIN = 0x00000200, LENGTH = 4K   /* Data Memory (Dời xuống 0x200 để tránh đụng ROM) */
}

SECTIONS
{
    /* 1. Phân vùng chứa mã máy (Code) */
    .text : 
    {
        /* Ép đoạn code khởi tạo hệ thống (.text.init) vào đúng địa chỉ 0x00000000 */
        *(.text.init)
        
        /* Các hàm C++ (như main) sẽ nằm tiếp ngay sau vùng init */
        *(.text .text.*)
    } > ROM

    /* 2. Căn chỉnh địa chỉ chính xác đến 0x100 cho Vector Ngắt */
    . = 0x00000100;
    .trap :
    {
        /* Ép trình xử lý ngắt (.text.trap) vào đúng 0x00000100 */
        *(.text.trap)
    } > ROM

    /* 3. Phân vùng biến tĩnh có khởi tạo (Data) */
    .data :
    {
        *(.sdata .sdata.*)
        *(.data .data.*)
    } > RAM

    /* 4. Phân vùng biến tĩnh bằng 0 (BSS) */
    .bss :
    {
        PROVIDE(_bss_start = .);
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
        PROVIDE(_bss_end = .);
    } > RAM

    /* 5. Cấp phát vùng Stack cho C++ hoạt động */
    /* Đỉnh Stack (SP) bắt đầu từ cuối RAM và mọc ngược trở lên */
    PROVIDE(_stack_top = ORIGIN(RAM) + LENGTH(RAM));
}