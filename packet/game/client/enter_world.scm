; l2j/gameserver/clientpackets/EnterWorld.java
(module system racket/base
	(provide game-client-packet/enter-world)
	(require "../../packet.scm")

	(define (game-client-packet/enter-world)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x11 s)
				(write-bytes (make-bytes 16) s)
				(write-bytes (bytes ; 72 len
					#xC1 #x7A #xD7 #x78 #x45 #x10 #xD7 #x96 #x15 #xA4 #x98 #x8F #x39 #x4C #xEF #x78 #xC4 #x81 #xEA #x9F #x25 #xB5 #xBC #x5B #xF2 #xC2 #x79 #x06 #x63 #x67 #x47 #x10 #x96 #x88 #xD4 #x75 #xE0 #x8F #xCF #x71 #xA8 #x2F #xDA #x35 #x5D #x9E #x45 #x6E #x81 #xFC #x7B #xB9 #x2A #x62 #x96 #xEA #x44 #x13 #x09 #xCA #x81 #x52 #x16 #x3E #x74 #x16 #x00 #x00 #xD8 #x6B #xF2 #xC3
				) s)
				(write-int32 0 #f s)
				(write-int32 0 #f s)
				(write-int32 0 #f s)
				(write-int32 0 #f s)
				(write-byte 0 s)
				(write-byte 0 s)
				(write-byte 0 s)
				(write-byte 0 s)
				(write-byte 0 s)
				(get-output-bytes s)
			)
		)
	)
)
