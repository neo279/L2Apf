; l2j/gameserver/serverpackets/PartySmallWindowUpdate.java
(module system racket/base
	(require "../../packet.scm")
	(provide game-server-packet/party-member-update)

	(define (game-server-packet/party-member-update buffer)
		(let ((s (open-input-bytes buffer)))
			(list
				(cons 'id (read-byte s))
				(cons 'object-id (read-int32 #f s))
				(cons 'name (read-utf16 s))
				(cons 'cp (read-int32 #f s))
				(cons 'max-cp (read-int32 #f s))
				(cons 'hp (read-int32 #f s))
				(cons 'max-hp (read-int32 #f s))
				(cons 'mp (read-int32 #f s))
				(cons 'max-mp (read-int32 #f s))
				(cons 'level (read-int32 #f s))
				(cons 'class-id (read-int32 #f s))
			)
		)
	)
)
