#include "icc.h"

// ------------------------------------------------------------------------
// 1. TRÌNH XỬ LÝ NGẮT (TRAP HANDLER)
// Bắt buộc phải có hàm này để Linker (startup.S) không báo lỗi.
// ------------------------------------------------------------------------
extern "C" void c_trap_handler() {
    // Khi bị ngắt (do Mailbox của Core kia gửi tới), phần cứng yêu cầu
    // phải đọc thanh ghi Mailbox để tự động xóa cờ ngắt (Clear IRQ).

    // Đọc "giả" cả 2 hộp thư để dập cờ ngắt cho an toàn:
    unsigned int clear_irq_1 = ICC_MAILBOX_0TO1;
    unsigned int clear_irq_0 = ICC_MAILBOX_1TO0;

    // Ép kiểu void để Compiler GCC không báo lỗi "biến không được sử dụng"
    (void)clear_irq_1;
    (void)clear_irq_0;
}

// ------------------------------------------------------------------------
// 2. CÁC HÀM ĐỒNG BỘ PHẦN CỨNG (HARDWARE MUTEX)
// ------------------------------------------------------------------------

// Hàm khóa Mutex (Spinlock) - Ép CPU đứng chờ đến khi tranh được khóa
void mutex_lock() {
    // Thuật toán Atomic Test-And-Set: Liên tục đọc thanh ghi Mutex
    // Nếu đọc ra 1 (Bận) -> Tiếp tục vòng lặp (Spin)
    // Nếu đọc ra 0 (Rảnh) -> Phần cứng đã tự động Set lên 1, CPU chiếm được khóa
    while (ICC_MUTEX == 1) {
        // Đứng chờ
    }
}

// Hàm nhả khóa Mutex
void mutex_unlock() {
    ICC_MUTEX = 0; // Ghi 0 để nhả khóa cho Core khác dùng
}

// ------------------------------------------------------------------------
// 3. CHƯƠNG TRÌNH CHÍNH (MAIN)
// ------------------------------------------------------------------------
int main() {
    // =======================================================
    // KỊCH BẢN TEST MUTEX (ĐỒNG BỘ ĐA LUỒNG PHẦN CỨNG)
    // =======================================================

    // 1. Xin khóa Mutex
    mutex_lock();

    // 2. ------- CRITICAL SECTION (Vùng găng) -------
    // Khi đã cầm khóa, Core yên tâm vào RAM đọc, sửa, ghi
    // mà không sợ Core còn lại nhảy vào phá đám gây sai dữ liệu
    unsigned int temp = SHARED_RAM_VAR;
    temp = temp + 1;
    SHARED_RAM_VAR = temp;
    // -----------------------------------------------

    // 3. Làm xong thì nhả khóa ra
    mutex_unlock();

    // 4. (Tùy chọn) Ghi vào Mailbox báo hiệu đã làm xong
    ICC_MAILBOX_0TO1 = 0xAA;

    // Vòng lặp dừng vô tận
    while (1) {
    }

    return 0;
}
