; l2j/gameserver/clientpackets/Action.java
(module system racket/base
	(require "../../packet.scm")
	(provide game-client-packet/action)

	(define (game-client-packet/action object-id origin shift?)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x1F s)
				(write-int32 object-id #f s)
				(write-point origin s)
				(write-byte (if shift? 1 0) s)
				(get-output-bytes s)
			)
		)
	)
)
