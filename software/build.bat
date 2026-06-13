@echo off
cd /d "%~dp0"
echo ==================================================
echo      BIEN DICH FIRMWARE RISC-V (C++ va ASSEMBLY)
echo ==================================================

:: BUOC QUAN TRONG: Dan chinh xac duong dan toi thu muc 'bin' tren may cua ban vao day!
set TOOLCHAIN_PATH=C:\riscv-gcc\xpack-riscv-none-elf-gcc-15.2.0-1\bin
set PATH=%TOOLCHAIN_PATH%;%PATH%

set CC=riscv-none-elf-gcc
set OBJCOPY=riscv-none-elf-objcopy

echo [1/3] Dang bien dich startup.S va main.cpp...
%CC% -I inc -march=rv32i_zicsr -mabi=ilp32 -O0 -ffreestanding -nostdlib -c src/main.cpp -o main.o || pause && exit /b
%CC% -I inc -march=rv32i_zicsr -mabi=ilp32 -c src/startup.S -o startup.o || pause && exit /b

echo [2/3] Dang Lien ket (Linking) tao file thuc thi ELF...
%CC% -nostdlib -T linker/memory.ld startup.o main.o -o firmware.elf || pause && exit /b

echo [3/3] Dang xuat file ma may Hex cho ModelSim...
%OBJCOPY% -O verilog --verilog-data-width=4 firmware.elf core0.txt || pause && exit /b

echo.
echo ==================================================
echo   HOAN THANH TIEP THU! Da tao ra file core0.txt
echo ==================================================
pause