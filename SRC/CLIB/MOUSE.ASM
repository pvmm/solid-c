; Входящие функции:
;
;  ms_init	(initMouse)
;  ms_show	(showMouse)
;  ms_hide	(hideMouse)
;  ms_stat	(getStatMouse)
;  msgstat	(getGStatMouse)
;  ms_spos	(setPosMouse)
;  ms_ybnd	(yLimMouse)
;  ms_xbnd	(xLimMouse)
;  ms_scur	(setCursMouse)
;  ms_tcur	(setTxtMouse)
;  ms_gcur	(getCursMouse)
;  ms_gsen	(getSensMouse)
;  ms_ssen	(setSensMouse)
;  ms_hard	(hardMouse)
;  ms_vmod	(vmodeMouse)
;  ms_ref	(refreshMouse)
;




	MODULE	msinit
;
; "mouse.h"
; Initialization the mouse driver.
; Returns 0 if mouse installed, -1 if not.
;
; char initMouse(void)
;
ms_init_::
	ld	c,0
	rst	30h
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msshow
;
; "mouse.h"
; Функция выводит на экран курсор мыши, отслеживает
; все перемещения курсора и перерисовывает его.
;
; При ошибке, возвращается значение -1 и errno
; содержит номер ошибки.
;
; char showMouse(void)
;
ms_show_::
	ld	c,1
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	mshide
;
; "mouse.h"
; Функция стирает курсор мыши с экрана, но драйвер продолжает
; отслеживание перемещения мыши и нажатие на кнопки.
;
; При ошибке, возвращается значение -1 и errno
; содержит номер ошибки.
;
; char hideMouse(void)
;
ms_hide_::
	ld	c,2
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msstat
;
; "mouse.h"
; Чтение состояния мыши.
; Функция возвращает текущие текстовые координаты курсора мыши
; и состояние ее кнопок.
; Функция возвращает указатель на структуру MSSTAT, определенную
; в "mouse.h".
; При ошибке, возвращается значение -1 (0FFFFh) и errno содержит
; номер ошибки.
;
; выходные данные:
;  A - состояние кнопок
;      0 bit - левая
;      1 bit - правая
;  HL - Y/X текст. координаты
;
; MSSTAT *getStatMouse()
;
ms_stat_::
	ld	c,3			; получить коорд. мышки
	rst	30h
	jr	c,@1
	ld	(button),a
	srl	h
	rr	l
	srl	h
	rr	l
	srl	l
	ld	a,e			; Y координата (0-255)
	rra
	rra
	rra
	and	1Fh
	ld	h,a			; hl = Y/X коорд. в знакоместах
	ld	(x),hl
	ld	hl,button		; Ok
	ret
	;
@1:	ld	(errno_##),a
	ld	hl,-1			; error
	ret

	dseg
button:	db	0
x:	dw	0			; Y/X текст. координаты

	ENDMODULE


	MODULE	msgstat
;
; "mouse.h"
; Чтение состояния мыши.
; Функция возвращает текущие графические координаты курсора мыши
; и состояние ее кнопок.
; Функция возвращает указатель на структуру MSGSTAT, определенную
; в "mouse.h".
; При ошибке, возвращается значение -1 (0FFFFh) и errno содержит
; номер ошибки.
;
; выходные данные:
;  A - состояние кнопок
;      0 bit - левая
;      1 bit - правая
;  HL - x-координата
;  DE - y-координата
;
; MSGSTAT *getGStatMouse()
;
msgstat_::
	ld	c,3
	rst	30h
	ld	(button),a
	ld	(errno_##),a
	ld	(x),hl
	ld	(y),de
	ld	hl,button		; Ok
	ret	nc
	ld	hl,-1			; error
	ret

	dseg
button:	db	0
x:	dw	0
y:	dw	0

	ENDMODULE


	MODULE	msspos
;
; "mouse.h"
; Установка текстовых координат курсора мыши.
; Функция перемещает курсор мыши в заданные координаты.
;
; При ошибке, возвращается значение -1 и errno содержит
; номер ошибки.
; 
; входные данные:
;  HL - колонка
;  DE - строка
;
; char setPosMouse(int col, int line)
;
ms_spos_::
	sla	l			; *2
	rl	h
	sla	l
	rl	h			; hl = X pos
	ld	a,e
	and	1Fh
	rla
	rla
	rla
	ld	e,a			; de = Y pos
	ld	c,4
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	mssgpos
;
; "mouse.h"
; Установка графических координат курсора мыши.
; Функция перемещает курсор мыши в заданные координаты.
;
; При ошибке, возвращается значение -1 и errno содержит
; номер ошибки.
; 
; входные данные:
;  HL - x-координата
;  DE - y-координата
;
; char setGPosMouse(int x, int y)
;
mssgpos_::
	ld	c,4
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msybnd
;
; "mouse.h"
; Задание вертикальных границ перемещения курсора.
; Функция задает верхнюю минимальную и нижнюю максимальную координаты,
; в которых может перемещаться курсор мыши по вертикали.
;
; При ошибке, возвращается значение -1 и errno содержит номер ошибки.
; 
; входные данные:
;  HL - y-минимальная
;  DE - y-максимальная
;
; char yLimMouse(int miny, int maxy)
;
ms_ybnd_::
	ld	c,7
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msxbnd
;
; "mouse.h"
; Задание горизонтальных границ перемещения курсора.
; Функция задает левую минимальную и правую максимальную координаты,
; в которых может перемещаться курсор мыши по горизонтали.
;
; При ошибке, возвращается значение -1 и errno содержит номер ошибки.
; 
; входные данные:
;  HL - x-минимальная
;  DE - x-максимальная
;
; char xLimMouse(uint minx, uint maxx)
;
ms_xbnd_::
	ld	c,8
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msscur
;
; "mouse.h"
; Загрузка изображения курсора мыши.
; Функция загружает новое изображение курсора мыши в драйвер
; и задает активную точку изображения.
; Перед вызовом функции, должна быть заполнена структура
; MSCURS, определенная в "mouse.h".
;
; При ошибке, возвращается значение -1 и errno содержит номер
; ошибки.
;
; входные данные:
;   H - высота курсора
;   L - ширина курсора
;   D - Y активная точка
;   E - X активная точка
;  IX - изображение курсора
;
; char setCursMouse(MSCURS *p)
;
ms_scur_::
	push	ix
	ld	c,(hl)			; width
	inc	hl
	ld	b,(hl)			; high
	inc	hl
	ld	e,(hl)			; xpoint
	inc	hl
	ld	d,(hl)			; ypoint
	inc	hl
	ld	a,(hl)			; *buffer
	ld	lx,a
	inc	hl
	ld	a,(hl)
	ld	hx,a
	ld	l,c
	ld	h,b
	ld	bc,9
	rst	30h
	pop	ix
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	mstcur
;
; "mouse.h"
; Установка курсора мыши в текстовом режиме.
; Функция устанавливает символ и атрибут курсора мыши
; для текстового режима.
; При ошибке, возвращается значение -1 и errno содержит
; номер ошибки.
;
; входные данные:
;   E - XOR attribut mask
;   D - AND attribut mask
;   L - XOR simbol mask
;   H - AND simbol mask
;
; char setTxtMouse(MSTXT *p)
;
ms_tcur_::
	ld	e,(hl)			; XOR attribut mask
	inc	hl
	ld	d,(hl)			; AND attribut mask
	inc	hl
	ld	a,(hl)			; XOR simbol mask
	inc	hl
	ld	h,(hl)			; AND simbol mask
	ld	l,a
	ld	bc,0Ah
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msgcur
;
; "mouse.h"
; Получение изображения курсора из драйвера мыши.
; Функция возвращает указатель на заполненную структуру MSCURS,
; определенную в "mouse.h".
; При ошибке, возвращается значение -1 (0FFFFh) и errno содержит
; номер ошибки.
;
; входные данные:
;  IX - буфер для изображения курсора
;
; выходные данные:
;  H - высота курсора
;  L - ширина курсора
;  D - Y активная точка
;  E - X активная точка
;
; MSCURS *getCursMouse(char *buffer)
;
ms_gcur_::
	push	ix
	push	hl
	pop	ix
	ld	(buff),hl
	ld	c,0Bh
	rst	30h
	pop	ix
	ld	(errno_##),a
	ld	(width),hl
	ld	(xpoint),de
	ld	hl,width		; Ok
	ret	nc
	ld	hl,-1			; error
	ret

	dseg
width:	db	0			; ширина курсора
	db	0			; высота курсора
xpoint:	db	0			; X активная точка
	db	0			; Y активная точка
buff:	dw	0			; адрес буфера изображения курсора

	ENDMODULE


	MODULE	msgsens
;
; "mouse.h"
; Получение значения чувствительности перемещения мыши
; по вертикали и горизонтали.
; Функция возвращает указатель на заполненную структуру MSSENS,
; определенную в "mouse.h".
; При ошибке, возвращается значение -1 (0FFFFh) и errno содержит
; номер ошибки.
;
; выходные данные:
;   H - чувствительность по вертикали
;   L - чувствительность по горизонтали
;
; MSSENS *getSensMouse()
;
ms_gsen_::
	ld	c,0Eh
	rst	30h
	ld	(errno_##),a
	ld	(hsens),hl
	ld	hl,hsens		; Ok
	ret	nc
	ld	hl,-1			; error
	ret

	dseg
hsens:	db	0			; чувств. по горизонтали
	db	0			; чувств. по вертикали

	ENDMODULE


	MODULE	mssens
;
; "mouse.h"
; Функция устанавливает значения чувствительности перемещения
; мыши по вертикали и горизонтали.
; Перед вызовом функции, должна быть заполнена структура
; MSSENS, определенная в "mouse.h".
; При ошибке, возвращается значение -1 и errno содержит номер
; ошибки.
;
; входные данные:
;   H - чувствительность по вертикали
;   L - чувствительность по горизонтали
;
; char setSensMouse(MSSENS *p)
;
ms_ssen_::
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	c,0Fh
	rst	30h
	ld	(errno_##),a
	ld	a,0
	ret	nc
	dec	a
	ret

	ENDMODULE


	MODULE	mshard
;
; "mouse.h"
; Обработчик аппаратного прерывания от мыши.
; По приходу прерывания от мыши, вызывается данная функция драйвера.
; В случае, когда требуется работа подпрограммы при запрещенных преры-
; ваниях, используйте данную функцию, для избежания потерь пакетов
; данных от мыши.
; При ошибке, возвращается значение -1 и errno содержит номер ошибки.
; 
; char hardMouse()
;
ms_hard_::
	ld	c,80h
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msvmode
;
; "mouse.h"
; Информирование о смене режима экрана.
; Функция информирует драйвер мыши об изменении режима экрана.
; Номера режимов соответствуют функции установки режима экрана.
;
; При ошибке, возвращается значение -1 и errno содержит номер
; ошибки.
;
; входные данные:
;   A - режим экрана
;
; char vmodeMouse(char video_mode)
;
ms_vmod_::
	ld	c,81h
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE


	MODULE	msref
;
; "mouse.h"
; Принудительная перерисовка курсора.
; Функция перерисовывает изображение курсора мыши на экране
; не дожидаясь очередного прерывания.
; При ошибке, возвращается значение -1 и errno содержит
; номер ошибки.
;
; char refreshMouse()
;
ms_ref_::
	ld	c,83h
	rst	30h
	ld	(errno_##),a
	ld	a,0			; Ok
	ret	nc
	dec	a			; error
	ret

	ENDMODULE
