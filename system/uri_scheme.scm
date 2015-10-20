(module system racket/base
	(require
		srfi/1
		srfi/13
		(rename-in racket/contract (any all/c))
	)
	(provide (contract-out
		(parse-uri (string? . -> . (or/c list? false/c)))
	))
	
	(define (parse-uri uri)
		(let ((t (regexp-match #rx"^l2apf://([0-9A-Za-z]+):([0-9A-Za-z]+)@([0-9A-Za-z\\.\\-]+):?([0-9]*)/([0-9A-Za-z]+)[\\?#/]?" uri)))
			(if t
				(list
					(second t) ; login
					(third t) ; password
					(fourth t) ; host
					(let ((port (fifth t))) ; port
						(if (string-null? port) 2106 (string->number port))					
					)
					(sixth t) ; name
				)
				#f
			)
		)
	)
)