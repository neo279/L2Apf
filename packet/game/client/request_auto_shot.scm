(module system racket/base
	(require "../../packet.scm")
	(provide game-client-packet/request-auto-shot)
	
	(define (game-client-packet/request-auto-shot item-id is?)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #xd0 s)
				(write-int16 #x0D #f s)
				(write-int32 item-id #f s)
				(write-int32 (if is? 1 0) #f s)
				(get-output-bytes s)
			)
		)
	)
)