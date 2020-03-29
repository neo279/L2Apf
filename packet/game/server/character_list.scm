(module system racket/base
	(provide game-server-packet/character-list)
	(require "../../packet.scm" "../../../system/debug.scm")

	(define (read-item s n)
		(let ((name (read-utf16 s)))
			(begin
				(read-bytes 4 s) ; must be object-id, but trash
				(read-utf16 s) ; login
				(read-bytes (+ ; 305
				 4 ; sessionid
				 4 ; clanid
				 4 ; builder level
				 4 ; sex
				 4 ; race
				 4 ; baseclass
				 4 ; active
				 12 ; x, y, z
				 8 ; hp
				 8 ; mp
				 4 ; sp
				 8 ; exp
				 8 ; percentage
				 4 ; lvl
				 4 ; pvp
				 4 ; pk
				 (* 7 4) ; zeroes
				 (* 26 4) ; paperdoll
				 4 ; hair style
				 4 ; hair color
				 4 ; face
				 8 ; max hp
				 8 ; max mp
				 4 ; delete timer
				 4 ; classid
				 4 ; c3 autoselect
				 1 ; enchant
				 4 ; augment id
				 4 ; retail transformation ??
				 4 ; pet id
				 4 ; pet level
				 4 ; max food
				 4 ; current food
				 8 ; max hp
				 8 ; max mp
				 4 ; vitality
				) s) ; other
				(apf-debug "char parsed ~v" name)
				(list
					(cons 'character-id n)
					(cons 'name name)
				)
			)
		)
	)

	(define (read-list s c n l)
		(if (< n c)
			(let ((i (read-item s n)))
				(read-list s c (+ n 1) (cons i l))
			)
			l
		)
	)

	(define (game-server-packet/character-list buffer)
		(let ((s (open-input-bytes buffer)))
			(let ((id (read-byte s)) (count (read-int32 #f s)) (max-char-num (read-int32 #f s)))
				(begin
					(read-byte s)
					(list
						(cons 'id id)
						(cons 'list (reverse (read-list s count 0 (list))))
					)
				)
			)
		)
	)
)
