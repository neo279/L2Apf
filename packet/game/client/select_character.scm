(module system racket/base
	(provide game-client-packet/select-character)
	(require "../../packet.scm")

	(define (game-client-packet/select-character struct)
		(let ((s (open-output-bytes)))
			(begin
				(write-byte #x12 s)
				(write-int32 (cdr (assoc 'id struct)) #f s)
				(write-bytes (make-bytes 16) s)
				(get-output-bytes s)
			)
		)
	)
)