; В _fopen_ код для "t" выкинуть ?.
;



;
; Входящие функции:
;
;  _main_
;  exit
;  atexit
;  fclosall
;  fflush
;  fgetpos
;  fsetpos
;  rewind
;  fseek
;  ftell
;  clearerr	-  проверить передаются ли все 9 символов имени "clearerr_"
;  fdopen
;  freopen
;  fopen
;  fclose
;  gets
;  ungetc
;  fputc
;  fputs
;  fgetc
;  fgets
;  fwrite
;  fread
;





;////////////////////////////////////////////////////////////////////////
;
;	C root MODULE - open standart i/o
;
;////////////////////////////////////////////////////////////////////////

	MODULE	root2
;
;
; in: hl = кол-во аргументов (макс.32)
;     de = адрес массива _argv_ (список аргументов ком. строки)
;
	cseg
_main_::
	xor	a
	ld	(atxcount),a		; сбр. число зарегист. функций
	push	de
	push	hl
	ld	hl,fclosall_		; func
	call	atexit_			; set as "exit function"
	;---------------------------------------------------
	;  initialize standard streams (without buffer)
	;---------------------------------------------------
	; stdin "read only"
	ld	iy,_iob_##		; FILE stdin
	ld	hl,-1
	ld	(iy+6),l		; descriptor
	ld	(iy+7),h
	set	0,(iy+0)		; set "read only"
	set	1,(iy+1)		; set "stdin" (keyboard)
	; stdout "write only"
	ld	iy,_iob_##-14		; FILE stdout
	dec	hl			; -2
	ld	(iy+6),l		; descriptor
	ld	(iy+7),h
	set	1,(iy+0)		; set "write only"
	set	2,(iy+1)		; set "stdout" (screen)
	; stderr "write only"
	ld	iy,_iob_##-28		; FILE stderr
	dec	hl			; -3
	ld	(iy+6),l		; descriptor
	ld	(iy+7),h
	set	1,(iy+0)		; set "write only"
	set	3,(iy+1)		; set "stderr" (screen)
	; stdaux "write only"
	ld	iy,_iob_##-42		; FILE stdaux
	dec	hl			; -4
	ld	(iy+6),l		; descriptor
	ld	(iy+7),h
	set	1,(iy+0)		; set "write only"
	set	4,(iy+1)		; set "stdaux" (serial port)
	; stdprn "write only"
	ld	iy,_iob_##-56		; FILE stdprn
	dec	hl			; -5
	ld	(iy+6),l		; descriptor
	ld	(iy+7),h
	set	1,(iy+0)		; set "write only"
	set	5,(iy+1)		; set "stdprn" (printer)
	pop	hl			; count arguments (max.32)
	pop	de			; addr list of arguments (_argv_)

	call	main_##			; func main()

;
; "stdlib.h"
; Функция завершает вызванный процесс. Перед завершением процесса,
; функция сбрасывает все буферы в файлы и закрывает все открытые файлы.
; Перед выходом в операционую систему, функция предварительно вызывает
; на отработку зарегистрированные функции "exit function" (отрабатыва-
; ющие перед выходом в ДОС).
; Значение code обычно устанавливается в 0 для указания нормального вы-
; хода и устанавливается в любое другое значение для определения ошибки.
; Поскольку вызов exit не возвращает значения, то мл. байт code является
; кодом возврата для родительского процесса.
;
; in: hl = значение code
; out: нет
;
; void exit(int code)
;
exit_::
	push	hl			; значение code
@2:	ld	a,(atxcount)		; число зарегистр. функций
	dec	a			; --atxcount
	jp	m,@1			; число функций < 0
	ld	(atxcount),a
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	de,atxtable		; список адресов зарегистр. функций
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	de,@2			; адрес возврата после отработки функции
	push	de
	; вызвать последнюю в списке зарегистр. функцию
	jp	(hl)
	;
@1:	pop	hl			; значение code
	jp	_exit_##		; выйти в ДОС

;
; "stdlib.h"
; Функция регистрирует (заносит в свой список) функцию *func
; как "exit function", т.е. отрабатывающую перед выходом в ДОС.
; В случае нормального окончания программы, exit вызывает (без
; аргументов) "exit function" как раз перед возвратом в опера-
; ционную систему.
; Каждый вызов atexit регистрирует другую завершающуюся функцию.
; Регистрируемые функции не мoгут иметь параметрoв. Может быть
; зарегистрировано не более 8 функций, которые выполняются в порядке
; "последний пришел - первый ушел" (LIFO).
; Функция atexit сooтветствует стандарту ANSI и дoлжна испoльзo-
; ваться вместo onexit, если требуется сoвместимoсть с ANSI.
; Функция вoзвращает 0, если все нoрмальнo и ненулевoе значение
; при oшибке (если уже oпределенo макс. число exit-функций).
;
; in: hl = адрес регистрируемой функции
; out: a = 0, если Ok
;      a = не 0 при ошибке
;
; char atexit(*func)
;
;
;  Пример:
;       main()
;       {
;          atexit(func1);		// "Exit Function 1 called"
;          atexit(func2);		// "Exit Function 2 called"
;          printf("Main quitting ...\n");
;       }
;  Выведется:
;        Main quitting ...
;        Exit Function 2 called
;        Exit Function 1 called
;
atexit_::
	ld	a,(atxcount)		; число зарегистр. функций
	inc	a			; ++atxcount
	cp	8+1			; макс. число функций
	ret	nc
	ld	(atxcount),a
	ex	de,hl			; de = адрес передаваемой функции
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	bc,atxtable-2		; список адресов функций
	add	hl,bc
	ld	(hl),e			; адрес функции в список
	inc	hl
	ld	(hl),d
	xor	a			; Ok
	ret

;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция сбрасывает все буферы в файлы
; и закрывает все открытые файлы.
;
; in: нет
; out: нет
;
; void fclosall()
;
fclosall_::
	ld	hl,_iob_##+14		; начало FILE-структур файлов
	ld	b,8			; max. count FILE-structurs
@fca:	push	hl
	push	bc
	call	fclose_##
	pop	bc
	pop	hl
	ld	de,14			; size FILE-structure
	add	hl,de			; next
	djnz	@fca
	ret

	dseg
atxcount:
	db	0			; число зарегистр. функций
; список адресов зарегистр. функций
atxtable:
	ds	16			; 8*2

	ENDMODULE



	MODULE	fflush
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция освобождает (записывает) буфер открытого файла.
; Применяется для сохранения данных на диске, перед выполнением
; операции, могущей сломать систему.
; Если файл открыт для записи, буфер сбрасывается в файл.
; Если файл открыт для чтения, буфер очищается.
; После вызова функции, файл остается открытым.
; Функция возвращает 0, если буфер успешно обновлен. Это же значение
; возвращается, когда поток не имеет буфера или когда он открыт только
; для чтения. В случае возникновения ошибки, возвращается значение EOF.
;
; in: hl = FILE *fp
; out: a = 0  - Ok
;         -1  - error
;
; char fflush(FILE *fp)
;
fflush_::
	xor	a
	ld	(@3+1),a
	push	hl			; fp
	pop	iy
	bit	1,(iy+1)		; stdin ?
	ret	nz			; yes,  a=0 !
	bit	7,(iy+0)		; data is incoming ?
	jr	z,@1			; no
	; flushing input file:
	;  lseek file to curren position;
	;  invalidate buffer
	ld	hl,0
	push	iy
	ld	bc,1			; SEEK_CUR
	push	bc;
	ld	e,(iy+2)		; level of buffer
	ld	d,(iy+3)
	or	a
	sbc	hl,de
	ld	c,l
	ld	b,h			; bc=low
	sbc	hl,hl
	ex	de,hl			; de=high
	ld	l,(iy+6)		; file descriptor
	ld	h,0
	call	lseek_##
	pop	bc;
	ld	(@3+1),a
	jr	@2
	;
@1:	bit	0,(iy+1)		; data is outgoing ?
	jr	z,@2a			; no
	ld	l,(iy+6)		; file descriptor
	ld	e,(iy+8)		; addr data transfer buffer
	ld	d,(iy+9)
	ld	c,(iy+2)		; level of buffer (bytes)
	ld	b,(iy+3)
	push	iy
	push	bc
	call	write_##		; write to file
	pop	bc
	;or	a
	;sbc	hl,bc			; все записали ?
	;jr	nc,@2
	or	a;
	jr	z,@2;
	ld	a,-1			; error
	ld	(@3+1),a
@2:	pop	iy
@2a:	xor	a
	ld	(iy+2),a		; set empty level of buffer
	ld	(iy+3),a
	ld	a,(iy+8)		; current active pointer
	ld	(iy+4),a		; to begin buffer
	ld	a,(iy+9)
	ld	(iy+5),a
	res	0,(iy+1)		; data is outgoing
	res	7,(iy+0)		; data is incoming
@3:	ld	a,0
	or	a
	ret	z			; Ok
	set	4,(iy+0)		; error indicator
	ret

	ENDMODULE


	MODULE	fgetpos
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция сохраняет текущее положение указателя файла в объекте,
; на который указывает position. Позднее, функция fsetpos использует
; значение, хранимое в position для переустановки указателя в файле
; в новое положение. Значение position хранится вo внутреннем фoрмате
; и oнo дoлжнo испoльзoваться тoлькo с функциями fgetpos и fsetpos.
; Функция вoзвращает 0.
; При ошибке, вoзвращается -1.
;
; char fgetpos(FILE *fp, fpos_t *position)
;
fgetpos_::
	inc	hl
	ld	a,(hl)
	and	00111110b		;+1 std.. devices ?
	dec	hl
	jr	nz,@0			; yes
	push	hl
	push	de
	call	fflush_##		; flushing file buffer
	pop	de
	pop	hl
	or	a
	jr	z,@1			; Ok
@0:	ld	a,-1
	ret
	;
@1:	ld	bc,6
	add	hl,bc
	ld	l,(hl)			; file descriptor
	ld	h,b
	push	de
	call	ltell_##
	pop	de
	ld	a,l
	and	h
	inc	a
	jr	z,@0			; error
	ld	bc,4
	ldir
	xor	a
	ret

	ENDMODULE


	MODULE	fsetpos
;
; "stdio.h"
;---------------------------------------------------------------------
; Функции высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция rewind перемещает указатель в файле к началу файла.
; Вызов функции эквивалентен вызову следующей функции:
;
;	fseek(FILE *fp, 0, 0, SEEK_SET);
;
; с учетом того, что в FILE-структуре fp описателя файла функция rewind
; очищает флаг ошибки и индикатор конца файла, а fseek этого не делает.
; Функция не возвращает никакого значения.
;
; void rewind(FILE *fp)
;
rewind_::
	ld	de,@4
	res	4,(hl)			; error indicator

;
; Функция fsetpos устанавливает положение указателя в файле равным
; значению, находящемуся в position, кoтoрoе пoлучается при вызoве
; функции fgetpos для данного файла. Функция oчищает индикатoр кoнца
; файла. Значение position хранится вo внутреннем фoрмате и oнo дoлжнo
; испoльзoваться тoлькo с функциями fgetpos и fsetpos.
; Функция вoзвращает 0.
; При ошибке, вoзвращается -1.
;
; char fsetpos(FILE *fp, fpos_t *position)
;
fsetpos_::
	inc	hl
	ld	a,(hl)
	and	00111110b		;+1 std.. devices ?
	dec	hl
	jr      nz,@2			; yes
	push	de
	push	hl
	call	fflush_##		; flushing file buffer
	pop	hl
	pop	de
	or	a
	jr	z,@3			; Ok
@2:	ld	a,-1
	ret
	;
@3:	res	5,(hl)			; EOF indicator
	ld	bc,6
	add	hl,bc
	ld	l,(hl)			; file descriptor
	ld	h,b
	ld	c,b			; bc=SEEK_SET
	push	bc
	push	hl
	ex	de,hl			; hl= &pos
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; bc=low
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)			; de=high
	pop	hl
	call	lseek_##		; move_fp
	pop	bc
	ld	a,l
	and	h
	inc	a
	jr	z,@2			; error
	xor	a
	ret

; for rewind_
@4:	dw	0
	dw	0

	ENDMODULE


	MODULE	fseek
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция устанавливает указатель в файле на новое место расположения,
; определяемое аргументами high и low, соответственно старшая и млад-
; шая часть 32-х битного значения перемещения.
; Тип перемещения определяется аргументом type. Следующая операция в
; файле выполняется на новом месте расположения указателя.
; Аргумент type может быть одной из следующих констант, определенных
; в "stdio.h":
;
;       SEEK_SET    от начала файла
;       SEEK_CUR    от текущей позиции указателя в файле
;       SEEK_END    от конца файла
;
; Функция возвращает структуру f_point, определенную в "types.h"
; При ошибке возвращается -1 и errno содержит номер ошибки.
; Установка указателя за пределами файла, ошибки не вызывает.
; Для устройств, не приспособленных к поиску (таких как терминалы
; и принтеры), возвращается значение -1.
;
; struct fpoint *fseek(FILE *fp, high, low, type)
;
fseek_::
	inc	hl
	ld	a,(hl)
	and	00111110b		;+1 std.. devices ?
	dec	hl
	jr      nz,@1			; yes
	push	de
	push	hl
	push	bc
	call	fflush_##		; flushing file buffer
	pop	bc
	pop	hl
	pop	de
	or	a
	jr	z,@2			; Ok
@1:	ld	hl,-1
	ret
	;
@2:	push	bc
	ld	bc,6
	add	hl,bc
	ld	l,(hl)			; file descriptor
	ld	h,b
	pop	bc
	jp	lseek_##

	ENDMODULE


	MODULE	ftell
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция ftell получает текущую позицию указателя в файле.
; Позиция выражается как число байтов от начала файла.
; Функция возвращает структуру f_point, определенную в "types.h"
; При ошибке возвращается -1 и errno содержит номер ошибки.
; Для устройств, не приспособленных к поиску (таких как терминалы
; и принтеры), возвращается значение -1.
;
; struct fpoint *ftell(FILE *fp)
;
ftell_::
	inc	hl
	ld	a,(hl)
	and	00111110b		;+1 std.. devices ?
	dec	hl
	jr      nz,@1			; yes
	push	hl
	call	fflush_##		; flushing file buffer
	pop	hl
	or	a
	jr	z,@2			; Ok
@1:	ld	hl,-1
	ret
	;
@2:	ld	bc,6
	add	hl,bc
	ld	l,(hl)			; file descriptor
	ld	h,b
	jp	ltell_##

	ENDMODULE


	MODULE	clearerr
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция сбрасывает в FILE-структуре файла 4-й бит "индикатора ошибки"
; и 5-й бит "индикатора конца файла".
; Индикаторы ошибок автоматически не очищаются: если для файла уста-
; новлен индикатор ошибки, то операции над файлом будут возвращать
; значения ошибок до тех пор, пока не будут вызваны функции clearerr
; или rewind.
;
; in: hl = адрес структуры описателя
; out: нет
;
; void clearerr(FILE *fp)
;
clearerr_::
	ld	a,(hl)
	and	11001111b		; 0CFh (clear 5,4 bits)
	ld	(hl),a
	ret

	ENDMODULE


	MODULE	fheap
;-----------------------------------------------------------
; вызывается из fopen_
;-----------------------------------------------------------
; Ищет свободную FILE-структуру.
; Проверяет на нулевое значение поле flags (статус)
; у 8-ми FILE-структур.
; Возвращает указатель на первую найденную структуру.
; Возвращает NULL, если нет свободных структур.
;
; in: нет
; out: hl = адрес найденной структуры
;      hl = NULL, если структуру не нашли
;
_fpheap_::
	ld	hl,_iob_+14		; начало FILE-структур файлов
	ld	de,14			; размер структуры
	ld	b,8			; макс. число структур
@1:	ld	a,(hl)			;+0
	inc	hl
	or	(hl)			;+1
	dec	hl
	ret	z			; found
	add	hl,de
	djnz	@1
	; no structs available
	ld	hl,0			; NULL
	ret

	dseg
	; 182 bytes
	; FILE structs std.. devices
	ds	14			; stdprn  (descriptor -5)
	ds	14			; stdaux  (descriptor -4)
	ds	14			; stderr  (descriptor -3)
	ds	14			; stdout  (descriptor -2)
_iob_::	ds	14			; stdin   (descriptor -1)
	; FILE structs of files
	ds	14*8

	ENDMODULE


	MODULE	fdopen
;
; "stdio.h"
; Функция разрешает файлу, oткрытoму для низкo-урoвневoгo ввoда/вывoда,
; быть буферирoванным и фoрматирoванным, т.е. преобразует его для высоко-
; уровневого ввода/вывода. После этого, для всех пoследующих oпераций с
; файлом, необходимо использовать функции высоко-уровневого ввода/вывода.
; В следствии этого, закрывать файл необходимо функцией fclose, а не close.
; Символьная строка mode определяет тип доступа к файлу:
;
;       r,w,a          - режим текст. файла
;       rb,wb,ab       - режим. бинарного файла
;       r+, w+, a+     - r/w, "на обновление" текст. файла
;       r+b, w+b, a+b  - r/w, "на обновление" бинарного файла
;
; В дoбавление к вышеприведенным значениям, может быть добавлен симвoл "b"
; или "t", для задания режима трансляции нoвых стрoк. Опция "t" не относится
; к ANSI-стандарту для fopen. Этo расширение Microsoft и oнo не дoлжнo испoль-
; зoваться, если требуется ANSI-сoвместимoсть.
; Если "b" или "t" не заданы в стрoке "mode", режим трансляции oпределяется
; как "t".
;
; Функция вoзвращает указатель на oткрытую FILE-структуру.
; При ошибке, возвращается NULL.
;
; in: hl = номер дескриптора
;     de = адрес строки type
; out: hl = адрес FILE-структуры открытого файла
;      hl = NULL, при ошибке
;
; FILE *fdopen(FD fd, char *mode)
;
fdopen_::
	ld	a,l
	or	h
	cp	8+1			; max number of descriptors
	jp	nc,@err
	push	hl
	push	de
	call	_fpheap_##		; get any FILE structs available
	pop	bc			; mode
	pop	de			; file descriptor
	ld	a,h
	or	l
	ret	z			; hl=NULL, structs not available
	push	hl
	pop	iy			; адрес FILE-структуры
	ex	de,hl			; de=адрес структуры
	ld	a,(bc)
	and	5Fh
	inc	bc
	cp	"R"			; read
	jr	z,@10
	cp	"W"			; write
	jr	z,@20
	cp	"A"			; append
	jp	nz,@err
	;
	ld	(iy+6),l		; file descriptor
	ld	(iy+7),h		;
	set	1,(iy+0)		; "write only"
	push	bc
	push	iy
	ld	bc,2			; SEEK_END
	push	bc
	;ld	l,(iy+6)		; дескр. файла
	ld	h,b
	ld	c,b
	ld	e,b
	ld	d,b
	call	lseek_##		; move_fp
	pop	bc
	pop	iy
	pop	bc
	jp	@4


;-----------------------------------------------------------
; вызывается из freopen_, fopen_
;-----------------------------------------------------------
; Разбор и установка режимов открытия файла.
; По-умолчанию бит "binary file" сброшен.
;
; in: hl = адрес FILE *fp файла
;     de = адрес path-имени файла
;     bc = адрес mode-строки:
;            r,w,a          - режим текст. файла
;            rb,wb,ab       - режим. бинарного файла
;            r+, w+, a+     - r/w, "на обновление" текст. файла
;            r+b, w+b, a+b  - r/w, "на обновление" бинарного файла
;
; Эквиваленты:
;
;      "r"         O_RDONLY
;
;      "w"         O_WRONLY (обычно O_WRONLY | O_CREAT | O_TRUNC)
;
;      "a"         O_WRONLY | O_APPEND (обычно O_WRONLY | O_CREAT | O_APPEND)
;
;      "r+"        O_RDWR
;
;      "w+"        O_RDWR (обычно O_RDWR | O_CREAT | O_TRUNC)
;
;      "a+"        O_RDWR | O_APPEND (обычно O_RDWR | O_CREAT | O_APPEND)
;
; В дoбавление к вышеприведенным значениям, может быть добавлен симвoл "b"
; или "t", для задания режима трансляции нoвых стрoк. Опция "t" не относится
; к ANSI-стандарту для fopen. Этo расширение Microsoft и oнo не дoлжнo испoль-
; зoваться, если требуется ANSI-сoвместимoсть.
; Если "b" или "t" не заданы в стрoке "mode", то по-умолчанию используется
; режим трансляции нoвых стрoк, т.е. включена опция "t".
;
; out: hl = адрес FILE *fp файла, если Ok
;      hl = NULL, при ошибке
;
_fopen_::
	inc	hl
	ld	a,(hl)
	and	00111110b		;+1 std.. devices ?
	jr      nz,@err			; yes
	dec	hl
	push	hl
	pop	iy			; FILE *fp
	xor	a
	ld	(iy+2),a		; set "empty level of buffer"
	ld	(iy+3),a
	ld	(iy+8),a		; res "data transfer buffer"
	ld	(iy+9),a
	;ld	(iy+7),-1		; ст. байт file descriptor
	ld	a,(bc)			;+0  mode-строка
	and	5Fh
	inc	bc
	cp	"R"			; read
	jr	z,@read
	cp	"W"			; write
	jr	z,@write
	cp	"A"			; append
	jr	z,@append
	; ошибка
@err:	ld	hl,0			; NULL
	ret
	;
; "R" открыть "на чтение"
@read:	push	bc
	push	iy
	ex	de,hl			; hl=path-имя файла
	ld	de,3			; O_RDWR
	call	open_##
	pop	iy
	pop	bc
	bit	7,h			; return -1 ?  (file not found ?)
	jr	nz,@err			; yes
@10:	ld	(iy+6),l		; номер дескриптора для low-level i/o
	ld	(iy+7),h
	set	0,(iy+0)		; "read only"
	jr	@4
	;
; "W" открыть "на запись"
@write:	push	bc
	push	iy
@21:	ex	de,hl			; hl=path-имя файла
	ld	de,4			; O_TRUNC
	call	open_##
	pop	iy
	pop	bc
@20:	ld	(iy+6),l
	ld	(iy+7),h
	set	1,(iy+0)		; "write only"
	jr	@4
	;
; "A" открыть "на добавление"
@append:push	bc
	push	iy
	ex	de,hl			; hl=path-имя файла
	ld	de,23h			; O_RDWR | O_APPEND
	push	hl
	call	open_##
	pop	de
	bit	7,h			; return -1 ?  (file not found ?)
	jr	nz,@21			; yes
	pop	iy
	pop	bc
	ld	(iy+6),l		; номер дескриптора для low-level i/o
	ld	(iy+7),h
	set	1,(iy+0)		; "write only"
	;
@4:	ld	a,(bc)			;+1  mode-строка
	cp	"+"
	jr	nz,@5
	set	0,(iy+0)		; "read only"
	set	1,(iy+0)		; "write only"
	inc	bc
@5:	res	6,(iy+0)		; clear "binary file"
	ld	a,(bc)			;+2  mode-строка
	cp	"b"
	jr	nz,@6
	set	6,(iy+0)		; binary file
@6:	push	iy;
	pop	hl;
	ret;
	;
	;bit	7,(iy+7)		; ?
	;jr	z,@7			; без ошибок
	;ld	hl,0
	;ld	(iy+0),l		; clear status FILE *fp
	;ld	(iy+1),h
	;ret
	;
;@7:	push	iy
	;ld	l,(iy+6)		; file descriptor
	;ld	h,0
	;call	isatty_##		; std.. devices ?
	;pop	hl
	;or	a
	;ret	z			; no
	;inc	hl
	;set	1,(hl)			;+1  set "std.. device" in FILE *fp
	;dec	hl
	;ret

	ENDMODULE


	MODULE	freopen
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция закрывает текущий файл, связанный с дескриптором (FILE-структурой)
; fp и переназначает этот дескриптор на новый файл, определяемый path-именем.
; Ошибки при закрытии файла игнорируются. Эта функция обычно применяется для
; переадресации предоткрытых потоков stdin, stdout, stderr, stdaux и stdprn
; в файлы, определяемые пользователем. Но поскольку ДОС Estex не поддерживает
; эти потоки, то при попытке переадресации stdin, stdout, stderr, stdaux и
; stdprn, будет возвращен NULL. Новый файл открывается в режиме mode.
; Функция возвращает указатель на fp вновь открытого файла.
; При ошибке, функция возвращает значение NULL.
;
; in: hl = адрес pathname
;     de = адрес строки mode
;     bc = адрес FILE *fp
; out: hl = адрес дескриптора вновь открытого файла
;      hl = NULL, при ошибке
;
; FILE *freopen(pathname, mode, FILE *fp)
;
freopen_::
	ld	(@1+1),hl		; pathname (имя нового файла)
	ld	l,c			; hl=FILE *fp
	ld	h,b
	inc	bc
	ld	a,(bc)
	and	00111110b		;+1 std.. devices ?
	jr      nz,@2			; yes
	push	hl
	push	de			; адрес строки mode
	call	fclose_##
	pop	bc			; mode
	pop	hl			; FILE *fp
@1:	ld	de,0			; pathname
	jp	_fopen_##		; открыть новый файл
	;
@2:	ld	hl,0			; NULL
	ret

	ENDMODULE


	MODULE	fopen
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция открывает файл с именем pathname.
; Символы в строке mode определяют тип доступа к файлу.
; Функция возвращает указатель на открытый файл.
; При ошибке, возвращается NULL.
;
; in: hl = адрес pathname
;     de = адрес строки mode
; out: hl = адрес FILE *fp
;      hl = NULL, при ошибке
;
;
; FILE *fopen(pathname, mode)
;
fopen_::
	push	hl			; адрес pathname
	push	de			; адрес строки mode
	call	_fpheap_##		; найти свободную FILE-структуру
	pop	bc			; адрес строки mode
	pop	de			; адрес pathname
	ld	a,l
	or	h
	ret	z			; hl=NULL
	jp	_fopen_##

	ENDMODULE


	MODULE	fclose
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция сбрасывает буфер в файл и закрывает его.
; Данной функцией можно закрывать только те файлы, работа с которыми
; производится в рамках высоко-уровневого ввода/вывода.
; Для закрытия файлов в рамках низко-уровневого ввода/вывода, необхо-
; димо применять функцию close.
;
; in: hl = адрес FILE-структуры
; out: a = 0, если Ok
;      a = EOF, при ошибке
;
; char fclose(FILE *fp)
;
fclose_::
	ld	a,(hl)			; test status current FILE *fp
	inc	hl
	or	(hl)
	ld	c,(hl)
	dec	hl
	ret	z			; free structure (не назначена файлу)
	ld	a,c
	and	00111110b		; std.. devices ?
	jr      nz,@24			; yes
	push	hl
	call	fflush_##		; сбросить буфер в файл
	ld	(@23+1),a		; 0 или -1
	pop	iy			; fp
	push	iy
	;bit	1,(iy+1)		; stdin ?
	;jr	nz,@22			; yes
	ld	l,(iy+6)		; file descriptor
	call	close_##		; close file
	ld	a,l
	ld	hl,@23+1
	or	(hl)
	ld	(hl),a
@22:	pop	iy
	bit	2,(iy+0)		; malloc'ed Buffer data ?
	ld	(iy+0),0
	ld	(iy+1),0
	jr	z,@23			; no
	ld	l,(iy+8)		; addr data transfer buffer
	ld	h,(iy+9)
	call	free_##			; free memory of buffer
@23:	ld	a,0			; return value
	ret
@24:	ld	a,-1
	ret

	ENDMODULE


	MODULE	gets
;
; "stdio.h"
; Функция читает из стандартного потока stdin строку и запоминает
; ее в своем буфере buffer. Входная строка читается до тех пор, пока
; не встрерится код новой строки "0x0D" или число введенных символом
; не превысит 254. В конец строки вместо кода 0x0D заносится нуль,
; в отличии от функции fgets, которая сохраняет символ 0x0D.
; Функция возвращает указатель на буфер.
; В случае ошибки, возвращаемое значение не определено.
; Формат строки в буфере следующий:
;   
;   +0:  - байт, содержащий длину прочитанной строки, без концевого нуля.
;   +1:  - начало строки.
;
; in: hl = адрес буфера
; out: hl= адрес буфера
;
; char *gets(char buffer[255])
;
gets_::	;push	ix
	ld	b,254			; max len string
__gets_::
	ld	c,0			; counter
	push	hl
	inc	hl
@1:	push	bc
	push	hl
@2:	ld	c,8Eh			; get curs
	rst	08h
	push	de
	ld	c,32h			; echokey
	rst	10h
	pop	de
	cp	8
	jr	z,@4
	cp	0Dh
	jr	z,@5
	cp	" "
	jr	nc,@3
	ld	c,84h			; set curs
	rst	08h
	jr	@2
	;
@3:	pop	hl
	pop	bc
	ld	(hl),a			; save symbol
	inc	hl
	inc	c			; ++counter
	djnz	@1
	jr	@6
	;
@4:	pop	hl
	pop	bc
	dec	c
	inc	c
	jr	z,@1
	dec	c
	dec	hl
	inc	b
	jr	@1
	;
@5:	pop	hl
	pop	bc
@6:	ld	(hl),0
	push	bc
	ld	a,0Ah
	call	putch_##		; вывод символа прямо на экран
	pop	bc
	pop	hl			; buffer
	ld	(hl),c			; len string
	;pop	ix
	ret

	ENDMODULE


	MODULE	fgetc1
;-----------------------------------------------------------
; вызывается из fgetc_, fread_
;-----------------------------------------------------------
; Функция высоко-уровневого ввода/вывода.
; Читает символ из файла fp или stdin.
;
; in: hl = адрес FILE *fp
; out: a = считанный символ, если Ok
;      a = EOF (0FFh) при ошибке
;
; char _fgetc(FILE *fp)
;
_fgetc_::
	ld	a,(hl)
	and	00110000b		; 4,5 bits (Error/EOF)
	ld	c,a
	inc	hl
	ld	a,(hl)
	dec	hl
	;and	1
	and	00111100b		; mask stdout...stdprn
	or	c
	jr	z,@45			; stdin, no errors, not EOF
@46:	ld	a,-1			; Error/EOF or not stdin
	ret
	;
@45:	bit	0,(hl)			;+0 read only ?		& ?
	jr	z,@46			; no			& ?
	inc	hl
	bit	1,(hl)			;+1 stdin ?
	jr	z,@47			; no
	call	getche_##		; echokey
	cp	0Dh
	ret	nz
	ld	a,0Ah			; '\n'
	ret
	; file
@47:	dec	hl
	push	hl			; fp
	pop	iy
	ld	a,(iy+2)		; empty level of buffer ?
	or	(iy+3)
	jr	nz,@48			; no
	ld	a,(iy+8)		; data transfer buffer
	or	(iy+9)
	jr	nz,@49			; != NULL
	; first time
	ld	hl,512			; size buffer
	call	malloc_##		; alloc memory
	ld	(iy+8),l		; адрес начала выдел. блока
	ld	(iy+9),h
	ld	a,l
	or	h
	jr	nz,@50
	; hl=NULL
	set	4,(iy+0)		; Error indicator
	jr	@46
	;
@50:	set	2,(iy+0)		; malloc'ed Buffer data
@49:	ld	e,(iy+8)
	ld	d,(iy+9)
	ld	(iy+4),e		; de=current active pointer
	ld	(iy+5),d
	ld	l,(iy+6)		; file descriptor
	push	iy
	ld	bc,512			; size buffer
	call	read_##			; read file
	pop	iy
	ld	(iy+2),l		; fill level of buffer
	ld	(iy+3),h
	ld	a,h
	or	l
	jr	nz,@48			; Ok
	; hl=NULL
	xor	a
	set	5,(iy+0)		; EOF indicator
	ld	(iy+2),a		; empty level of buffer
	ld	(iy+3),a
	dec	a			; a=EOF
	ret
	;
@48:	set	7,(iy+0)		; data is incoming
	ld	e,(iy+2)		; level of buffer
	ld	d,(iy+3)
	dec	de
	ld	(iy+3),d
	ld	(iy+2),e
	ld	e,(iy+4)		; current active pointer
	ld	d,(iy+5)
	ld	a,(de)			; get byte from buffer
	inc	de
	ld	(iy+5),d
	ld	(iy+4),e
	ret

	ENDMODULE


	MODULE	ungetc
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция возвращает символ ch в файл.
; Последующая операция чтения из файла начинается
; с символа ch.
; При удачном завершении, функция возвращает ch.
; При ошибке возвращается EOF, говорящее о неудачном
; возвращении заданного символа.
;
; in: a = возвр. символ
;     l = .. ?
;     de = адрес структуры дескриптора
; out: a = возвр. символ, если Ok
;      a = EOF (0FFh) при ошибке
;
; char ungetc(char ch, FILE *fp)
;
ungetc_::
	;ld	a,-1			; EOF
	;cp	l
	;jr	z,@51			; error
	cp	-1;
	ret	z;
	push	de			; адрес fp
	pop	iy
	ld	(?132+1),a		; возвр. символ
	ld	e,(iy+2)		; число байт в буфере
	ld	d,(iy+3)
	inc	de
	ld	(iy+3),d
	ld	(iy+2),e
	ld	hl,1
	call	?cpshd##		; знаковое? сравнение hl с de
	jr	nc,@52			; в буфере 1 символ или он пуст ?
?132:	ld	a,0			; return value
	ld	e,(iy+4)		; текущий адрес в буфере
	ld	d,(iy+5)
	dec	de
	ld	(iy+5),d
	ld	(iy+4),e
	ld	(de),a			; вернуть символ в буфер
	ret
	;
@52:	ld	a,(iy+2)		; число байт в
	dec	a
	or	(iy+3)			; буфере
	jr	nz,@53
	push	iy
	pop	bc
	ld	hl,10			;+10 смещ. на ячейку hold в FILE-структуре
	add	hl,bc
	ld	(iy+4),l		; тек. адрес в буфере
	ld	(iy+5),h
	ld	a,(?132+1)		; return value
	ld	(hl),a			; вернуть символ в буфер (ячейку hold)
	ret
	;
@53:	ld	a,(iy+2)		; число байт в
	sub	1
	ld	(iy+2),a
	jr	nc,@51
	dec	(iy+3)			; буфере
	; ошибка
@51:	ld	a,-1			; EOF
	ret

	ENDMODULE


	MODULE	fputc1
;-----------------------------------------------------------
; вызывается из fputc_ и fwrite_
;-----------------------------------------------------------
; Выводит символ ch в поток, закрепленный за fp.
;
; in: a = выводимый символ
;     de = адрес FILE *fp
; out: a = выводимый символ, если Ok
;      a = EOF (0FFh) при ошибке
;
; char fputc(char ch, FILE *fp)
;
_fputc_::
	ex	de,hl
	ld	(@59+1),a		; выводимый символ
	bit	1,(hl)			;+0 write only ?
	jr	nz,@54			; yes
@55:	ld	a,-1			; EOF
	ret
	;
@54:	bit	7,(hl)			;+0 data is incoming ?
	jr	nz,@55			; yes
	res	5,(hl)			;+0 clear EOF indicator
	inc	hl;
	bit	2,(hl)			; stdout ?
	jr	nz,@60			; yes
	bit	3,(hl)			; stderr ?
	jr	z,@56			; no
	; stdout, stderr
@60:	;push	ix
	push	af
	ld	c,5Bh			; putchar
	rst	10h
	pop	af			; return symbol
	;pop	ix
	ret
	;
@56:	bit	4,(hl)			; stdaux ?
	jr	nz,@55			; yes
	bit	5,(hl)			; stdprn ?
	jr	z,@61			; no
	;push	ix
	ld	c,5Fh			; print
	rst	10h
	;pop	ix
	jr	c,@55			; not ready
	ld	a,b			; return symbol
	ret
	;
@61:	dec	hl
	push	hl			; fp
	pop	iy
	ld	a,(iy+2)		; level of buffer
	or	(iy+3)
	jr	nz,@57
	ld	a,(iy+8)		; addr data transfer buffer
	or	(iy+9)
	jr	nz,@57			; not NULL
	ld	hl,512			; size buffer
	call	malloc_##		; alloc memory
	ld	(iy+8),l		; new addr data transfer buffer
	ld	(iy+9),h
	ld	a,l
	or	h
	jr	nz,@58
	; hl=NULL
	set	4,(iy+0)		; error indicator
	jr	@55			; eof
	;
@58:	set	2,(iy+0)		; malloc'ed Buffer data
	ld	(iy+4),l		; current active pointer
	ld	(iy+5),h
@57:	ld	e,(iy+4)
	ld	d,(iy+5)
	ld	a,(@59+1)		; symbol
	ld	(de),a			; put symbol to buffer
	inc	de			; ++pointer
	ld	(iy+5),d
	ld	(iy+4),e
	set	0,(iy+1)		; "data is outgoing"
	ld	l,(iy+2)		; level of buffer
	ld	h,(iy+3)
	inc	hl			; ++level
	ld	(iy+2),l
	ld	(iy+3),h
	bit	1,h			; full buffer ?
	jr	z,@59			; no
	push	iy
	pop	hl
	call	fflush_##		; flushing file buffer
	or	a
	jp	nz,@55			; eof
@59:	ld	a,0			; return symbol
	ret

	ENDMODULE


	MODULE	fputc
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Записывает символ ch в файл fp.
; Функция возвращает записанный символ.
; При ошибке, возвращается значение EOF.
;
; in: a = выводимый символ
;     de = адрес FILE *fp
; out: a = выводимый символ, если Ok
;      a = EOF (0FFh) при ошибке
;
; char putc(char ch, FILE *fp)
; char fputc(char ch, FILE *fp)
;
putc_::
fputc_::
	ld	h,d			; адрес FILE-структуры
	ld	l,e
	bit	6,(hl)			; binary file indicator
	jp	nz,_fputc_##
	; для файла, открытого в текст. режиме
	cp	0Ah
	jp	nz,_fputc_##
	push	de			; fp
	ld	a,0Dh
	call	_fputc_##
	pop	de
	cp	-1			; EOF
	ret	z
	ld	a,0Ah
	jp	_fputc_##

	ENDMODULE


	MODULE	fputs
;
; "stdio.h"
; Функция копирует строку в конец файла fp.
; Нулевой символ окончания строки '\0' не копируется.
; Функция возвращает последний записанный символ.
; ;Если вводимая строка string пустая, возвращается значение 0.
; При ошибке возвращается значение EOF.
;
; char fputs(char *string, FILE *fp)
;
fputs_::
	push	hl
	push	de
	ex	de,hl			; hl=FILE *fp
	ld	bc,2			; SEEK_END
	push	bc
	ld	c,b			; bc=low
	ld	e,b			; de=high
	ld	d,b
	call	fseek_##
	pop	bc
	pop	de
	pop	hl
	ld	a,l
	and	h
	cp	-1
	ret	z
@1:	ld	a,(hl)
	or	a
	jr	z,@2
	ld	(@2+1),a
	push	hl
	call	fputc_##
	pop	hl
	cp	-1
	ret	z			; error
	inc	hl
	jp	@1
	;
@2:	ld	a,0			; return symbol
	ret

	ENDMODULE


	MODULE	fgetc
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода  (используется fgets_)
;---------------------------------------------------------------------
; Функция читает текущий символ из потока fp и ставит указатель
; (если он есть) на следующий символ.
; Возвращается считанный символ.
; В случае возникновения ошибки или достижения конца файла, возвра-
; щается значение EOF. Однако, значение EOF может быть воспринято
; как целая величина, тогда нужно использовать функции ferror и feof
; для проверки ошибки или конца файла.
;
; in: hl = адрес структуры дескриптора
; out: a = прочитанный символ, если Ok
;      a = EOF (0FFh) при ошибке
;
; char getc(FILE *fp)
; char fgetc(FILE *fp)
;
getc_::
fgetc_::
	bit	6,(hl)			; "binary file" ?
	jp	nz,_fgetc_##		; yes
	; line-buffered file (CR-LF translation)
@41:	push	hl			; fp
	call	_fgetc_##
	pop	hl
	cp	0Dh			; только из файла (не из stdin)
	jr	z,@41
	cp	1Ah			; EOF text file
	ret	nz			; no
	set	5,(hl)			; EOF indicator
	push	hl
	inc	hl
	inc	hl
	ld	e,(hl)			;+2 level of buffer
	inc	hl			;
	ld	d,(hl)			;+3
	inc	de			; ++level
	ld	(hl),d
	dec	hl
	ld	(hl),e
	inc	hl
	inc	hl
	ld	e,(hl)			;+4 current active pointer
	inc	hl			;
	ld	d,(hl)			;+5
	dec	de			; --pointer
	ld	(hl),d
	dec	hl
	ld	(hl),e
	pop	hl
	jr	@41

	ENDMODULE


	MODULE	fgets
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция читает строку из входного потока fp и располагает
; ее в string. Символы считываются, начиная с текущей позиции
; fp и до символа новой строки '\n' или до конца потока, либо
; пока число считанных символов не станет равным maxlen-1.
; Строка размещается в string, затем в ее конец ставится нуль.
; Символ новой строки также включается в string. Если в начале
; считывания maxlen равнялось 1, то string будет пустой "".
; Функция возвращает указатель на строку string.
; При ошибке или конце файла, возвращается NULL.
;
; in: hl = адрес буфера string
;     de = длина строки
;     bc = адрес структуры дескриптора
; out: hl = адрес буфера string, если Ok
;      hl = NULL, при ошибке или конце файла
;
; char *fgets(char *string, int maxlen, FILE *fp)
;
fgets_::
	ld	(?105+1),bc		; адрес FILE *fp
	ld	(@40+1),hl		; адрес буфера string
	ld	(@39+1),de		; maxlen
	ld	(?107+1),hl		; тек. адрес в буфере string
@39:	ld	hl,0			; maxlen
	dec	hl			; --maxlen
	ld	(@39+1),hl
	ex	de,hl
	ld	hl,0
	call	?cpshd##		; сравнить hl с de
	jr	nc,@38
?105:	ld	hl,0			; адрес fd FILE-структуры
	call	fgetc_##		; прочитать символ из файла
	cp	-1
	jr	z,@38			; eof
?107:	ld	hl,0			; тек. адрес в буфере string
	ld	(hl),a			; save symbol
	inc	hl
	ld	(?107+1),hl
	cp	0Ah
	jr	nz,@39
@38:	ex	af,af'			; save "a"
	xor	a
	ld	de,(?107+1)		; тек. адрес в буфере string
	ld	(de),a			; нуль в конец строки в string
	ex	af,af'			; rest "a"
	inc	a
	jr	nz,@40
	; end of file
	ld	hl,(@40+1)		; адрес буфера string
	ld	a,e
	cp	l
	ret	nz
	ld	a,d
	cp	h
	ret	nz
	; empty string ""
	ld	hl,0			; NULL
	ret
	;
@40:	ld	hl,0			; адрес буфера string
	ret

	ENDMODULE


	MODULE	fwrite
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция записывает объекты размера size по счетчику
; count из буфера buffer в выходной файл fp.
; Возвращает число реально записанных объектов.
;
; in: hl = адрес buffer
;     de = size
;     bc = count
;     sp+2 = адрес FILE *fp
; out: hl = число записанных объектов
;
; uint fwrite(buffer, size, count, FILE *fp)
;
fwrite_::
	push	ix
	ld	ix,0
	add	ix,sp			; ix = база стека
	ld	(?86+1),hl		; тек. адрес в buffer
	ld	(?87+1),de		; size (размер объекта в байтах)
	ld	(@34+1),bc		; count (кол-во объектов)
	ld	hl,0			; сбр. число записанных объектов
	ld	(@31+1),hl
@34:	ld	hl,0			; сохр. кол-во объектов
	ld	a,l
	or	h
	jr	z,@30			; все объектов записаны
	dec	hl			; --count
	ld	(@34+1),hl
?87:	ld	hl,0			; сохр. size (размер объекта в байтах)
	ld	(@32+1),hl		; тек. размер size
@32:	ld	hl,0
	ld	a,l
	or	h
	jr	z,@31			; один объект записан
	dec	hl			; --size
	ld	(@32+1),hl
?86:	ld	hl,0			; current pointer
	ld	a,(hl)			; get symbol from buffer
	inc	hl			; ++pointer
	ld	(?86+1),hl
	ld	e,(ix+4)		; de = адрес FILE *fp
	ld	d,(ix+5)
	call	_fputc_##		; put symbol to file
	inc	a
	jr	nz,@32			; not EOF
	; ошибка, конец файла - вернуть число успешно запис. объектов
@30:	ld	hl,(@31+1)		; узнать число запис. объектов
@33:	ld	sp,ix			; восст. стек
	pop	ix
	ret
	;
@31:	ld	hl,0			; число записанных объектов
	inc	hl
	ld	(@31+1),hl
	jp	@34

	ENDMODULE


	MODULE	fread
;
; "stdio.h"
;---------------------------------------------------------------------
; Функция высоко-уровневого ввода/вывода
;---------------------------------------------------------------------
; Функция читает объекты размера size по счетчику count из входного
; файла fp и располагает их в буфере buffer.
; Возвращает число реально прочитанных объектов.
; Примечание:
; При чтении из stdin, код 0x0D заменяется на код 0x0A (прoгoн бумаги)
; и нет возможности редактировать вводимые данные. Нажатие на комбинацию
; клавиш Ctrl+Z или Ctrl+C воспринимается как конец ввода данных.
; Для ввода строки символов из stdin лучше использовать функцию gets,
; допускающую редактирование вводимых данных.
;
; in: hl = адрес buffer
;     de = size
;     bc = count
;     sp+2 = адрес FILE *fp
; out: hl = число прочитанных объектов
;
; uint fread(buffer, size, count, FILE *fp)
;
fread_::
	push	ix
	ld	ix,0
	add	ix,sp			; ix = база стека
	ld	(@26+1),hl		; тек. адрес в buffer
	ld	(?75+1),de		; size (размер объекта в байтах)
	ld	(@29+1),bc		; count (кол-во объектов)
	ld	hl,0			; сбр. число прочитанных объектов
	ld	(@25+1),hl
@29:	ld	hl,0			; сохр. кол-во объектов
	ld	a,l
	or	h
	jr	z,@24			; все объектов прочитаны
	dec	hl			; --count
	ld	(@29+1),hl
?75:	ld	hl,0			; сохр. size (размер объекта в байтах)
	ld	(@28+1),hl
@28:	ld	hl,0			; тек. размер size
	ld	a,l
	or	h
	jr	z,@25			; один объект прочитан
	dec	hl			; --size
	ld	(@28+1),hl
	ld	l,(ix+4)		; hl = адрес FILE *fp
	ld	h,(ix+5)
	call	_fgetc_##		; прочитать символ из файла
	cp	-1
	jr	nz,@26			; not EOF
	; ошибка, конец файла - вернуть число успешно прочит. объектов
@24:	ld	hl,(@25+1)		; число прочит. объектов
@27:	ld	sp,ix
	pop	ix
	ret
	;
@26:	ld	hl,0			; current pointer
	ld	(hl),a			; save symbol to buffer
	inc	hl			; ++pointer
	ld	(@26+1),hl
	jr	@28
	;
@25:	ld	hl,0			; число прочит. объектов
	inc	hl
	ld	(@25+1),hl
	jr	@29

	ENDMODULE
