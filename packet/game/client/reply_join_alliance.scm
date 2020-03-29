(module system racket/base
	(require "../../packet.scm")
	(provide game-client-packet/reply-join-alliance)
	
	(define (game-client-packet/reply-join-alliance accept?)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x8D s)
				(write-int32 (if accept? 1 0) #f s)
				(get-output-bytes s)
			)
		)
	)
)