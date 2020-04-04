; l2j/gameserver/clientpackets/RequestWithDrawalParty.java
(module system racket/base
	(require "../../packet.scm")
	(provide game-client-packet/leave-party)

	(define (game-client-packet/leave-party)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x44 s)
				(get-output-bytes s)
			)
		)
	)
)
