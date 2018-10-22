	bits 16

	global play_mix
	global enable_sound
	
	global active_sounds
	
segment sound
			
	play_mix:
			push ds
			push es
			push si
			push di
			
			mov ax, active_sounds_segment
			mov es, ax
			
			mov dx, 127 ; --> result mixed sample
			
			mov si, 0
			mov cl, 0
		.next_sound:

			mov al, [es:active_sounds + si] ; sound s (status)
			cmp al, 0
			jz .continue
			
			; mix sound
			mov bx, [es:active_sounds + si + 7] ; sound index
			mov ax, [es:active_sounds + si + 3] ; sound segment
			mov ds, ax
			mov di, [es:active_sounds + si + 1] ; sound offset
			mov ah, 0
			mov al, [ds:di + bx] ; get sound byte sample
			add dx, ax
			sub dx, 127 ; mixed_sample = sample_a + sample_b - 127
			;mov dx, ax
			
			inc word [es:active_sounds + si + 7] ; increment sound index
			mov bx, [es:active_sounds + si + 7] ; sound index
			cmp bx, [es:active_sounds + si + 5] ; end of sound
			jb .continue

			mov word [es:active_sounds + si + 7], 300 ; sound index

			; is loop ?
			cmp byte [es:active_sounds + si], 2
			je .continue
			
			; end of sound
			mov byte [es:active_sounds + si], 0 ; sound s (status)
			
		.continue:
			add si, 9
			inc cl
			cmp cl, 15
			jbe .next_sound
			
			; limit sample 0~255
			cmp dx, 255
			jbe .play_mixed_sample
			mov dx, 255
			
		.play_mixed_sample:
			mov bl, dl
			
			; send DSP Command 10h
			mov dx, 22ch
			mov al, 10h
			out dx, al

			; send byte audio sample
			mov al, bl
			out dx, al
			
		.end:
			pop di
			pop si
			pop es
			pop ds
			retf			

	; void enable_sound(int sound_index);
	enable_sound:
			push bp
			mov bp, sp
			push es

			;mov ah, 0eh
			;mov al, 'S'
			;int 10h

			mov ax, active_sounds_segment
			mov es, ax

			mov dx, 0
			mov bx, [bp + 6]
			mov ax, 9
			mul bx
			mov bx, ax
			mov word [es:active_sounds + bx + 7], 300 ; sound index
			mov byte [es:active_sounds + bx], 1 ; sound status 
			
			pop es
			pop bp
			retf

segment active_sounds_segment

	active_sounds:
		;  s -> 0=free, 1=playing, 2=loop
		;  s  low   high  size  index
		;  -  ----  ----  ----  ----
		db 0
		dw sound_data
		dw music_sound
		dw 51029
		dw 0 ; 0

		db 0
		dw dig
		dw sound_effects
		dw 5895
		dw 0 ; 1

		db 0
		dw door
		dw sound_effects
		dw 4456
		dw 0 ; 2

		db 0
		dw twinb
		dw sound_effects
		dw 2317
		dw 0 ; 3
		
		db 0
		dw twinb2
		dw sound_effects
		dw 4541
		dw 0 ; 4

		;db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 0
		;db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 1
		;db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 2
		;db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 3
		;db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 4
		
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 5
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 6
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 7
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 8
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 9
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 10
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 11
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 12
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 13
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 14
		db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 15

		
segment music_sound

	sound_data:
			incbin "kingsv.wav" ; 51.529 bytes
		

segment sound_effects

	; sound_index dw 0


	dig:
			incbin "dig.wav" ; 5.895 bytes

	door:
			incbin "door.wav" ; 4.456 bytes

	twinb:
			incbin "twinb.wav" ; 2.817 bytes

	twinb2:
			incbin "twinb2.wav" ; 5.041 bytes




