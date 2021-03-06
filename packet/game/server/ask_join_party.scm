(module system racket/base
	(require racket/string "../../packet.scm" "../party_loot.scm")
	(provide game-server-packet/ask-join-party)

	(define (game-server-packet/ask-join-party buffer)
		(let ((s (open-input-bytes buffer)))
			(list
				(cons 'id (read-byte s))
				(cons 'name (string-trim (read-utf16 s)))
				(cons 'loot (cdr (assoc (read-int32 #f s) loot-types)))
			)
		)
	)
)
