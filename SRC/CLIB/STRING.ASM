; Входящие функции:
;
;  memchr
;  strcpy
;  strncpy
;  strcat
;  strncat
;  strcmp
;  strncmp
;  strchr
;  strcspn
;  strpbrk
;  strlen
;  strrchr
;  strlwr
;  strupr
;  strspn
;  strstr
;  strtok
;




	MODULE	memchr
;
; "string.h"
; Функция ищет первые count байт в buff с целью обнаружения
; первого появления символа "c". Поиск продолжается до тех пор,
; пока не будет найден указанный символ или не будут проверены
; все count байты.
; Функция возвращает указатель на расположение символа "c" в buff.
; Если символ "c" не обнаружен в первых count байтах buff, возвра-
; щается NULL.
;
; void *memchr(char *buff, c, count)
;
memchr_::
	ld	a,e			; символ
	cpir
	dec	hl
	ret	z			; найден
	ld	hl,0			; NULL
	ret

	ENDMODULE


	MODULE	strcpy
;
; "string.h"
; Функция копирует s2 в s1 (включая 0-й символ окончания строки).
; Функция возвращает указатель на s1.
;
; char *strcpy(*s1, *s2)
;
strcpy_::
	ex	de,hl
	push	de
@1:	ld	a,(hl)
	ldi
	or	a
	jp	nz,@1
	pop	hl			; вернуть адрес s1
	ret

	ENDMODULE


	MODULE	strncpy
;
; "string.h"
; Функция копирует точно count символов строки s2 в строку s1.
; Если count меньше длины s2, нулевой символ окончания строки
; не добавляется к строке s1. Если count больше длины s2, то
; s1 заполняется нулевыми символами, вплоть до достижения длины
; count.
; Функция возвращает указатель на s1.
;
; char *strncpy(*s1, *s2, count)
;
strncpy_::
	ex	de,hl
	push	de
@2:	ld	a,(hl)
@3:	ldi
	jp	pe,@4
	or	a
	jp	nz,@2
	dec	hl
	jp	@3
	;
@4:	pop	hl			; вернуть адрес s1
	ret

	ENDMODULE


	MODULE	strcat
;
; "string.h"
; Функция добавляет s2 к s1, завершая строку s1
; нулевым символом.
; Функция возвращает указатель на s1.
;
; char *strcat(*s1, *s2)
;
strcat_::
	xor	a
	ld	b,a
	ld	c,a
	push	hl
	cpir
	dec	hl
	ex	de,hl
@1:	ld	a,(hl)
	ldi
	or	a
	jp	nz,@1
	pop	hl			; вернуть адрес s1
	ret

	ENDMODULE


	MODULE	strncat
;
; "string.h"
; Функция добавляет count символов строки s2 в конец строки s1,
; завершая строку s1 нулевым символом.
; В s1 должно быть достаточно места для размещения результиру-
; ющей строки.
; Функция возвращает указатель на s1.
;
; char *strncat(*s1, *s2, count)
;
strncat_::
	xor	a
	push	hl
	ld	bc,0
	cpir
	dec	hl
	ex	de,hl
@4:	ld	a,(hl)
	or	a
	jr	z,@5
	ldi
	jp	po,@4
@5:	xor	a
	ld	(de),a
	pop	hl			; вернуть адрес s1
	ret

	ENDMODULE


	MODULE	strcmp
;
; "string.h"
; Функция производит последовательное регистро-зависимое
; сравнение символов строк s1 и s2, и продолжает это, пока
; они совпадают, либо пока одна из строк не закончится.
; Функция возвращает значение, указывающее на соотношение
; этих строк:
;	< 0	s1 < s2
;	= 0	s1 = s2
;	> 0	s1 > s2
;
; int strcmp(*s1, *s2)
;
strcmp_::
	ex	de,hl
@6:	ld	a,(de)
	sub	(hl)
        jr	nz,@7
	inc	de
	inc	hl
	ld	a,(de)
	or	a
	jp	nz,@6
@7:	ld	h,a
	ld	l,0
	ret

	ENDMODULE


	MODULE	strncmp
;
; "string.h"
; Функция производит последовательное регистро-зависимое сравнение
; символов строк s1 и s2. Количество сравниваемых символов задается
; в count. Если одна из строк заканчивается, сравнение прекращается.
; Функция возвращает значение, указывающее на соотношение этих строк:
;	< 0	s1 < s2
;	= 0	s1 = s2
;	> 0	s1 > s2
;
; int strncmp(*s1, *s2, uint count)
;
strncmp_::
	ex	de,hl
@6:	ld	a,(de)
	sub	(hl)
        jr	nz,@7
	ld	a,(de)
	or	a
	jr	z,@7
	inc	de
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jp	nz,@6
@7:	ld	h,a
	ld	l,0
	ret

	ENDMODULE


	MODULE	strchr
;
; "string.h"
; Функция находит первое вхождение "c" в string.
; Символ "c" может быть нулевым символом.
; Нулевой символ окончания string также включается в поиск.
; Функция возвращает указатель на первое вхождение "c" в string.
; Возвращается NULL, если символ не найден.
;
; char *strchr(*string, c)
;
strchr_::
	ld	a,(hl)			; string
	cp	e			; символ "c"
	ret	z
	inc	hl
	or	a
	jp	nz,strchr_
	ld	h,a			; NULL
	ld	l,a
	ret

	ENDMODULE


	MODULE	inrange
;
; вызывается из др. п/программ
;
@inran::
	ld	a,(hl)
	or	a
	ret	z
	cp	e
	inc	hl
	jp	nz,@inran
	or	0FFh
	ret

	ENDMODULE


	MODULE	strcspn
;
; "string.h"
; Находит первую часть строки в s1, не входящую в строку s2.
; Возвращает длину части строки s1, состоящей из символов, не
; найденных в строке s2. Если ни один из символов строки s1 не
; найден в s2, возвращается общая длина строки s1 без заверша-
; ющего нуля.
;
; size_t strcspn(*s1, *s2)
;
strcspn_::
	ld	b,h
	ld	c,l
	ld	hl,0
@1:	ld	a,(bc)
	or	a
	ret	z
	push	hl
	ex	de,hl
	push	hl
	ld	e,a
	call	@inran##
	pop	de
	pop	hl
	ret	nz
	inc	hl
	inc	bc
	jp	@1

	ENDMODULE


	MODULE	strpbrk
;
; "string.h"
; Функция находит первое вхождение в строке s1 любого
; символа из строки s2. Нулевой символ окончания при
; поиске не рассматривается.
; Функция возвращает указатель на первое вхождение
; символа из s2 в строке s1.
; При отсутствии общих символов в s1 и s2, возвра-
; щается NULL.
;
; char *strpbrk(*s1, *s2)
;
strpbrk_::
	ld	a,(hl)
	or	a
	jr	z,@2
@1:	push	hl
	ld	l,(hl)
	push	de
	ex	de,hl
	call	@inran##
	pop	de
	pop	hl
	ret	nz
	inc	hl
	jp	@1
	;
@2:	ld	h,a			; NULL
	ld	l,a
	ret

	ENDMODULE


	MODULE	strlen
;
; "string.h"
; Функция возвращает в байтах длину строки string,
; причем нулевой символ окончания строки, в размер
; строки не входит.
;
; size_t strlen(*string)
;
strlen_::
	xor	a
	ld	b,a
	ld	c,a
	push	hl
	cpir
	pop	de
	scf
	sbc	hl,de			; hl = длина строки
	ret

	ENDMODULE


	MODULE	strrchr
;
; "string.h"
; Функция находит последнее вхождение символа "c"
; в строке string. Нулевой символ окончания строки
; string также включается в поиск.
; Функция возвращает указатель на последнее вхождение
; символа "c" в string.
; Если заданный символ не найден, возвращается NULL.
;
; char *strrchr(*string, c)
;
strrchr_::
	ld	b,h
	ld	c,l
	ld	hl,0			; NULL
@1:	ld	a,(bc)			; string
	or	a
	ret	z
	cp	e			; символ "c"
	jp	nz,@2
	ld	h,b			; адрес вхождения
	ld	l,c
@2:	inc	bc
	jp	@1

	ENDMODULE


	MODULE	strlwr
;
; "string.h"
; Функция преобразовывает любые буквы верхнего регистра
; строки string, заканчивающейся нулем, в буквы нижнего
; регистра. Другие символы не рассматриваются.
; Функция возвращает указатель на строку string.
;
; char *strlwr(*string)
;
strlwr_::
	push	hl
@1:	ld	a,(hl)
	or	a
	jr	z,@2
	call	tolower_##		; A..Z -> a..z
	ld	(hl),a
	inc	hl
	jp	@1
	;
@2:	pop	hl			; вернуть адрес string
	ret

	ENDMODULE


	MODULE	strupr
;
; "string.h"
; Функция преобразовывает любые буквы нижнего регистра
; строки string, заканчивающейся нулем, в буквы верхнего
; регистра. Другие символы не рассматриваются.
; Функция возвращает указатель на строку string.
;
; char *strupr(*string)
;
strupr_::
	push	hl
@1:	ld	a,(hl)
	or	a
	jr	z,@2
	call	toupper_##		; a..z -> A..Z
	ld	(hl),a
	inc	hl
	jp	@1
	;
@2:	pop	hl			; вернуть адрес string
	ret

	ENDMODULE


	MODULE	strspn
;
; "string.h"
; Функция возвращает длину совпадающей части строки s1, которая
; полностью состоит из символов, найденных в строке s2. Нулевой
; символ окончания строки s2 не рассматривается.
; Если строка s1 начинается с символа, не входящего в строку s2,
; возвращается 0.
;
; size_t strspn(*s1, *s2)
;
strspn_::
	ld	b,h
	ld	c,l
	ld	hl,0			; нач. длина подстроки
@1:	ld	a,(bc)
	or	a
	ret	z
	push	hl
	ex	de,hl
	push	hl
	ld	e,a
	call	@inran##
	pop	de
	pop	hl
	ret	z			; вернуть длину подстроки
	inc	hl
	inc	bc
	jp	@1

	ENDMODULE


	MODULE	strstr
;
; "string.h"
; Функция возвращает указатель на первое вхождение
; строки s2 в строку s1.
; Функция возвращает NULL, если s2 не была найдена.
; Если длина строки s2 равна 0, возвращается s1.
;
; char *strstr(*s1, *s2)
;
strstr_::
        ld	a,(hl)
	or	a
	jr	nz,@1
	ld	l,a			; NULL
	ld	h,a
	ret
@1:	push	hl			; адрес s1
	push	de			; адрес s2
@2:	ld	a,(de)			; s2
	or	a
	jr	z,@3
	cp	(hl)			; s1
	inc	hl
	inc	de
	jp	z,@2
	pop	de
	pop	hl
	inc	hl
	jp	strstr_
	;
@3:	pop	de
	pop	hl			; вернуть адрес s1
	ret

	ENDMODULE


	MODULE	strtok
;
; "string.h"
; Поиск токена(ов).
; Функция находит в строке s1 токен, отделенный одним (или более)
; ограничителем из множества символов-ограничителей строки s2.
; Найденный токен в строке s1 оканчивается нулем.
; Для того, чтобы прочитать следующий токен из s1, функция strtok
; должна вызываться с NULL-значением для аргумента s1.
; Аргумент NULL s1 вызывает strtok на поиск следующего знака в
; предыдущей строке символов.
; Множество ограничителей в строк s2, от вызова к вызову, может
; быть различным, так что s2 может принимать любые значения.
; При каждом вызове, функция возвращает указатель на найденный
; токен строки s1, каждый раз продвигаясь вперед по строке s1.
; Функция возвращает указатель NULL, когда больше нет токенов
; в строке s1.
;
; char *strtok(*s1, *s2)
;
strtok_::
	ld	(@4+1),de		; s2
	ld	(@2+1),hl		; s1
	ld	a,l
	or	h
	jr	nz,@0
@3:	ld	hl,0			; адрес след. поиска в s1
	ld	(@2+1),hl
@0:	ld	(@1+1),hl		; s1
@2:	ld	hl,0			; тек. адрес в s1
	ld	a,(hl)
	inc	hl
	ld	(@2+1),hl
	or	a
	jr	z,@1
	ld	e,a
@4:	ld	hl,0			; сохр. адрес s2
	call	@inran##
	jr	z,@2
	ld	hl,(@2+1)		; тек. адрес в s1
	dec	hl
	ld	(hl),0			; на место найденного символа ?
	inc	hl
	ld	(@3+1),hl		; адрес след. поиска в s1
@1:	ld	hl,0			; адрес найденного символа
	ret

        ENDMODULE
