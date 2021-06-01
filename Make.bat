gcc.exe  -c -std=c99 -o main.o main.c 
gcc.exe  -c -std=c99 -o dead.o dead.c
gcc.exe -ffreestanding -c  -o dmm.o dmm.c
gcc.exe -ffreestanding -nostdlib -c -std=c99 -o  printf.o printf.c
ld.exe   -T link.ld -o extd.bin main.o startup.o printf.o dmm.o dead.o
objcopy extd.bin -O binary


echo 

pause