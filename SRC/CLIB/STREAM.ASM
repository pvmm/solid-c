; Входящие функции:
;
;  puts
;  printf
;  fprintf
;  cprintf
;  sprintf
;  scanf
;  fscanf
;  sscanf
;





	MODULE	puts
;
; "stdio.h"
; Функция записывает выбранную строку string в стандартный поток
; вывода stdout, заменяя в выходном потоке нулевой символ окончания
; строки ('\0') символом новой строки ('\n').
; Функция всегда возвращает последний записанный символ, которым
; является символ новой строки '\n'.
;
; in: hl = адрес строки
; out: a = последний символ строки
;
; char puts(*string)
;
puts_::
	ld	a,(hl)
	or	a
	jr	z,@1
	push	hl
	call	putch_##
	pop	hl
	inc	hl
	jp	puts_
	;
@1:	ld	a,0Ah
	push	af
	call	putch_##
	pop	af
	ret

	ENDMODULE


	MODULE	frmts
;-----------------------------------------------------------
; call from ..printf
;-----------------------------------------------------------
; in: hl = адрес начала параметров
;     de = адрес обработчика
;     bc = адрес передаваемых параметров
; out: hl = число выведенных символов, если Ok
;      hl = отрицательное значение, при ошибке
;
; int @spr@(char *fmt, char (* callback)(), int param)
;
;
mk_num:	ld	(mn0+1),a		; base
	ld	(chars+1),bc
	exx
	ld	hl,number
	exx
	call	mn0
	exx
	ld	(hl),0
	exx
	ld	hl,number
	ld	a,(sign)
	or	a
	ret	z
	dec	hl
	ret

;------------------------------------	
mn0:	ld	bc,200Ah
	xor	a
mn1:	add	hl,hl
	rl	e
	rl	d
	rla
	cp	c
	jr	c,mn2
	sub	c
	inc	l
mn2:	djnz	mn1
	; DEHL-quot; A-rem
	push	af
	ld	a,d
	or	e
	or	h
	or	l
	call	nz,mn0
	pop	af
	push	hl
chars:	ld	hl,char1		; save char1 or char2
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	a,(hl)
	pop	hl
	exx
	ld	(hl),a
	inc	hl
	exx
	ret

;-------------------------------------------
scan_length:
	xor	a
	ld	(flong),a		; false
	ld	(fladj),a
	ld	(flen+0),a		; make length = 0
	ld	(flen+1),a
	ld	a," "
	ld	(padch),a		; space padding by default
	ld	a,(hl)
	cp	"-"
	jr	nz,sl1
	ld	(fladj),a		; all will be LEFT adjusted, not right
	inc	hl
sl1:	ld	a,(hl)
	cp	"0"
	jr	nz,sl2
	ld	a,(fladj)
	or	a
	jr	nz,sl1a
	ld	a,"0"
	ld	(padch),a		; pad numbers with '0's, not spaces
sl1a:	inc	hl
sl2:	ld	de,0
sl2a:	ld	a,(hl)
	sub	"0"
	jr	c,sl3
	cp	9+1
	jr	nc,sl3
	ex	de,hl
	ld	c,l
	ld	b,h
	add	hl,hl
	add	hl,hl
	add	hl,bc
	add	hl,hl
	ld	b,0
	ld	c,a
	add	hl,bc
	ex	de,hl
	inc	hl
	jr	sl2a
	;
sl3:	ld	(flen),de		; set explicit length
	ld	a,(hl)
	cp	"l"
	jr	z,sl4
	cp	"L"
	ret	nz
sl4:	ld	(flong),a		; true
	inc	hl
	ret

;--------------------------------------------
_pad:	dec	hl
	bit	7,h
	ret	nz
	push	hl
	ld	a,(padch)
	call	outch
	pop	hl
	ld	de,(nprtd+1)
	inc	de
	ld	(nprtd+1),de
	jp	_pad

;=====================================================================
;
; int @spr@(char *fmt,char (* callback)(), int param)
;
;=====================================================================
@spr@::	ld	(outch1+1),bc		; optional parameter
	ld	(outch2+1),de		; callback pointer
	push	hl
	pop	iy			; at (iy+2) we have current parameter
	ld	hl,0
	ld	(nprtd+1),hl		; clear return value
	ld	l,(iy+0)		; at iy we have pointer to format string
	ld	h,(iy+1)
loop:	ld	a,(hl)
	inc	hl
	or	a
	jr	z,nprtd
	cp	"%"
	jr	z,loc3
loc4:	call	outch
	ld	de,(nprtd+1)
	inc	de
	ld	(nprtd+1),de
	jp	loop
	;
nprtd:	ld	hl,0			; return value
	ret
	;
loc3:	ld	a,(hl)
	inc	hl
	cp	"%"
	jr	z,loc4
	dec	hl
	call	scan_length		; scan [-][0][0-9*][lL]
	ld	a,(hl)
	inc	hl
	cp	"c"
	jp	z,prt_c
	cp	"C"
	jp	z,prt_c			; print single character
	cp	"d"
        jp	z,prt_d
	cp	"D"
	jp	z,prt_d			; signed decimal
	cp	"u"
	jp	z,prt_u
	cp	"U"
	jp	z,prt_u			; unsigned decimal
	cp	"o"
	jp	z,prt_o
	cp	"O"
	jp	z,prt_o			; octal
	cp	"x"
	jp	z,prt_x1
	cp	"X"
	jp	z,prt_x2		; hexadecimal
	cp	"s"
	jp	z,prt_s
	cp	"S"
	jp	z,prt_s			; string
	jp	loop
	;
; %c  symbol
prt_c:	ld	a,(iy+2)
	call	outch
	ld	de,(nprtd+1)
	inc	de
	ld	(nprtd+1),de
prt_q:	inc	iy
	inc	iy
	ld	a,(flong)
	or	a
	jp	z,loop			; false
	inc	iy
	inc	iy
	jp	loop
	;
; %s  string
prt_s:	ld	a," "
	ld	(padch),a
	push	hl
	push	iy
	ld	l,(iy+2)
	ld	h,(iy+3)
fmt0:	push	hl
	call	strlen_##
	ex	de,hl
	ld	hl,(flen)
	or	a
	sbc	hl,de
	ld	(flen),hl
	ld	a,(fladj)
	or	a
	call	z,_pad
	pop	hl
fmt1:	ld	a,(hl)
	inc	hl
	or	a
	jr	z,fmt2
	call	outch
	ld	de,(nprtd+1)
	inc	de
	ld	(nprtd+1),de
	jp	fmt1
	;
fmt2:	ld	hl,(fladj)
	ld	a,(flen)
	or	a
	call	nz,_pad
	pop	iy
	pop	hl
	jp	prt_q
	;
; %u  unsigned decimal
prt_u:	push	hl
	push	iy
	call	getnum
	jr	fmt4
	;
; %d  signed decimal
prt_d:	push	hl
	push	iy
	call	getnum
	ld	a,(flong)
	or	a
	jr	nz,fmt3			; true
	bit	7,h
	jr	z,fmt3
	ld	de,-1
fmt3:	bit	7,d
	jr	z,fmt4
	ld	a,"-"
	ld	(sign),a
	xor	a
	sub	l
	ld	l,a
	ld	a,0
	sbc	a,h
	ld	h,a
	ld	a,0
	sbc	a,e
	ld	e,a
	ld	a,0
	sbc	a,d
	ld	d,a
fmt4:	ld	a,10			; base
	ld	bc,char1
	call	mk_num
	jp	fmt0
	;
; %o  octal
prt_o:	push	hl
	push	iy
	call	getnum
	ld	a,8			; base
	ld	bc,char1
	call	mk_num
	jp	fmt0
	;
; %X  hex
prt_x2:	ld	bc,char1
prt_x:	push	hl
	push	iy
	call	getnum
	ld	a,16			; base
	call	mk_num
	jp	fmt0
	;
; %x  hex
prt_x1:	ld	bc,char2
	jr	prt_x

;---------------------------------------
getnum:	xor	a
	ld	(sign),a
	ld	l,(iy+2)
	ld	h,(iy+3)
	ld	a,(flong)
	or	a
	jr	z,gnu1			; false
	ld	e,(iy+4)
	ld	d,(iy+5)
	ret
gnu1:	ld	de,0
	ret

;---------------------------------------
outch:	push	hl
	push	iy
outch1:	ld	de,0			; optional parameter
outch2:	call	0			; callback pointer
	or	a
	jr	z,och1
	ld	hl,8000h		; -32768
	ld	(nprtd+1),hl
och1:	pop	iy
	pop	hl
	ret

char1:	db	"0123456789ABCDEF"
char2:	db	"0123456789abcdef"

	dseg
flen:	dw	0
fladj:	db	0
flong:	db	0			; false/true
padch:	db	" "
	;
sign:	db	0			; знак числа
number:	ds	16			; буфер числа

	ENDMODULE


	MODULE	xfputc
;-----------------------------------------------------------
; call from printf_, fprintf_
;-----------------------------------------------------------
; Функция выводит символ в файл *fp.
; При ошибке возвращается EOF (0FFFFh)
; in: a = выводимый символ
; out: hl=0 - Ok
;      hl=EOF (0FFFFh) - ошибка
;
; int @fputc(c, FILE *fp)
;
@fputc::
	call	fputc_##		; вывод символа в поток (файл)
	ld	hl,-1			; ошибка
	cp	l
	ret	z
	xor	a
	inc	hl			; Ok
	ret

	ENDMODULE


	MODULE	printf
;
; "stdio.h"
; Функция выводит данные с преобразованием формата в стандартный
; поток stdout из переменных, определяемых аргументами args.
; Каждый аргумент должен указывать на значение с типом, который
; соответствует типу, заданному в строке формата.
;
; in: параметры в стеке
; out: hl = число выведеных символов, если Ok
;      hl = отриц. значение (из @spr@) при ошибке
;
; int printf(char *format, arg1, arg2, ...)
;
printf_::
	ld	bc,_iob_##-14		; FILE-структура потока stdout
	ld	de,@fputc##		; адрес обработчика
	ld	hl,2
	add	hl,sp			; ячейка с адресом arg1
	jp	@spr@##

	ENDMODULE


	MODULE	fprintf
;
; "stdio.h"
; Функция выводит данные с преобразованием формата в файл *fp
; из переменных, определяемых указателями аргументов args.
; Каждый аргумент должен указывать на значение с типом, который
; соответствует типу, заданному в строке формата.
;
; in: параметры в стеке
; out: hl = число вывед. символов, если Ok
;      hl = отриц. значение (из @spr@) при ошибке
;
; int fprintf(FILE *fp, char *format, arg1, arg2, ...)
;
fprintf_::
	pop	hl
	pop	bc			; bc = адрес форм. строки
	push	bc
	push	hl
	ld	de,@fputc##		; адрес обработчика
	ld	hl,4
	add	hl,sp			; ячейка с адресом arg1
	jp	@spr@##

	ENDMODULE


	MODULE	cprintf
;
; "conio.h"
; Функция выводит с преобразованием формата наборы символов
; и значений прямо на экран.
; Каждый аргумент должен указывать на значение с типом, который
; соответствует типу, заданному в строке формата.
;
; in: данные в стеке
; out: hl = число вывед. символов, если Ok
;      hl = отриц. значение (из @spr@), при ошибке
;
; int cprintf(char *format, arg1, arg2, ...)
;
putch@:	call	putch_##
	xor	a
	ret

cprintf_::
	ld	de,putch@		; адрес обработчика
	ld	hl,2
	add	hl,sp			; ячейка с адресом arg1
	jp	@spr@##

	ENDMODULE


	MODULE	sprintf
;
; "stdio.h"
; Функция преобразует формат и выводит наборы символов и значений
; в buffer. В конец выводимой строки записывается нуль.
; Каждый аргумент должен указывать на значение с типом, который соот-
; ветствует типу, заданному в строке формата.
; Функция возвращает количество символов, записанных в buffer.
;
; int sprintf(char buffer, char *format, arg1, arg2, ...)
;
; in: de=ячейка, хранящая адрес буфера
@sspr@:	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)			; de=адрес буфера
	ld	(de),a			; сохр. символ
	inc	de
	ld	(hl),d			; сохр. тек. адрес буфера в стеке
	dec	hl
	ld	(hl),e
	xor	a
	ret

sprintf_::
	ld	hl,2
	add	hl,sp			; ячейка с адресом буфера
	ld	c,l
	ld	b,h
	ld	de,@sspr@		; адрес обработчика
	ld	hl,4
	add	hl,sp
	call	@spr@##
	ex	de,hl
	pop	bc
	pop	hl
	ld	(hl),0			; to end string
	push	hl
	push	bc
	ex	de,hl			; hl=return value
	ret

	ENDMODULE



;[]============================ scanf ==================================[]


	MODULE	xxscn
;
; call from _scn_
;
@igs@:	ex	de,hl
@41:	ld	l,e
	ld	h,d
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,(hl)
	cp	" "
	jr	z,@40
	cp	9			; Tab
	jr	z,@40
	cp	0Ah
	ret	nz
@40:	ld	l,e
	ld	h,d
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	de
	ld	(hl),d
	dec	hl
	ld	(hl),e
	pop	de
	jr	@41

; выход: hl= возвр. байт
@bc@:	ld	hl,@46+1
	ld	(hl),e			; база чисел
	call	toupper_##
	cp	"A"
	jr	c,@42
	cp	"Z"+1
	jr	c,@43
@42:	cp	"a"
	jr	c,@44
	cp	"z"+1
	jr	c,@43
@44:	cp	"_"
	jr	nz,@45
@43:	sub	"7"
	jr	@46
	;
@45:	cp	"0"
	jr	c,@47
	cp	"9"+1
	jr	nc,@47
	sub	"0"
	jr	@46
	;
@47:	ld	hl,-1			; возвр. значение
	ret
	;
@46:	ld	l,0			; сохр. значение
	cp	l
	jr	c,@48
	ld	a,-1
@48:	ld	l,a			; возвр. байт
	ld	h,0
	ret

	dseg
?95:	dw	0
?99:	dw	0
?100:	db	0			; false/true
?102:	db	0
?103:	dw	0
?104:	dw	0
?105:	dw	0

	cseg
;
; call from ..scanf
;
_scn_::
	ld	(?95),hl
	ld	l,e;
	ld	h,d;
	inc	de
	inc	de
	;ld	hl,-2
	;add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(?99),hl
	ld	l,e
	ld	h,d
	ld	(?105),hl
	xor	a
	ld	(?102),a
@50:	ld	hl,(?99)
	ld	a,(hl)
	inc	hl
	ld	(?99),hl
	or	a
	jp	z,@49
	cp	" "
	jr	z,@50
	cp	9			; Tab
	jr	z,@50
	cp	0Ah
	jr	z,@50
	cp	"%"
	jp	nz,@51
	push	hl
	ld	hl,1
	ld	(?103),hl
	ld	a,l			; a=true
	ld	(?100),a
	ld	a,10
	ld	(?101+1),a		; база чисел
	pop	hl
	ld	a,(hl)
	inc	hl
	ld	(?99),hl
	cp	"*"
	jr	nz,@52
	xor	a			; false
	ld	(?100),a
	ld	a,(hl)
	inc	hl
	ld	(?99),hl
@52:	call	toupper_##
	cp	"X"			; hex
	jr	z,@53
	cp	"O"			; octal
	jr	z,@54
	cp	"D"			; decimal
	jr	z,@55
	cp	"U"			; unsigned
	jr	z,@56
	cp	"S"			; string
	jp	z,@57
	cp	"C"			; char
	jp	z,@58
	jp	@49
	;
@53:	ld	a,16
	ld	(?101+1),a		; база чисел
	jr	@56
	;
@54:	ld	a,8
	ld	(?101+1),a		; база чисел
	jr	@56
	;
@55:	ld	hl,?95
	call	@igs@
	cp	"-"
	jr	nz,@56
	ld	hl,-1
	ld	(?103),hl
	ld	hl,(?95)
	inc	hl
	ld	(?95),hl
	;
@56:	ld	hl,0
	ld	(?104),hl
	ld	hl,?95
	call	@igs@
?101:	ld	e,0			; сохр. значение (база чисел)
	call	@bc@
	ld	a,l
	and	h
	inc	a
	jp	z,@49
@60:	ld	a,(?101+1)		; база чисел
	ld	e,a
	push	af
	ld	hl,(?95)
	ld	a,(hl)
	inc	hl
	ld	(?95),hl
	call	@bc@
	ld	a,l
	pop	de
	ld	e,d
	cp	0FFh
	jr	z,@61
	push	af
	ld	d,0
	ld	hl,(?104)
	call	?MULHD##
	pop	de
	ld	e,d
	ld	d,0
	add	hl,de
	ld	(?104),hl
	jr	@60
	;
@61:	ld	hl,(?95)
	dec	hl
	ld	(?95),hl
	jp	@62
	;
@57:	ld	hl,?95
	call	@igs@
	ld	hl,(?105)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
@65:	ld	hl,(?95)
	ld	a,(hl)
	inc	hl
	ld	(?95),hl
	ld	e,a
	inc	e
	dec	e
	jr	z,@63
	ld	hl,(?99)
	ld	a,(hl)
	cp	e
	jr	nz,@64
	inc	hl
	ld	(?99),hl
	jr	@63
	;
@64:	ld	a,(?100)
	or	a
	jr	z,@65			; false
	ld	a,e
	ld	(bc),a
	inc	bc
	jr	@65
	;
@63:	ld	hl,?100
	ld	e,(hl)
	inc	e
	dec	e
	jp	z,@50			; false
	ld	hl,(?102)
	inc	l
	ld	a,l
	ld	(?102),a
	xor	a
	ld	(bc),a
	ld	hl,(?105)
	inc	hl
	inc	hl
	ld	(?105),hl
	jp	@50
	;
@58:	ld	hl,?100
	ld	e,(hl)
	inc	e
	dec	e
	jr	z,@66			; false
	ld	hl,(?95)
	ld	a,(hl)
	ld	hl,(?105)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	(?105),hl
	ld	(bc),a
	ld	hl,(?102)
	inc	l
	ld	a,l
	ld	(?102),a
@66:	ld	hl,(?95)
	inc	hl
	ld	(?95),hl
	jp	@50
	;
@62:	ld	a,(?100)
	or	a
	jr	z,@51			; false
	ld	de,(?103)
	ld	hl,(?104)
	call	?MULHD##
	ex	de,hl
	ld	hl,(?105)
	inc	hl
	inc	hl
	ld	(?105),hl
	dec	hl
	dec	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	hl,(?102)
	inc	l
	ld	a,l
	ld	(?102),a
@51:	ld	hl,(?95)
	ld	a,(hl)
	or	a
	jp	nz,@50
@49:	ld	hl,(?102)
	ld	h,0
	ret

	ENDMODULE


	MODULE	scanf
;
; "stdio.h"
; Функция читает данные с преобразованием формата из стандартного
; потока stdin в переменные, определяемые указателями аргументов args.
; Каждый аргумент должен указывать на значение с типом, который соот-
; ветствует типу, заданному в строке формата.
; Функция использует буфер в области стека, размером 128 байт.
; Функция возвращает число полей, разделенных спец-символами.
;
; int scanf(char *format, arg1, arg2, ...)
;
scanf_::
	ld	(@1+1),sp
	ld	hl,-128			; размер буфера
	add	hl,sp			; hl=адрес буфера в стеке
	ld	sp,hl			; расположить стек ниже буфера
	call	gets_##			; ввести строку с консоли
	ex	de,hl
	ld	hl,128+2
	add	hl,sp
	ex	de,hl			; hl=указатель на буфер
	call	_scn_##
@1:	ld	sp,0
	ret

	ENDMODULE


	MODULE	fscanf
;
; "stdio.h"
; Функция читает данные с преобразованием формата из файла *fp,
; в переменные, определяемые указателями аргументов args.
; Каждый аргумент должен указывать на значение с типом, который
; соответствует типу, заданному в строке формата.
; Функция использует буфер в области стека, размером 128 байт.
; Функция возвращает число полей, разделенных спец-символами.
; При достижении конца файла, выдается EOF.
;
; int fscanf(FILE *fp, char *format, arg1, arg2, ...)
;
fscanf_::
	ld	(@68+1),sp
;	ld	(?137+1),hl		; адрес структуры дескр.
	ld	c,l;			; bc=адрес структуры дескр.
	ld	b,h;
	ld	hl,-128
	add	hl,sp
	ld	sp,hl			; расположить стек ниже буфера
;?137:	ld	hl,0
;	call	?LAUHL;##
;	dw	132
;	;
;	ld	c,l			; bc=адрес структуры дескр.
;	ld	b,h
	ld	de,127			; макс.длина строки + 1
	ld	hl,0
	add	hl,sp			; hl=адрес буфера в ячейке стека
	call	fgets_##		; получить строку из файла (потока)
	ld	a,l
	or	h
	jr	nz,@67			; без ошибок
	dec	hl			; hl=EOF
	jr	@68
	;
@67:	ex	de,hl
	ld	hl,132
	add	hl,sp
	ex	de,hl			; hl=указатель на буфер
	call	_scn_##
@68:	ld	sp,0
	ret

	ENDMODULE


	MODULE	sscanf
;
; "stdio.h"
; Функция читает данные с преобразованием формата из buffer,
; в переменные, определяемые указателями аргументов args.
; Каждый аргумент должен указывать на значение с типом, который
; соответствует типу, заданному в строке формата.
; Функция возвращает число полей, разделенных спец-символами.
;
; int sscanf(char *buffer, char *format, arg1, arg2, ...)
;
sscanf_::
	ld	hl,2
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	de,hl
	jp	_scn_##

	ENDMODULE
