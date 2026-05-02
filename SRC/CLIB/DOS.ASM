; Функции проверены.
;
; Входящие функции:
;
;  bdos
;  bdosh
;  enable
;  disable
;  _setargv
;  setdisk
;  getdisk
;  absread
;  abswrite
;  setdate
;  getdate
;  settime
;  gettime
;  intdos
;  ffirst  (findfirst)
;  fnext   (findnext)
;





	MODULE	bdos
;
; "dos.h"
; Выполняет системный вызов ДОС, номер которого определен в n.
; Аргументы doshl и dosa размещаются соответственно в регистрах HL и A.
; Функция выполняет команду RST 10h для осуществления системного вызова.
; Функция может быть использована только для системных ДОС-вызовов, которые
; не принимают аргументов или принимают их только в регистрах HL и A.
; Функция возвращает значение регистра A, заполненного системным вызовом.
; Примечание: Эту функцию нельзя использовать для осуществления системных
; вызовов, в которых ошибки указываются посредством установки флага переноса.
; Т.к. Си-программы не имеют доступа к этому флагу, статус возвращаемого
; значения определить невозможно. В этом случае необходимо использовать
; функцию intdos.
; Функция bdosh отличается от bdos только тем, что возвращаемое значение
; содержится в рег. паре HL.
; Обе функции можно использовать для ДОС-вызовов: 02h,0Ah,0Bh,0Eh,11h,1Bh
; 1Ch,1Dh,1Eh,5Ch функций.
;
; in: a = номер функции
;     de = передаваемые параметры
;     c = атрибут
; out: a = значение системного вызова
;
; char bdos(char n, int doshl, char dosa)
; int bdosh(char n, int doshl, char dosa)
;
bdosh_::
bdos_::
	ld	b,c
	ld	c,a			; c = n
	ld	a,b			; a = dosa
	ex	de,hl			; hl = doshl
	push	ix
	rst	10h
	pop	ix
	ld	l,a
	ld	h,0
	ret

	ENDMODULE


	MODULE	diei
;
; "dos.h"
; Enable and disable interrupts.
;
; in: нет
; out: нет
;
; void enable()
; void disable()
;
enable_::
	ei
	ret

disable_::
	di
	ret

	ENDMODULE


	MODULE	setarg
;-----------------------------------------------------------
; внутренняя: вызывается из xmain для функции _main_
;-----------------------------------------------------------
; Создать список аргументов, заданных в командной строке.
; Возвращается число аргументов. Список расчитан на адреса
; максимум 30 аргументов.
;
; in: hl = адрес ком. строки
; out: hl = число аргументов (argc)
;
; int _setargv(*string)
;
_setargv::
	ld	c,(hl)			; длина ком. строки
	inc	hl
	ld	b,0
	ld	e,l			; начало ком. строки
	ld	d,h
	add	hl,bc
	ld	(hl),b			; нуль в конец ком. строки
	; адрес имени программы
	push	de
	inc	hl
	inc	hl
	ld	b,122
@6:	ld	a,(hl)
	inc	hl
	or	a
	jr	z,@8
	cp	"\"
	jr	nz,@7
	ld	e,l
	ld	d,h
@7:	djnz	@6
@8:	ld	(_argv_),de		; адрес имени программы
	pop	de
	;
	ld	hl,_argv_+2		; список адресов аргументов
	ld	b,1			; b=1 argc!
@1:	ld	a,(de)
	inc	de
	cp	" "
	jr	z,@1
	cp	9			; Tab
	jr	z,@1
	or	a
	jr	z,@2			; конец строки
	dec	de
	ld	(hl),e			; адрес аргумента в список
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b			; ++argc
@3:	ld	a,(de)
	cp	" "
	jr	z,@4
	cp	9			; Tab
	jr	z,@4
	or	a
	jr	z,@2			; конец строки
	inc	de
	cp	'"'
	jr	z,@5
	jr	@3
	;
@4:	xor	a
	ld	(de),a			; нуль в конец аргумента в ком. строке
	inc	de
	jr	@1
	;
@5:	ld	a,(de)
	cp	'"'
	jr	z,@3
	or	a
	jr	z,@2
	inc	de
	jr	@5
	;
	; конец аргументов
@2:	ld	(hl),0			; null
	inc	hl
	ld	(hl),0
	ld	l,b			; hl=число аргументов
	ld	h,0
	ret

	dseg
_argv_::
	ds	32*2			; список адресов аргументов

	ENDMODULE


	MODULE	setdisk
;
; "dos.h"
; Установить текущий диск
;
; in: a = номер диска
; out: нет
;
; void setdisk(char diskno)
;
setdisk_::
	push	ix
	ld	c,1
	rst	10h
	pop	ix
	ret

	ENDMODULE


	MODULE	absread
;
; "dos.h"
; Абсолютное чтение с диска.
; Функция считывает в буфер один или несколько секторов
; с заданным начальным относительным номером. Секторы
; нумеруются с 0 от начала логического (не физического!)
; диска. К примеру, загрузочный сектор данного логического
; диска имеет номер 0, далее первая копия FAT начинается
; с сектора номер 1 и т.д.
; Функция возвращают 0 при успешном завершении операции.
; В случае ошибки возвращается -1 (0FFh) и errno содержит
; номер ошибки.
;
; in:  a = номер диска
;     de = лог. номер сектора
;     bc = кол-во читаемых секторов
;     стек = адрес буфера
; out: a = 0   - Ok
;      a = -1  - Error
;
; char absread(char disk, int nsect, char count, char buffer)
;
;      disk - номер диска
;     nsect - номер начального сектора
;     count - кол-во читаемых секторов
;    buffer - адрес буфера под считываемые данные
;
absread_::
	ld	(@1+2),ix
	ld	lx,e			; ix=nsect
	ld	hx,d
	pop	hl
	pop	de			; de=адрес buffer
	push	de
	push	hl
	ld	hl,0			; ст.разряд номера сектора
	ld	b,c			; count
	ld	c,55h
	rst	08h
	jr	c,@2
	xor	a			; Ok
@1:	ld	ix,0
	ret
@2:	ld	a,25			; EREAD (read error)
	ld	(errno_##),a
	ld	a,-1
	jr	@1

	ENDMODULE


	MODULE	abswrit
;
; "dos.h"
; Абсолютная запись на диск.
; Функция записывает из буфера один или несколько секторов
; с заданным начальным относительным номером. Секторы
; нумеруются с 0 от начала логического (не физического!)
; диска. К примеру, загрузочный сектор данного логического
; диска имеет номер 0, далее первая копия FAT начинается
; с сектора номер 1 и т.д.
; Функция возвращают 0 при успешном завершении операции.
; В случае ошибки возвращается -1 (0FFh) и errno содержит
; номер ошибки.
;
; in:  a = номер диска
;     de = лог. номер сектора
;     bc = кол-во записываемых секторов
; out: a = 0   - Ok
;      a = -1  - Error
;
; char abswrite(char disk, int nsect, char count, char buffer)
;
;       disk - номер диска
;      nsect - номер начального сектора
;      count - кол-во записываемых секторов
;     buffer - адрес буфера данных
;
abswrite_::
	ld	(@1+2),ix
	ld	lx,e			; ix=nsect
	ld	hx,d
	pop	hl
	pop	de			; de=адрес buffer
	push	de
	push	hl
	ld	hl,0			; ст.разряд номера сектора
	ld	b,c			; count
	ld	c,56h
	rst	08h
	jr	c,@2
	xor	a			; Ok
@1:	ld	ix,0
	ret
@2:	ld	a,26			; EWRITE (write error)
	ld	(errno_##),a
	ld	a,-1
	jr	@1

	ENDMODULE


	MODULE	getdisk
;
; "dos.h"
; Узнать номер диска
;
; in: нет
; out: a = номер диска
;
; char getdisk()
;
getdisk_::
	;push	ix
	ld	c,2
	rst	10h
	;pop	ix
	ret

	ENDMODULE


	MODULE	getdate
;
; "dos.h"
; Узнать системную дату и заполнить структуру date.
;
; in: hl = адрес структуры даты
; out: нет
;
; void getdate(struct date *date)
;
getdate_::
	push	ix
	push	hl			; адрес структуры даты
	ld	c,21h
	rst	10h
	pop	hl
	push	ix
	pop	bc
	ld	(hl),c			;+0 год
	inc	hl			;
	ld	(hl),b			;+1
	inc	hl
	ld	(hl),d			;+2 день
	inc	hl
	ld	(hl),e			;+3 месяц
	pop	ix
	ret

	ENDMODULE


	MODULE	setdate
;
; "dos.h"
; Установить системную дату.
;
; in: hl = адрес структуры даты
; out: нет
;
; void setdate(struct date *date)
;
setdate_::
	push	ix
	ld	c,(hl)			;+0 год
	inc	hl			;
	ld	b,(hl)			;+1
	inc	hl
	ld	d,(hl)			;+2 день
	inc	hl
	ld	e,(hl)			;+3 месяц
	push	bc
	pop	ix
	ld	c,22h
	rst	10h
	pop	ix
	ret

	ENDMODULE


	MODULE	gettime
;
; "dos.h"
; Узнать системное время и заполнить структуру time.
;
; in: hl = адрес структуры времени
; out: нет
;
; void gettime(struct time *time)
;
gettime_::
	push	ix
	push	hl
	ld	c,21h
	rst	10h
	ex	de,hl
	pop	hl
	ld	(hl),e			;+0  минуты
	inc	hl
	ld	(hl),d			;+1  часы
	inc	hl
	inc	hl			; обойти ячейку "ti_hund"
	ld	(hl),b			;+3  секунды
	pop	ix
	ret

	ENDMODULE


	MODULE	settime
;
; "dos.h"
; Установить системное время.
;
; in: hl = адрес структуры времени
; out: нет
;
; void settime(struct time *time)
;
settime_::
	push	ix
	ld	e,(hl)			;+0  минуты
	inc	hl
	ld	d,(hl)			;+1  часы
	inc	hl
	inc	hl			; обойти ячейку "ti_hund"
	ld	b,(hl)			;+3  секунды
	ex	de,hl
	ld	c,22h
	rst	10h
	pop	ix
	ret

	ENDMODULE


	MODULE	intdos
;
; "dos.h"
; Функция intdos осуществляет выполнение системного ДОС-вызова (с возвратом
; флагов условий), который определен значениями регистров, объявленных в
; union REGS *ri и возвращает результат системного вызова в union REGS *ro.
; Тип объединения union REGS объявлен в "dos.h".
; Для осуществления системного вызова intdos выполняет команду RST 10h.
; Перед выполнением команды функция копирует содержимое union REGS *ri в
; соответствующие регистры. После выполнения команды RST, функция intdos
; копирует значения текущих регистров в union REGS *ro. Она также копирует
; возвращаемый флаг условий системы в поле flag, размещенное в union REGS *ro.
; Если это поле является ненулевым, флаг указывает на условие ошибки.
;
;  union REGS *ri  - значения регистров при вызове
;  union REGS *ro  - значения регистров при возврате
;
; in: hl = адрес union REGS *ri
;     de = адрес union REGS *ro
; out: нет
;
; void intdos(union REGS *ri, union REGS *ro)
;
intdos_::
	push	ix
	push	de			; de=REGS *ro
	inc	hl
	ld	a,(hl)			;+1  a
	inc	hl
	ld	c,(hl)			;+2
	inc	hl
	ld	b,(hl)			;+3
	push	bc
	inc	hl
	ld	e,(hl)			;+4
	inc	hl
	ld	d,(hl)			;+5
	push	de
	inc	hl
	ld	e,(hl)			;+6  l
	inc	hl
	ld	d,(hl)			;+7  h
	inc	hl
	ld	c,(hl)			;+8  xl
	inc	hl
	ld	b,(hl)			;+9  xh
	push	bc
	pop	ix
	inc	hl
	ld	c,(hl)			;+10  yl
	inc	hl
	ld	b,(hl)			;+11  yh
	push	bc
	pop	iy
	ex	de,hl			; hl
	pop	de
	pop	bc
	rst	10h			; системный ДОС-вызов
	ex	(sp),hl			; hl=REGS *ro
	push	bc
	push	af
	pop	bc
	ld	(hl),c			;+0  flag
	inc	hl
	ld	(hl),b			;+1  a
	pop	bc
	inc	hl
	ld	(hl),c			;+2
	inc	hl
	ld	(hl),b			;+3
	inc	hl
	ld	(hl),e			;+4
	inc	hl
	ld	(hl),d			;+5
	inc	hl
	pop	de
	ld	(hl),e			;+6  l
	inc	hl
	ld	(hl),d			;+7  h
	push	ix
	pop	bc
	inc	hl
	ld	(hl),c			;+8  xl
	inc	hl
	ld	(hl),b			;+9  xh
	push	iy
	pop	bc
	inc	hl
	ld	(hl),c			;+10  yl
	inc	hl
	ld	(hl),b			;+11  yh
	pop	ix
	ret

	ENDMODULE


	MODULE	ffirst
;
; "dos.h"
; Функция ffirst производит поиск заданного в pathname файла из группы
; файлов. Аргумент pathname может содержать имя диска и каталог для поиска.
; В имени файла допускаются глобальные символы ? и *. Имя найденного файла
; находится в формате DOS "filename.ext".
; Функция _ffirst отличается от функции ffirst тем, что возвращает имя
; найденного файла в формате "FilenameExt".
; Если файл обнаружен, функция заполняет структуру (определенную в "dos.h"),
; на которую указывает аргумент ffblk.
; Аргумент attr содержит атрибут(ы) файлов для поиска и может принимать
; следующие значения, определенные в "dos.h":
;
;	FA_NORMAL	Обычный файл
;	FA_RDONLY	Только чтение
;	FA_HIDDEN	Скрытый файл
;	FA_SYSTEM	Системный файл
;	FA_LABEL	Метка тома
;	FA_DIREC	Каталог
;	FA_ARCH		Архивный
;
; Мoжнo задавать кратные значения атрибутов, испoльзуя симвoл "|"
; (оператор OR).
; Функция возвращает 0 при успешном завершении поиска.
; Если файл не найден или в имени файла встретилась какая-либо ошибка,
; возвращается -1 и errno содержит номер ошибки.
;
; char ffirst(char *pathname, FIND *ffblk, char attr)
;
_ffirst_::
	ld	b,0			; format "FilenameExt"
	jr	@1

ffirst_::
	ld	b,1			; format "filename.ext"
@1:	ld	a,c			; attr
	ld	c,19h			; f_first
	push	ix
	rst	10h
	pop	ix
	ld	(errno_##),a
	ld	a,0
	ret	nc
	dec	a
	ret

	ENDMODULE


	MODULE	fnext
;
; "dos.h"
; Функция производит поиск следующего совпадающего файла.
; При каждом вызове, функция возвращает одно имя файла, до тех пор, пока
; параметры файла будут подходить под заданные параметры поиска.
; Аргумент ffblk должен указывать на структуру (определенную в "dos.h"),
; предварительно заполненную функцией ffirst.
; Функция возвращает 0 при успешном завершении поиска.
; Если файл не найден или в имени файла встретилась какая-либо ошибка,
; возвращается -1 и errno содержит номер ошибки.
;
; char fnext(FIND *ffblk)
;
fnext_::
	ex	de,hl
	ld	c,1Ah			; f_next
	push	ix
	rst	10h
	pop	ix
	ld	(errno_##),a
	ld	a,0
	ret	nc
	dec	a
	ret

	ENDMODULE
