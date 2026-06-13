.section .text.init
.globl _start

_start:
    /* 1. Khởi tạo Stack bằng lệnh cơ bản (Không dùng la/auipc) */
    li sp, 0x000001F0

    /* 2. Nhảy vào hàm C++ */
    call main

halt:
    j halt

    /* TRÌNH XỬ LÝ NGẮT TẠI 0x00000100 */
    .section .text.trap
    .align 2
trap_vector:
    addi sp, sp, -64
    sw ra,  0(sp)
    /* (Để ngắn gọn khi test sóng, tôi chỉ lưu 1 thanh ghi ra) */

    call c_trap_handler

    lw ra,  0(sp)
    addi sp, sp, 64
    mret
    