; Assembly 8086 - Playing Multiple Sounds Simultaneously Test
; Sound Blaster Direct Mode (mono 8-bit unsigned PCM 4KHz)
; 
; Written by Leonardo Ono (ono.leo@gmail.com)
; 22/10/2018
;
; target os: DOS (.EXE file extension)
; use: build.bat (requires nasm and tlink)

	bits 16

	%include "timer.inc"
	%include "sound.inc"
	
segment main

	..start: ; entry point
	
			; setup stack
			mov ax, stack_top
			mov ss, ax
			mov sp, stack_top
			
			call far install_timer_handler
			call far start_fast_clock
			
			call clear_screen
			call print_general_message
			
	main_loop:
			mov dh, 1
			call print_sound_status
			
			mov dh, 2
			call print_sound_status
			
			mov dh, 3
			call print_sound_status

			mov dh, 4
			call print_sound_status

			mov dh, 5
			call print_sound_status
			
			; wait for keypress
			mov ah, 1
			int 16h
			jz main_loop
			
			mov ah, 0
			int 16h
			
			cmp al, 27
			jz exit_process
			
			cmp al, '1'
			jz key_1_pressed

			cmp al, '2'
			jz key_2_pressed

			cmp al, '3'
			jz key_3_pressed

			cmp al, '4'
			jz key_4_pressed

			cmp al, '5'
			jz key_5_pressed
			
			jmp main_loop
			
	exit_process:
			call far stop_fast_clock
			call far uninstall_timer_handler
		
			mov ah, 4ch
			int 21h
			
	key_1_pressed:
			; play sound 1
			push word 0
			call far enable_sound
			add sp, 2
			jmp main_loop
			
	key_2_pressed:
			; play sound 2
			push word 1
			call far enable_sound
			add sp, 2
			jmp main_loop

	key_3_pressed:
			; play sound 3
			push word 2
			call far enable_sound
			add sp, 2
			jmp main_loop
	
	key_4_pressed:
			; play sound 4
			push word 3
			call far enable_sound
			add sp, 2
			jmp main_loop

	key_5_pressed:
			; play sound 5
			push word 4
			call far enable_sound
			add sp, 2
			jmp main_loop

			
	clear_screen:
			mov ah, 0h
			mov al, 3h
			int 10h
			ret
			
	print_general_message:
			mov ah, 2
			mov bh, 0
			mov dh, 1 ; row
			mov dl, 0 ; col
			int 10h
			
			mov ax, data
			mov ds, ax
			mov ah, 09h
			mov dx, general_message
			int 21h
			
			ret
			
	; dh = sound index (starts with 1)
	print_sound_status:
			shl dh, 1
			add dh, 9
			
			mov ah, 2
			mov bh, 0
			;mov dh, 1 ; row
			mov dl, 1 ; col
			int 10h
			
			sub dh, 9
			shr dh, 1
			
			call print_playing_status
			
			call print_sound_playing_progress_bar
			
			ret

	; dh = sound index (starts with 1)
	print_playing_status:
			push dx
			
			; print sound index
			mov ah, 0eh
			mov al, dh
			add al, '0'
			int 10h

			mov al, ' '
			int 10h
			
			; convert index to memory location
			mov bh, 0
			mov bl, dh
			dec bx
			mov ax, 9
			mul bx
			mov si, ax
			
			mov ax, seg active_sounds
			mov ds, ax
			mov al, [ds:active_sounds + si]
			add al, '0'
			;mov ah, 0eh
			;int 10h
			
			cmp al, '1'
			mov ax, data
			mov ds, ax
			mov ah, 09h
			jz .playing
			jmp .not_playing
		.playing:
			mov dx, playing_msg
			jmp .end
		.not_playing:
			mov dx, not_playing_msg
		.end:
			int 21h
			pop dx
			ret

	print_sound_playing_progress_bar:
			; convert index to memory location
			mov bh, 0
			mov bl, dh
			dec bx
			mov ax, 9
			mul bx
			mov si, ax
			
			mov ax, seg active_sounds
			mov ds, ax
			mov al, [ds:active_sounds + si]
		
			mov cx, 50
			cmp al, 0
			jz .start_draw
			
			mov ax, seg active_sounds
			mov ds, ax
			
			
			mov dx, 0
			mov ax, [ds:active_sounds + si + 7] ; current byte
			shr ax, 4
			
			mov bx, 50
			mul bx

			mov cx, [ds:active_sounds + si + 5] ; total bytes
			shr cx, 4
			
			div cx
			
			mov cx, ax
			; shr cx, 1
			
		.start_draw:
			mov bx, 50
			sub bx, cx
			
			cmp cx, 0
			jz .start_draw_empty
			
		.next_bar:
			mov ah, 0eh
			mov al, 219
			int 10h
			loop .next_bar
		
		.start_draw_empty:
			mov cx, bx
			
			cmp cx, 0
			jz .end
			
		.next_empty_bar:
			mov ah, 0eh
			mov al, 176
			int 10h
			loop .next_empty_bar
			
		.end:
			ret
			
segment data
	general_message 	db " Assembly 8086 - Playing Multiple Sounds Simultaneously Test", 0dh, 0ah, 0dh, 0ah
						db " Sound Blaster Direct Mode (mono 8-bit unsigned PCM 4KHz)", 0dh, 0ah, 0dh, 0ah
						db " Press 1=kingsv.wav / 2=dig.wav / 3=door.wav / 4=twinb.wav / 5=twinb2.wav", 0dh, 0ah, 0dh, 0ah
						db " Press ESC to exit$"
						
	playing_msg 		db "PLAYING $"
	not_playing_msg		db "STOP    $"
	

segment stack stack
			resb 256
	stack_top:
