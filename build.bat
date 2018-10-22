del *.map
del *.obj
del *.exe

nasm timer.asm -o timer.obj -f obj
nasm sound.asm -o sound.obj -f obj
nasm mixsnd.asm -o mixsnd.obj -f obj

tlink mixsnd.obj timer.obj sound.obj, mixsnd.exe