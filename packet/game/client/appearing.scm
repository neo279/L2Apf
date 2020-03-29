(module system racket/base
	(provide game-client-packet/appearing)
	(require "../../packet.scm")

	(define (game-client-packet/appearing)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x3A s)
				(get-output-bytes s)
			)
		)
	)
)
