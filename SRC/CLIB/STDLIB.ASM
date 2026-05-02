; Входящие функции:
;
;  rand
;  srand
;  div
;  atoi
;  strtol
;  qsort
;  bsearch
;  ?lauhl
;  ?sauhl
;  ?mulhd
;  ?mulab
;  ?dvnhd
;  min
;  max
;  abs
;  ?abshl
;  ?neghl
;  ?nothl
;  ?dvihd
;  ?dvbab
;  ?slhb
;  ?slab
;  ?srnhb
;  ?srihb
;  ?srab
;  ?cpshd
;  setjmp
;  longjmp
;  hex8
;  hex16
;  hex32
;  dec8
;  dec16
;  dec32
;





	MODULE	rand
;
; "stdlib.h"
; Функция srand устанавливает начальную точку для генерации
; множества псевдослучайных целых. В качестве аргумента seed
; для переустановки генератора используется 1. Любое другое
; значение seed устанавливает генератор в начальную случайную
; точку.
; Возвращаемого значения нет.
;
; void srand(seed)
;
srand_::
	ld	(seed+1),hl
	ret

;
; "stdlib.h"
; Функция возвращает псевдослучайное целое в интервале 0..65535.
; Перед вызовом rand, может быть вызвана функция srand для уста-
; новки начальной случайной точки.
; Функция возвращает псевдослучайное число.
;
; in: none
; out: hl=pseudo-random number, period 0..65535
;
; int rand()
;
rand_::
seed:	ld	de,0			; seed is usually 0
	ld	a,d
	ld	h,e
	ld	l,253
	or	a
	sbc	hl,de
	sbc	a,0
	sbc	hl,de
	ld	d,0
	sbc	a,d
	ld	e,a
	sbc	hl,de
	jr	nc,rnd1
	inc	hl
rnd1:	ld	(seed+1),hl
	ret

	ENDMODULE


	MODULE	div
;
; "stdlib.h"
; Функция делит num1 на num2, возвращая частное и остаток.
; Возвращает структуру типа div_t, определенную в "stdlib.h".
;
; struct divt *div(uint num1, uint num2)
;
div_::
	call	?dvihd##
	ld	(quot),hl		; частное
	ld	(rem),de		; остаток
	ld	hl,quot			; вернуть адрес структуры
	ret

quot:	dw	0			; частное
rem:	dw	0			; остаток

	ENDMODULE


	MODULE	atoi
;
; "stdlib.h"
; Функция преобразует символьную строку string в целое значение.
; Исходная строка string представляет собой последовательность
; символов, которые могут быть интерпретированы как числовое
; значение определенного типа. Функция прекращает чтение исходной
; строки, как только появится первый символ, который не может быть
; воспринят как часть числа (им может быть нулевой символ, завер-
; шающий строку).
; Функция возвращает значение int типа.
; Возвращаемое значение равно 0, если вход не может быть преобра-
; зован в значение данного типа.
; В случае переполнения, возвращаемое значение не определено.
;
; int atoi(*string)
;
atoi_::
	ex	de,hl			; de = адрес string
	xor	a
	ld	(@3+1),a
	ld	h,a
	ld	l,a
	ld	a,(de)
	cp	"-"
	jr	z,@0
	cp	"+"
	jr	z,@1
	jr	@2
	;
;@0:	ld	a,1
@0:	ld	(@3+1),a
@1:	inc	de
@2:	ld	a,(de)			; тек. адрес string
	cp	"0"
	jr	c,@3
	ld	a,(de)
	cp	"9"+1
	jr	nc,@3
	add	hl,hl
	ld	c,l
	ld	b,h
	add	hl,hl
	add	hl,hl
	add	hl,bc
	inc	de
	sub	"0"
	ld	c,a
	ld	b,0
	add	hl,bc
	jp	@2
	;
@3:	ld	a,0
	or	a
	ret	z
	xor	a
	sub	l
	ld	l,a
	ld	a,0
	sbc	a,h
	ld	h,a
	ret

	ENDMODULE


	MODULE	strtol
;
; "stdlib.h"
;
; int strtol(char *s, char **eptr, int base)
;
;	char *s          указатель на строку
;	char **eptr      указатель на конец просмотра
;	int base         используемое основание числа
;
; Функция преобразует символьную строку s в long-значение, эквивалентное числу
; с заданным base основанием. Функция прекращает чтение строки, как только
; встретится символ, который не может быть частью числа - это может быть нуле-
; вой символ '\0' в конце строки или первый цифровой символ, который больше
; или равен base. Если eptr не равен NULL, *eptr указывает на тот символ, на
; котором останавливается просмотр.
; Функция strtol предполагает, что s указывает на строку следующей структуры:
;
;	[whitespace][sign][0][x][digits]
;
; Если base лежит между 2 и 36, это значение используется как основание системы
; счисления данного числа. Если base равно 0, начальные символы строки, на
; которые указывает s, используются для определения основания. Если первый
; символ равен 0 и второй - одна из цифр от 1 до 7, то строка интерпретируется
; как восьмеричное целое. Если первый символ равен 0, а второй 'x' или 'X',
; тогда строка понимается как шестнадцатеричное целое. Если первый символ
; принадлежит к цифрам 1..9, то строка понимается как десятичное целое.
; Функция strtol возвращает значение преобразованной строки, если не было
; переполнения или потери результата.
;
strtol_::
	ld	(base),bc		; base
	push	de			; **eptr
	ld	(s@),hl			; *s
	ex	de,hl
	xor	a
	ld	(sig),a
	ld	h,a
	ld	l,a
	ld	(n@),hl
	ld	a,(de)
	cp	"-"
	jr	z,@4
	cp	"+"
	jr	z,@5
	jr	@6
	;
@4:	ld	a,1
	ld	(sig),a
@5:	inc	de
	ld	(s@),de
@6:	ld	a,c
	or	b
	jr	nz,@7
	ld	a,(de)
	cp	"0"
	jr	nz,@8
	ld	bc,8
	ld	(base),bc
	inc	de
	ld	(s@),de
	ld	a,(de)
	and	5Fh
	cp	"X"
	jr	nz,@10
	ld	bc,16
	ld	(base),bc
	inc	de
	ld	(s@),de
	jr	@10
	;
@8:	ld	bc,10
	ld	(base),bc
	jr	@10
	;
@7:	ld	a,c
	sub	16
	or	b
	jr	nz,@10
	ld	a,(de)
	cp	"0"
	jr	nz,@10
	ld	hl,1
	add	hl,de
	ld	a,(hl)
	and	5Fh
	cp	"X"
	jr	nz,@10
	inc	hl
	ld	(s@),hl
@10:	ld	e,c
	ld	d,b
	ld	hl,000Ah
	call	?CPSHD##
	jr	nc,@12
	ld	a,"9"
	jr	@13
	;
@12:	ld	a,c
	add	a,"0"
@13:	ld	(?16),a
	ld	e,c
	ld	d,b
	ld	hl,000Ah
	call	?CPSHD##
	jr	nc,@14
	ld	a,c
	add	a,57h
	jr	@15
	;
@14:	ld	a,(?16)
@15:	ld	(?17),a
@23:	ld	hl,(s@)
	ld	a,(hl)
	inc	hl
	ld	(s@),hl
	call	tolower_##
	ld	(?15),a
	cp	"0"
	jr	c,@18
	ld	hl,(?16)
	cp	l
	jr	c,@17
	cp	"a"
	jr	c,@18
	ld	hl,(?17)
	cp	l
	jr	nc,@18
@17:	ld	de,(base)
	ld	hl,(n@)
	call	?MULHD##
	ex	de,hl
	ld	a,(?15)
	cp	"9"+1
	jr	nc,@19
	ld	hl,0-"0"
	jr	@20
	;
@19:	ld	hl,0-"a"+10
@20:	add	hl,de
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,de
	ld	(n@),hl
	jr	@23
	;
@18:	ld	de,(s@)
	pop	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	a,(sig)
	ld	hl,(n@)
	or	a
	ret	z
	xor	a
	sub	l
	ld	l,a
	ld	a,0
	sbc	a,h
	ld	h,a
	ret

	dseg
s@:	dw	0
base:	dw	0
sig:	db	0
n@:	dw	0
?15:	db	0
?16:	db	0
?17:	db	0

	ENDMODULE


	MODULE	qsort
;-----------------------------------------------------------
; call from qsort
;-----------------------------------------------------------
_swp_:	ld	a,l
	or	h
	ret	z
	ld	a,(de)
	ex	af,af'
	ld	a,(bc)
	ld	(de),a
	ex	af,af'
	ld	(bc),a
	inc	de
	inc	bc
	dec	hl
	jr	_swp_

	dseg
?7:	dw	0
?10:	dw	0
?9:	dw	0
?11:	dw	0
?12:	dw	0
?13:	dw	0
?18:	dw	0

	cseg
;
; "stdlib.h"
; Функция реализует быструю сортировку таблицы данных.
;
; void qsort(*base, nel, size, *compare)
;
;        void *base;       -  указатель на таблицу
;        unsigned nel;     -  количество элементов таблицы
;        unsigned size;    -  размер в байтах элемента таблицы
;        int (*compare)(); -  указатель на функцию сравнения
;
; Аргумент compare является указателем на процедуру, поставляемую
; пользователем. В процессе сортировки, функция qsort может вызывать
; эту процедуру один или несколько раз, при каждом вызове передавая
; указатели на два элемента массива. Процедура compare должна срав-
; нивать элементы, а затем возвращать одно из следующих int-значений:
;
;     < 0      element1 < element2
;       0      element1 = element2
;     > 0      element1 > element2
;
; После отработки функции qsort, таблица содержит отсортированные
; элементы.
; В случае ошибки, возвращаемого значения нет.
;
qsort_::
	ld	(?7),hl			; base ?
	ld	hl,-80
	add	hl,sp
	ld	sp,hl
	ld	l,c			; size ?
	ld	h,b
	ld	(?9),hl
	ex	de,hl
	ld	(?10),hl		; nel ?
	ld	hl,(?7)
	ex	de,hl
	ld	hl,0
	add	hl,sp
	ld	(hl),e
	inc	hl
	ld	(hl),d
	push	de
	ld	e,c
	ld	d,b
	push	de
	ld	hl,(?10)
	ex	de,hl
	ld	hl,-1
	add	hl,de
	pop	de
	call	?MULHD##
	pop	de
	add	hl,de
	call	?SAUHL##
	dw	42
	;
	ld	hl,0
	ld	(?18),hl
@5:	inc	h
	dec	h
	jp	m,@3
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,2
	add	hl,sp
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	hl
	add	hl,hl
	ex	de,hl
	ld	hl,40
	add	hl,sp
	add	hl,de
	ld	a,c
	sub	(hl)
	inc	hl
	ld	a,b
	sbc	a,(hl)
	jr	c,@4
	ld	hl,(?18)
	dec	hl
	ld	(?18),hl
	jr	@5
	;
@4:	ld	hl,(?18)
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,2
	add	hl,sp
	add	hl,de
	push	hl
	ld	hl,(?9)
	ld	c,l
	ld	b,h
	pop	hl
	ld	a,(hl)
	sub	c
	ld	e,a
	inc	hl
	ld	a,(hl)
	sbc	a,b
	ld	d,a
	ex	de,hl
	ld	(?12),hl
	pop	hl
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,42
	add	hl,sp
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(?13),hl
	ld	(?11),hl
@12:	ld	hl,(?12)
	ld	de,(?13)
	ld	a,l
	sub	e
	ld	a,h
	sbc	a,d
	jp	nc,@6
	ex	de,hl
	ld	(?13),hl
	ex	de,hl
	add	hl,bc
	push	bc
@8:	ld	(?12),hl
	push	bc
	push	hl
	ld	hl,@1
	push	hl
	call	?LAUHL##
	dw	92+2
	;
	push	hl
	ld	hl,(?11)
	ex	de,hl
	ld	hl,(?12)
	ret
	;
@1:	pop	de
	pop	bc
	inc	h
	dec	h
	jp	p,@7
	ld	hl,(?12)
	add	hl,bc
	jr	@8
	;
@7:	push	bc
	push	de
	ld	hl,(?13)
	ex	de,hl
	ld	a,e
	sub	c
	ld	c,a
	ld	a,d
	sbc	a,b
	ld	b,a
	ld	l,c
	ld	h,b
	ld	(?13),hl
@10:	ld	hl,(?12)
	ld	a,l
	sub	c
	ld	a,h
	sbc	a,b
	jr	nc,@9
	ld	hl,@2
	push	bc
	push	hl
	call	?LAUHL##
	dw	94+2
	;
	push	hl
	ld	hl,(?11)
	ex	de,hl
	ld	l,c
	ld	h,b
	ret
	;
@2:	ex	de,hl
	ld	hl,0000h
	pop	bc
	call	?CPSHD##
	jr	nc,@9
	ld	hl,(?9)
	ld	a,c
	sub	l
	ld	c,a
	ld	a,b
	sbc	a,h
	ld	b,a
	ld	l,c
	ld	h,b
	ld	(?13),hl
	jr	@10
	;
@9:	pop	de
	pop	hl
	ld	a,e
	sub	c
	ld	a,d
	sbc	a,b
	jr	nc,@11
	call	_swp_
@11:	pop	bc
	jp	@12
	;
@6:	ld	(?12),hl
	pop	hl
	ld	(?18),hl
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,42
	add	hl,sp
	add	hl,de
	push	bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(?12)
	ex	de,hl
	pop	hl
	push	de
	call	_swp_
	ld	hl,(?18)
	ld	(?18),hl
	add	hl,hl
	ex	de,hl
	ld	hl,44
	add	hl,sp
	add	hl,de
	pop	bc
	ld	a,(hl)
	sub	c
	ld	e,a
	inc	hl
	ld	a,(hl)
	sbc	a,b
	ld	d,a
	push	de
	ld	hl,(?18)
	add	hl,hl
	ex	de,hl
	ld	hl,4
	add	hl,sp
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,c
	sub	e
	ld	l,a
	ld	a,b
	sbc	a,d
	ld	h,a
	pop	de
	call	?CPSHD##
	jr	nc,@13
	ld	l,c
	ld	h,b
	ld	(?12),hl
	ld	hl,(?18)
	ld	(?18),hl
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,4
	add	hl,sp
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(?18)
	inc	hl
	add	hl,hl
	ex	de,hl
	ld	hl,4
	add	hl,sp
	add	hl,de
	ld	(hl),c
	inc	hl
	ld	(hl),b
	pop	hl
	ld	(?18),hl
	inc	hl
	add	hl,hl
	ex	de,hl
	ld	hl,42
	add	hl,sp
	add	hl,de
	push	hl
	ld	hl,(?12)
	ld	c,l
	ld	b,h
	ld	hl,(?9)
	ld	a,c
	sub	l
	ld	e,a
	ld	a,b
	sbc	a,h
	ld	d,a
	ld	(?9),hl
	pop	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	l,c
	ld	h,b
	ex	de,hl
	ld	hl,(?9)
	ex	de,hl
	add	hl,de
	push	hl
	ld	hl,(?18)
	add	hl,hl
	ex	de,hl
	ld	hl,4
	add	hl,sp
	add	hl,de
	pop	de
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jr	@14
	;
@13:	ld	l,c
	ld	h,b
	push	bc
	ex	de,hl
	ld	hl,(?9)
	ex	de,hl
	add	hl,de
	push	hl
	ld	hl,(?18)
	ld	(?18),hl
	inc	hl
	add	hl,hl
	push	hl
	ld	hl,8
	add	hl,sp
	ex	de,hl
	ld	(?9),hl
	ex	de,hl
	pop	de
	add	hl,de
	pop	de
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	hl,(?18)
	push	hl
	add	hl,hl
	ex	de,hl
	ld	hl,46
	add	hl,sp
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(?18)
	inc	hl
	add	hl,hl
	ex	de,hl
	ld	hl,46
	add	hl,sp
	add	hl,de
	ld	(hl),c
	inc	hl
	ld	(hl),b
	pop	hl
	add	hl,hl
	ex	de,hl
	ld	hl,44
	add	hl,sp
	add	hl,de
	pop	bc
	ex	de,hl
	ld	hl,(?9)
	ex	de,hl
	ld	a,c
	sub	e
	ld	e,a
	ld	a,b
	sbc	a,d
	ld	d,a
	ld	(hl),e
	inc	hl
	ld	(hl),d
@14:	pop	hl
	inc	hl
	ld	(?18),hl
	jp	@5
	;
@3:	ld	hl,80
	add	hl,sp
	ld	sp,hl
	ret

	ENDMODULE


	MODULE	bsearch
;
; "stdlib.h"
; Функция выполняет двоичный поиск в отсортированном массиве.
;
; void *bsearch(*key, *base, num, size, *compare)
;
;     char *key;         - указатель на ключ (строку) поиска
;     char *base;        - указатель на массив
;     unsigned num;      - число элементов массива
;     unsigned size;     - размер каждого элемента
;     int (*compare)();  - указатель на функцию сравнения
;
; Аргумент compare является указателем на процедуру, поставляемую пользо-
; вателем. В процессе поиска, функция bsearch может вызывать эту процедуру
; один или несколько раз, при каждом вызове передавая указатели на два эле-
; мента массива. Процедура compare должна сравнивать элементы, а затем возв-
; ращать одно из следующих int-значений:
;
;     < 0      element1 < element2
;       0      element1 = element2
;     > 0      element1 > element2
;
; Функция bsearch возвращает указатель на первое вхождение ключа
; key в массиве.
; Возвращается NULL, если ключа key в массиве нет.
;
	dseg
?33:	dw	0
?37:	dw	0

	cseg
bsearch_::
	ld	(?33),hl
	ex	de,hl
	ld	(?37),hl
@18:	ld	a,c
	or	b
	jr	z,@16
	ld	hl,@15
	push	bc
	push	hl
	ld	hl,10
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de
	ld	de,(?37)
	ld	hl,(?33)
	ret

@15:	ld	de,(?37)
	pop	bc
	ld	a,l
	or	h
	jr	nz,@17
	ld	hl,(?37)
	ret

@17:	push	de
	dec	bc
	ld	hl,6
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	pop	hl
	add	hl,de
	ld	(?37),hl
	jr	@18
	;
@16:	ld	hl,0
	ret

	ENDMODULE


	MODULE lauhl
;
; Загрузить hl из ...
;
?lauhl::
	pop	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ex	de,hl
?laut::
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ret

	ENDMODULE


	MODULE	sauhl
;
; Сохранить hl в ...
;
?sauhl::
	ex	(sp),hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	(sp),hl
?saut::
	ex	de,hl
	add	hl,sp
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl
	ret

	ENDMODULE


	MODULE	mulhd
;
; Умножение h * d = hl
; out: hl = результат
;
?mulhd::
	ld	a,h
	ld	c,l
	ld	hl,0
	ld	b,16
@1:	add	hl,hl
	rl	c
	rla
	jr	nc,@2
	add	hl,de
@2:	djnz	@1
	ret

	ENDMODULE


	MODULE	mulab
;
; Умножение a * b
; out: a = результат
;
?mulab::
	ld	h,a
	xor	a
	ld	l,b
	ld	b,8
@1:	add	a,a
	rl	h
	jr	nc,@2
	add	a,l
@2:	djnz	@1
	ret

	ENDMODULE


	MODULE	dvnhd
;
; Беззнаковое деление hl / de
; out: hl,de = результат
;
?dvnhd::
	ld	b,d
	ld	c,e
	ld	de,0
	ld	a,16
@1:	ex	af,af'
	add	hl,hl
	rl	e
	rl	d
	jr	c,@2
	ld	a,e
	sub	c
	ld	a,d
	sbc	a,b
	jr	c,@3
@2:	or	a
	ex	de,hl
	sbc	hl,bc
	ex	de,hl
	inc	l
@3:	ex	af,af'
	dec	a
	jp	nz,@1
	ret

	ENDMODULE


	MODULE	min
;
; "stdlib.h"
; Функция сравнивает два аргумента и вoзвращает
; значение наименьшегo аргумента.
; Тип аргументoв и тип вoзвращаемoгo значения
; oдинакoв.
;
; int min(int arg1, int arg2)
;
min_::
	call	?cpshd##		; signed compare hl with de
	ret	c
	ex	de,hl
	ret

	ENDMODULE


	MODULE	max
;
; "stdlib.h"
; Функция сравнивает два аргумента и вoзвращает
; значение наибольшего аргумента.
; Тип аргументoв и тип вoзвращаемoгo значения
; oдинакoв.
;
; int max(int arg1, int arg2)
;
max_::
	push	hl
	ex	de,hl
	pop	de
	call	?cpshd##		; signed compare hl with de
	ret	nc
	ex	de,hl
	ret

	ENDMODULE


	MODULE	abs
;
; "stdlib.h"
; Возвращает значение n, равное абсолютной величине n
; in: hl = значение
; out: hl = результат
;
; int abs(int n)
;
abs_::
?abshl::
	bit	7,h
	ret	z
?neghl::
	dec	hl
?nothl::
	ld	a,l
	cpl
	ld	l,a
	ld	a,h
	cpl
	ld	h,a
	ret

	ENDMODULE


	MODULE	dvihd
;
; Знаковое деление hl / de
; out: hl,de = результат
;
?dvihd::
	ld	a,h
	or	a
	push	af		; reminder's sign
	xor	d
	push	af		; quotient's sign
	call	?abshl##
	ex	de,hl
	call	?abshl##
	ex	de,hl
	call	?dvnhd##
	pop	af
	call	m,?neghl##
	pop	af
	ret	p
	xor	a
	sub	e
	ld	e,a
	ld	a,0
	sbc	a,d
	ld	d,a
	ret

	ENDMODULE


	MODULE	dvbab
;
; Деление a / b
; out: b,a = результат
;
?dvbab::
	ld	l,a
	ld	h,b
	xor	a
	ld	b,8
@1:	sla	l
	rla
	jr	c,@2
	cp	h
	jr	c,@3
@2:	sub	h
	inc	l
@3:	djnz	@1
	ld	b,a
	ld	a,l
	ret

	ENDMODULE


	MODULE	slhb
;
; Смещение битов "hl" влево на "b" раз
;
?slhb::
	inc	b
	dec	b
	ret	z
@1:	add	hl,hl
	djnz	@1
	ret

	ENDMODULE


	MODULE	slab
;
; Смещение битов "a" влево на "b" раз
;
?slab::
	inc	b
	dec	b
	ret	z
@1:	add	a,a
	djnz	@1
	ret

	ENDMODULE


	MODULE	srnhb
;
; Беззнаковое смещение битов "hl" вправо на "b" раз
;
?srnhb::
	inc	b
	dec	b
	ret	z
@1:	srl	h
	rr	l
	djnz	@1
	ret

	ENDMODULE


	MODULE	srihb
;
; Знаковое смещение битов "hl" вправо на "b" раз
;
?srihb::
	inc	b
	dec	b
	ret	z
@1:	sra	h
	rr	l
	djnz	@1
	ret

	ENDMODULE


	MODULE srab
;
; Смещение битов "a" вправо на "b" раз
;
?srab::
	inc	b
	dec	b
	ret	z
@1:	srl	a
	djnz	@1
	ret

	ENDMODULE


	MODULE cpshd
;
; Знаковое сравнение hl с de
;
?cpshd::
	ld	a,h
	xor	d
	jp	p,@1
	ld	a,d
	cp	h
	ret
@1:	ld	a,h
	cp	d
	ret	nz
	ld	a,l
	cp	e
	ret

	ENDMODULE


	MODULE	setjmp
;
; "setjmp.h"
; Функция setjmp сохраняет состояние стека, который может быть
; последовательно восстановлен использованием функции longjmp.
; Функции setjmp и longjmp обеспечивают возможность выполнения
; нелокального (nonlocal) перехода и обычно используются для пере-
; дачи управления к обработке ошибок для восстановления кода в
; ранее вызванной процедуре (без использования обычного вызова),
; для возврата условных обозначений. Вызов setjmp активизирует
; сохранение текущего состояния стека в env. Последующий вызов
; longjmp восстанавливает сохраненное состояние и возвращает управ-
; ление на указатель (точку входа), непосредственно следующий за
; соответствующим вызовом setjmp.
;
; int setjmp(jmp_buf env)
;
setjmp_::
	push	ix
	pop	bc
	push	hl
	pop	iy
	ld	hl,2
	add	hl,sp
	ld	(iy+0),l		; SP value
	ld	(iy+1),h
	ld	(iy+2),c
	ld	(iy+3),b
	pop	hl
	ld	(iy+4),l
	ld	(iy+5),h
	push	hl
	ld	hl,0
	ret
;
; void longjmp(jmp_buf env, int retval)
;
longjmp_::
	push	hl
	pop	iy
	ld	l,(iy+0)
	ld	h,(iy+1)
	ld	c,(iy+2)
	ld	b,(iy+3)
	ld	sp,hl
	ld	l,(iy+4)
	ld	h,(iy+5)
	push	hl
	push	bc
	pop	ix
	ex	de,hl
	ld	a,h
	or	l
	ret	nz
	inc	hl
	ret

	ENDMODULE


	MODULE	hex32
;
; "stdlib.h"
; Функция выводит в шестнадцатеричном формате значения
; аргументов high и low как одно число.
; Возвращаемого значения нет.
;
; void hex32(uint high, uint low)
;
hex32_::
	push	de
	call	hex16_##
	pop	hl
	jp	hex16_##

	ENDMODULE


	MODULE	hex16
;
; "stdlib.h"
; Функция выводит в шестнадцатеричном формате значение value.
; Диапазон выводимых значений 0x0000..0xFFFF
; Возвращаемого значения нет.
;
; void hex16(uint value)
;
hex16_::
	ld	a,h
	push	hl
	call	hex8_##
	pop	hl
	ld	a,l
	jp	hex8_##

	ENDMODULE


	MODULE	hex8
;
; "stdlib.h"
; Функция выводит в шестнадцатеричном формате значение value.
; Диапазон выводимых значений 0x00..0xFF.
; Возвращаемого значения нет.
;
; void hex8(char value)
;
hex8_::
	push	af
	rra
	rra
	rra
	rra
	call	@1
	pop	af
@1:	and	0Fh
	cp	9+1
	sbc	a,69h
	daa
	ld	c,5Bh
	rst	10h
	ret

	ENDMODULE


	MODULE	dec8
;
; "stdlib.h"
; Функция выводит аргумент value в десятичном формате,
; без ведущих нулей.
; Диапазон выводимых значений 0..255.
; Функция не возвращает никакого значения.
;
; void dec8(char value)
;
dec8_::
	push	iy
	ld	l,a
	ld	h,0
	ld	iy,_@tmp_##
	res	7,(iy+0)
	jp	__dec3_##

	ENDMODULE


	MODULE	dec16
;
; "stdlib.h"
; Функция выводит аргумент value в десятичном формате,
; без ведущих нулей.
; Диапазон выводимых значений 0..65535.
; Функция не возвращает никакого значения.
;
; void dec16(uint value)
;
dec16_::
	push	iy
	exx
	ld	hl,0			; ст. разряд
	exx
	ld	iy,_@tmp_##
	res	7,(iy+0)
	jp	__dec5_##

	ENDMODULE


	MODULE	dec32
;
; "stdlib.h"
; Функция выводит аргументы high и low как одно значение.
; Вывод происходит в десятичном формате, без ведущих нулей.
; Диапазон выводимых значений 0...4 млрд.
; Функция не возвращает никакого значения.
;
; void dec32(uint high, uint low)
;
dec32_::
	push	hl
	exx
	pop	hl			; hl' = ст. разряд
	exx
	ex	de,hl			; hl = мл. разряд
	push	iy
	ld	de,0CA00h
	exx
	ld	de,3B9Ah		; 1.000.000.000
	exx
	ld	iy,_@tmp_
	res	7,(iy+0)
	call	GetLenN32
	ld	de,0E100h
	exx
	ld	de,05F5h		; 100.000.000
	exx
	call	GetLenN32
	ld	de,9680h
	exx
	ld	de,98h			; 10.000.000
	exx
	call	GetLenN32
	ld	de,4240h
	exx
	ld	de,0Fh			; 1.000.000
	exx
	call	GetLenN32
	ld	de,86A0h
	exx
	ld	de,1			; 100.000
	exx
	call	GetLenN32
__dec5_::
	ld	de,10000
	exx
	ld	de,0			; 10.000
	exx
	call	GetLenN32
	ld	de,1000			; 1.000
	call	GetLenN16
__dec3_::
	ld	de,100			; 100
	call	GetLenN16
	ld	de,10			; 10
	call	GetLenN16
	ld	a,l
	add	a,"0"
	ld	c,5Bh
	rst	10h
	pop	iy
	ret

_@tmp_::db	0

GetLenN32:
	ld	a,2Fh
	and	a
GetLenN321:
	inc	a
	sbc	hl,de
	exx
	sbc	hl,de
	exx
	jp	nc,GetLenN321
	add	hl,de
	exx
	adc	hl,de
	exx
	jr	GetLenN160
	;
GetLenN16:
	ld	a,2Fh
	and	a
GetLenN161:
	inc	a
	sbc	hl,de
	jp	nc,GetLenN161
	add	hl,de
GetLenN160:
	cp	"0"
	jr	z,GetLenN162
	set	7,(iy+0)
GetLenN162:
	bit	7,(iy+0)
	ret	z			; без ведущ. нулей
	ld	c,5Bh
	rst	10h
	ret

	ENDMODULE
