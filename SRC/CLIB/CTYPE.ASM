; Входящие функции:
;
;  tolower
;  toupper
;  isdigit
;  isupper
;  islower
;  isascii
;  isalnum
;  isxdigit
;  isspace
;  iscntrl
;  ispunct
;  isalpha
;  isgraph
;  isprint
;




	MODULE	xtcty
;
; Table for ctype functs
; 255 bytes
@ctype::
	db	1,1,1,1,1,1,1,1,1,3,3,3,3,3,1,1
	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	db	2,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	db	20,20,20,20,20,20,20,20,20,20,8,8,8,8,8,8
	db	8,48,48,48,48,48,48,32,32,32,32,32,32,32,32,32
	db	32,3,32,32,32,32,32,32,32,32,32,8,8,8,8,8
	db	8,80,80,80,80,80,80,64,64,64,64,64,64,64,64,64
	db	64,64,64,64,64,64,64,64,64,64,64,8,8,8,8,1
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ENDMODULE


	MODULE	tolower
;
; "ctype.h"
; Преобразует прописной символ в строчный.
; in: a = символ
; out a = a..z символ
;
; char tolower(char ch)
;
tolower_::
	cp	"A"
	ret	c
	cp	"Z"+1
	ret	nc
	add	a,20h
	ret

	ENDMODULE


	MODULE	toupper
;
; "ctype.h"
; Преобразует строчный символ в прописной.
; in: a = символ
; out a = A..Z символ
;
; char toupper(char ch)
;
toupper_::
	cp	"a"
	ret	c
	cp	"z"+1
	ret	nc
	sub	20h
	ret

	ENDMODULE


	MODULE	isdigit
;
; "ctype.h"
; Проверка символа на цифру.
; in: a = символ
; out: true - цифра
;      false - не цифра
;
; BOOL isdigit(char ch)
;
isdigit_::
	cp	"0"
	jr	c,@1
	cp	"9"+1
	jr	nc,@1
	ld	a,1		; true
	ret
@1:	xor	a		; false
	ret

	ENDMODULE


	MODULE	isupper
;
; "ctype.h"
; Проверка на прописной символ
; in: a = символ
; out: true - прописной
;      false - не прописной
;
; BOOL isupper(char ch)
;
isupper_::
	cp	"A"
	jr	c,@1
	cp	"Z"+1
	jr	nc,@1
	ld	a,1		; true
	ret
@1:	xor	a		; false
	ret

	ENDMODULE


	MODULE	islower
;
; "ctype.h"
; Проверка на строчный символ
; in: a = символ
; out: true - строчный
;      false - не строчный
;
; BOOL islower(char ch)
;
islower_::
	cp	"a"
	jr	c,@1
	cp	"z"+1
	jr	nc,@1
	ld	a,1		; true
	ret
@1:	xor	a		; false
	ret

	ENDMODULE

	
	MODULE	isascii
;
; "ctype.h"
; Проверка символа на ASCII принадлежность
; in: a = символ
; out: true - ascii-символ
;      false - не ascii-символ
;
; BOOL isascii(char ch)
;
isascii_::
	cp	0Dh
	ret	z
	cp	0Ah
	ret	z
	cp	" "
	jr	c,@1
	cp	"~"+1
	ret	c		; true
@1:	xor	a		; false
	ret

	ENDMODULE


	MODULE	isalnum
;
; "ctype.h"
; Проверяет символ на принадлежность к алфавитно-цифровому
; типу (A..Z, a..z, 0..9)
; in: a = символ
; out: true - алфавитно-цифровой символ
;      false - нет
;
; BOOL isalnum(char ch)
;
isalnum_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,4+32+64
	and	(hl)	
	ret

	ENDMODULE


	MODULE	isxdigit
;
; "ctype.h"
; Проверяет на шестнадцатеричные цифры (0..9, A..F, a..f)
; in: a = символ
; out: true - hex-цифра
;      false - нет
;
; BOOL isxdigit(char c)
;
isxdigit_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,10h
	and	(hl)	
	ret

	ENDMODULE


	MODULE	isspace
;
; "ctype.h"
; Проверяет на пробельные символы (0x09, 0x0D или 0x20)
; in: a = символ
; out: true - пробельный символ
;      false - нет
;
; BOOL isspace(char ch)
;
isspace_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,2
	and	(hl)	
	ret

	ENDMODULE


	MODULE	iscntrl
;
; "ctype.h"
; Проверяет на управляющий символ (0х00..0х1F или 0x7F)
; in: a = символ
; out: true - управляющий символ
;      false - нет
;
; BOOL iscntl(char ch)
;
iscntrl_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,1
	and	(hl)	
	ret

	ENDMODULE


	MODULE	ispunct
;
; "ctype.h"
; Проверяет на знаки пунктуации
; in: a = символ
; out: true - знак пунктуации
;      false - нет
;
; BOOL ispunct(char ch)
;
ispunct_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,8
	and	(hl)	
	ret

	ENDMODULE


	MODULE	isalpha
;
; "ctype.h"
; Проверяет на принадлежность к буквам (A..Z, a..z)
; in: a = символ
; out: true - буква
;      false - не буква
;
; BOOL isalpha(char ch)
;
isalpha_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,32+64
	and	(hl)	
	ret

	ENDMODULE


	MODULE	isgraph
;
; "ctype.h"
; Проверяет на принадлежность к печатаемым символам,
; исключая символ пробела (0х21..0х7E)
; in: a = символ
; out: true - печатаемый символ
;      false - нет
;
; BOOL isgraph(char ch)
;
isgraph_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,0FCh
	and	(hl)	
	ret

	ENDMODULE


	MODULE	isprint
;
; "ctype.h"
; Проверяет на принадлежность к печатаемым
; символам (0х20..0х7E).
; in: a = символ
; out: true - печатаемый символ
;      false - нет
;
; BOOL isprint(char ch)
;
isprint_::
	ld	l,a
	ld	h,0
	ld	de,@ctype##
	add	hl,de
	ld	a,0FEh
	and	(hl)	
	ret

	ENDMODULE
