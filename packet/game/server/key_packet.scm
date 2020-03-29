(module system racket/base
	(provide game-server-packet/key-packet)
	(require "../../packet.scm")
	
	(define (game-server-packet/key-packet buffer)
		(let ((s (open-input-bytes buffer)))
			(list
				(cons 'id (read-byte s))
				(cons 'protocol-ok (read-byte s))
				(cons 'key (bytes-append (read-bytes 8 s) (bytes #xc8 #x27 #x93 #x01 #xa1 #x6c #x31 #x97)))
			)
		)
	)
)