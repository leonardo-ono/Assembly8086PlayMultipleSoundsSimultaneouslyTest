	bits 16
	
	%include "sound.inc"

	global start_fast_clock
	global stop_fast_clock
	global install_timer_handler
	global uninstall_timer_handler
	
segment timer

	; 12ah = 4000 Hz (wav pcm sampling rate)
	start_fast_clock:
			cli
			mov al, 36h
			out 43h, al
			mov al, 2ah
			out 40h, al
			mov al, 1h
			out 40h, al
			sti
			retf

	stop_fast_clock:
			cli
			mov al, 36h
			out 43h, al
			mov al, 0h
			out 40h, al
			mov al, 0h
			out 40h, al
			sti
			retf
			
	install_timer_handler:
			cli
			mov ax, data
			mov ds, ax
			mov ax, 0
			mov es, ax
			mov ax, [es:4 * 8 + 2]
			mov [ds:int8_original_segment], ax
			mov ax, [es:4 * 8]
			mov [ds:int8_original_offset], ax
			mov word [es:4 * 8 + 2], timer
			mov word [es:4 * 8], timer_handler
			sti
			retf
			
	uninstall_timer_handler:
			cli
			mov ax, data
			mov ds, ax
			mov ax, 0
			mov es, ax
			mov ax, [ds:int8_original_offset]
			mov [es:4 * 8], ax
			mov ax, [ds:int8_original_segment]
			mov [es:4 * 8 + 2], ax
			sti
			retf
			
	timer_handler:
			push ds
			pusha

			;mov ah, 0eh
			;mov al, 'T'
			;int 10h
			
			call far play_mix
			
			mov al, 20h
			out 20h, al
			
			popa			
			pop ds
			iret  
			
section data
	int8_original_offset	dw 0
	int8_original_segment	dw 0
