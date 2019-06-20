all:
	make image
ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin -l ipl.lst 
head.bin: head.asm
	nasm head.asm -o head.bin -l head.lst
func.o: func.asm
	nasm -g -f elf func.asm -o func.o
bootpack.bin: bootpack.c harimain.ld func.o
	gcc -march=i486 -m32 -nostdlib -T harimain.ld -g bootpack.c func.o -o bootpack.bin -fno-pic
os.sys: head.bin bootpack.bin
	cat head.bin bootpack.bin > os.sys
image: ipl.bin os.sys a.img
	dd if=ipl.bin of=a.img bs=512 count=1 conv=notrunc
	dd if=os.sys of=a.img bs=512 seek=33 count=1 conv=notrunc
run:
	bochs -f bochsrc

.PHONY: clean
clean:
	rm -rf bootpack.bin func.o haribote.* os.sys {head,ipl}.{bin,lst}
