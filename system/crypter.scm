(module system racket/base
	(require
		srfi/1
		racket/trace
		(rename-in racket/contract (any all/c))
		"debug.scm"
	)
	(provide (contract-out
		(crypter? (any/c . -> . boolean?))
		(make-crypter ((and/c bytes? length-is-16?) . -> . procedure?))
	))

	(define (update-key key size)
		(let ((t (+ (integer-bytes->integer (subbytes key 8 12) #f) size)))
			(bytes-append (subbytes key 0 8) (integer->integer-bytes (bitwise-and t #xffffffff) 4 #f) (subbytes key 12 16))
		)
	)

	(define (encrypt data key)
		(apf-debug "ENC DATA <- ~v" data)
		(apf-debug "ENC KEY <- ~v" key)
		(define (f d r k p)
			(if (null? d)
				r
				(let ((i (bitwise-xor (car d) p (car k))))
					(f (cdr d) (cons i r) (cdr k) i)
				)
			)
		)
		(let ((data (bytes->list data)) (key (apply circular-list (bytes->list key))))
			(let ((out (list->bytes (reverse (f data (list) key 0)))))
				(apf-debug "ENC DATA -> ~v" out)
				out
			)
		)
	)

	(define (decrypt data key)
		(define (f d r k p)
			(if (null? d)
				r
				(let ((i (bitwise-xor (car d) p (car k))))
					(f (cdr d) (cons i r) (cdr k) (car d))
				)
			)
		)
		(let ((data (bytes->list data)) (key (apply circular-list (bytes->list key))))
			(list->bytes (reverse (f data (list) key 0)))
		)
	)

	(define (make-crypter key)
		(define encrypt-key key)
		(define decrypt-key key)

		(lambda (data encrypt?)
			(if encrypt?
				(let ((data (encrypt data encrypt-key)))
					(set! encrypt-key (update-key encrypt-key (bytes-length data)))
					data
				)
				(let ((data (decrypt data decrypt-key)))
					(set! decrypt-key (update-key decrypt-key (bytes-length data)))
					data
				)
			)
		)
	)

	(define (crypter? cr)
		(procedure? cr)
	)

	(define (length-is-16? data)
		(= (bytes-length data) 16)
	)
)
