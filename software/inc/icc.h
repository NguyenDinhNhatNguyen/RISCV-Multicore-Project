#ifndef ICC_H
#define ICC_H

// Địa chỉ gốc của khối Inter-Core Controller (Nằm ở Slave 2 của Crossbar)
#define ICC_BASE_ADDR 0x0C000000

// 1. THANH GHI MUTEX (Hardware Spinlock)
// Đọc: Trả về 0 nếu rảnh (và tự động khóa lại thành 1). Trả về 1 nếu đang bận.
// Ghi: Ghi giá trị 0 vào đây để nhả khóa (Unlock).
#define ICC_MUTEX        (*(volatile unsigned int*)(ICC_BASE_ADDR + 0x0000))

// 2. THANH GHI MAILBOX (Gửi ngắt chéo)
// Core 0 ghi vào MAILBOX_0TO1 sẽ làm chân irq_core1 bật lên 1.
#define ICC_MAILBOX_0TO1 (*(volatile unsigned int*)(ICC_BASE_ADDR + 0x0004))

// Core 1 ghi vào MAILBOX_1TO0 sẽ làm chân irq_core0 bật lên 1.
#define ICC_MAILBOX_1TO0 (*(volatile unsigned int*)(ICC_BASE_ADDR + 0x0008))

// Vùng nhớ RAM dùng chung (Bank 0)
#define SHARED_RAM_VAR   (*(volatile unsigned int*)(0x00000020))

#endif