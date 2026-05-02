; Функции проверены.
;
; Функции _getscon, _getcon (нужны ?), putdec (вывод числа в десятичном
; формате на экран) закомментарины.
;
;
; Входящие функции:
;
;  putch
;  getch
;  getche
;  cputs
;  clrscr
;  home
;  gotoxy
;  kbhit
;  cgets
;  inp
;  outp
;





	MODULE	putch
;
; "conio.h"
; Функция выводит символ прямо на экран.
;
; in: a = символ
; out: нет
;
; void putch(char *c)
;
putch_::
	cp	0Ah
	jr	nz,cputc
	call	cputc
	ld	a,0Dh
cputc:	;push	ix
	ld	c,5Bh
	rst	10h
	;pop	ix
	ret

	ENDMODULE


	MODULE	getch
;
; "conio.h"
; Функция читает символ с клавиатуры
; без отображения на экране.
;
; in: нет
; out: a = прочитанный символ
;
; char getch()
;
getch_::
	;push	ix
	ld	c,30h
	rst	10h
	;pop	ix
	ret

	ENDMODULE


	MODULE	getche
;
; "conio.h"
; Функция читает символ с клавиатуры с отображением на экране.
; При нажатии на Ctrl+Z или Ctrl+C, выдает значение -1.
;
; in: нет
; out: a = прочитанный символ
;
; char getche()
;
getche_::
@1:	;push	ix
	ld	c,32h
	rst	10h
	ld	a,e
	;pop	ix
	bit	7,d
	jr	z,@3			; normal input
	bit	5,b
	jr	z,@3			; not Ctrl+..
	ld	a,d
	cp	0AAh			; Ctrl+Z  (d = 7 bit "1")
	jr	z,@2
	cp	0ACh			; Ctrl+C
	jr	nz,@1
@2:	ld	a,-1			; end of input
	ret
@3:	cp	0Dh
	ret	nz
	push	af
	ld	a,0Ah
	call	putch_##
	pop	af
	ret

	ENDMODULE


	MODULE	cputs
;
; "conio.h"
; Функция выводит строку прямо на экран.
; Строка должна оканчиваться нулем.
;
; in: hl = адрес строки
; out: нет
;
; void cputs(char *str)
;
cputs_::
	ld	a,(hl)
	or	a
	ret	z
	call	putch_##
	inc	hl
	jp	cputs_

	ENDMODULE


	MODULE	clrscr
;
; "conio.h"
; Очищение экрана.
;
; in: нет
; out: нет
;
; void clrscr()
;
clrscr_::
	ld	de,0			; левый верх. угол
	ld	hl,2050h		; Y/X размеры окна
	ld	bc,0756h		; b=атрибут фона
	ld	a," "			; символ заполнитель
	rst	10h
	ret

	ENDMODULE


	MODULE	home
;
; "conio.h"
; Курсор в левый верхний угол.
;
; in: нет
; out: нет
;
; void home()
;
home_::
	ld	de,0			; Y/X position cursor
	ld	c,52h
	rst	10h
	ret

	ENDMODULE


	MODULE	gotoxy
;
; "conio.h"
; Установить курсор на X,Y позицию.
;
; in: l,e = X,Y координаты
; out: нет
;
; void gotoxy(int x, int y)
;
gotoxy_::
	ld	d,e			; Y полож.
	ld	e,l			; X полож.
	dec	d
	dec	e
	ld	c,52h
	rst	10h
	ret

	ENDMODULE


	MODULE	kbhit
;
; "conio.h"
; Функция проверяет нажатие клавиши на клавиатуре.
; Возвращает BOOL.
;
; in: нет
; out: a=true  - клавиша нажата
;      a=false - клавиша не нажата
;
; BOOL kbhit()
;
kbhit_::
	;push	ix
	ld	c,33h
	rst	10h
	;pop	ix
	or	a
	ret	z			; false
	ld	a,1			; true
	ret

	ENDMODULE


	MODULE	cgets
;
; "conio.h"
; Функция читает строку символов прямо с консоли, запоминает строку и ее
; длину в аргументе str. Аргумент str должен быть указателем на массив
; символов. Первый элемент массива - str[0] должен содержать максимальную
; длину (в символах) читаемой строки. Массив должен быть достаточно большим,
; чтобы вместить строку и заключительный нуль. Функция продолжает считывать
; символы, пока не будет прочитан код новой строки (0x0D) или заданное коли-
; чество символов. При этом, код новой строки заменяется на нуль. Строка запо-
; минается с str[2] элемента массива. Во втором элементе массива str[1] запо-
; минается действительная длина строки.
; Функция возвращает указатель на начало строки, находящейся в str[2].
; В случае ошибки, возвращаемое значение не определено.
;
; char *cgets(*str)
;
cgets_::
	;push	ix			; for _gets_
	ld	b,(hl)			; str[0]  max len string
	inc	hl
	call	__gets_##
	inc	hl
	ret

	ENDMODULE


;	MODULE	putdec
;
; "conio.h"
; Выводит число в десятичном формате на экран.
;
; in: hl = значение
; out: нет
;
; void putdec(int num)
;
;putdec_::
;	bit	7,h			; проверим знак числа
;	jr	z,@1
;	; отриц. число
;	call	?NEGHL##
;	ld	a,"-"
;	call	putch_##		; вывод символа прямо на экран
;@1:	ld	de,0
;	ld	c,e
;	ld	b,16
;@2:	add	hl,hl
;	ld	a,e
;	adc	a,a
;	daa
;	ld	e,a
;	ld	a,d
;	adc	a,a
;	daa
;	ld	d,a
;	rl	c
;	djnz	@2
;	ld	hl,mystr		; буфер числа
;	call	@fhexw
;	ld	e,c
;	call	@fhexb
;	ld	(hl),0
;	ld	hl,mystr
;	ld	bc,4
;	ld	a," "
;	cpir
;	jp	cputs_##		; вывести строку прямо на экран
;
; de в буфер
;@fhexw:push	de
;	ld	e,d
;	call	@fhexb
;	pop	de
;@fhexb:ld	a,e
;	push	af
;	rrca
;	rrca
;	rrca
;	rrca
;	call	@3
;	pop	af
;@3:	and	0Fh
;	add	a,"0"
;	cp	"9"+1
;	jr	c,@4
;	add	a,7
;@4:	ld	(hl),a
;	inc	hl
;	ret
;
;	dseg
;mystr:	ds	6			; буфер числа
;
;	ENDMODULE


;	MODULE	getscon
;
; Получить строку с консоли.
; Макс. длина строки 128 символов, без кодов концовки строки.
; in: e = ?
; out: hl = адрес буфера строки, если Ok
;      hl = NULL при ошибке
;
;_getscon_::
;	push	ix
;	ld	a,e			; перенес сюда
;	ex	de,hl
;	ld	hl,-130
;	add	hl,sp
;	ld	sp,hl
;	ex	de,hl			; hl=адрес буфера функции
;	push	hl
;	ld	(?23+1),hl
;	dec	a
;	dec	a
;	ld	hl,2
;	add	hl,sp
;	ld	(hl),a
;	ld	hl,2
;	add	hl,sp
;	ex	de,hl			; de=адрес буфера
;	ld	c,0Ah			; чтение в консольный буфер
;	call	5
;	ld	e,0Ah
;	ld	c,2			; вывести символ на зкран
;	call	5
;	ld	hl,4
;	add	hl,sp
;	ld	a,(hl)
;	pop	hl
;	cp	1Ah			; конец ввода строки
;	jr	nz,@5
;	ld	hl,0			; hl=null
;	jr	@6
;	;
;@5:	push	hl
;	ld	hl,3
;	add	hl,sp
;	ld	c,(hl)
;	ld	hl,4
;	add	hl,sp
;	ex	de,hl
;	pop	hl
;@8:	dec	c
;	ld	a,c
;	inc	a
;	jr	z,@7
;	ld	a,(de)
;	inc	de
;	ld	(hl),a
;	inc	hl
;	jr	@8
;	;
;@7:	ld	(hl),0Ah
;	inc	hl
;	xor	a
;	ld	(hl),a
;?23:	ld	hl,0			; hl,(?23)  адрес буфера строки
;@6:	ex	de,hl
;	ld	hl,130
;	add	hl,sp
;	ld	sp,hl
;	ex	de,hl
;	pop	ix
;	ret
;
;	ENDMODULE


;	MODULE	getcon
;
; Получить символ с консоли с эхом.
; Обрабатывает код 0Dh.
;
;_getcon_::
;	push	ix
;	ld	c,1			; ввод символа с клавиатуры
;	call	5
;	cp	0Dh
;	ret	nz
;	ld	a,0Ah
;	push	af
;	ld	c,2			; вывод символа на экран
;	ld	e,a
;	call	5
;	pop	af
;	pop	ix
;	ret
;
;	ENDMODULE


	MODULE	inp
;
; "conio.h"
; Функция читает 1 байт из порта port.
; Аргумент port может быть любым беззнаковым
; целым числом в диапазоне от 0 до 65535.
; Функция возвращает прочитанный байт из port.
;
; char inp(uint port);
;
inp_::
	ld	c,l
	ld	b,h
	in	a,(c)
	ret

	ENDMODULE


	MODULE	outp
;
; "conio.h"
; Функция записывает значение value в порт port.
; Аргумент port может быть любым беззнаковым целым
; числом в диапазоне от 0 до 65535. Аргумент value
; может быть любым целым числом в диапазоне от 0
; до 255.
; Функция возвращает записываемый байт.
;
; char outp(uint port, char value);
;
outp_::
	ld	c,l
	ld	b,h
	ld	a,e
	out	(c),a
	ret

	ENDMODULE
