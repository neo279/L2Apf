(module system racket/base
	(provide game-client-packet/restart)
	(require "../../packet.scm")
	
	(define (game-client-packet/restart)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x57 s)
				(get-output-bytes s)
			)
		)
	)
)