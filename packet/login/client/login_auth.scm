(module system racket/base
	(provide login-client-packet/login-auth)
	(require "../../../library/rsa.scm")
	(require "../../packet.scm")

	(define (login-client-packet/login-auth struct)
		(let ((s (open-output-bytes)) (rsa-key (cdr (assoc 'rsa-key struct))))
			(begin
				(file-position s #x5E)
				(write-ascii (cdr (assoc 'login struct)) s)
				(file-position s #x6C)
				(write-ascii (cdr (assoc 'password struct)) s)
				(file-position s #x80)

				(let ((buffer (get-output-bytes s #t)))
					(write-byte #x00 s)
					(write-bytes (rsa-encrypt buffer rsa-key) s)
					(write-int32 (cdr (assoc 'session-id struct)) #f s)
					(write-bytes (bytes
						#x23 #x01 #x00 #x00 
						#x67 #x45 #x00 #x00 
						#xAB #x89 #x00 #x00 
						#xEF #xCD #x00 #x00
						#x00 #x00 #x00
					) s)
					(write-bytes (checksum (get-output-bytes s)) s)
					(write-bytes (make-bytes 4) s)
					(get-output-bytes s)
				)
			)
		)
	)
)
