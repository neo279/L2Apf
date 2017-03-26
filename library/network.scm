; TODO move to system

(module network racket/base
	(require
		racket/contract
		racket/async-channel
		"structure.scm"
	)
	(provide (contract-out
	;	(smart-receive receive (box? . -> . bytes?))
	;	(smart-send send (box? bytes? . -> . void?))
		(disconnect (box? . -> . void?))
		(get-packet-id (bytes? . -> . byte?))
	))
	(provide
		(rename-out (smart-receive receive))
		(rename-out (smart-send send))
	)
	
	(define (print-dump label data)
		(display label)
		(display (map (lambda (x) (format "~x" x)) (bytes->list data)))
		(newline)
	)
	
	(define (read-buffer port)
		(let loop ()
			(let ((size (integer-bytes->integer (read-bytes 2 port) #f)))
				(if (> size 2)
					(read-bytes (- size 2) port)
					(loop) ; skip empty packets
				)
			)
		)
	)
	(define (write-buffer buffer port)
		(let ((size (+ (bytes-length buffer) 2)))
			(write-bytes (integer->integer-bytes size 2 #f) port)
			(write-bytes buffer port)
			(flush-output port)
		)
	)
	
	(define (receive input-port crypter)
		(let ((buffer (read-buffer input-port)))
			;(print-dump "buffer <-: " buffer)
			(let ((buffer (if crypter (crypter buffer #f) buffer)))
				;(print-dump "packet <-: " buffer)
				buffer
			)
		)
	)
	
	(define (send buffer output-port crypter)
		;(print-dump "packet ->: " buffer)
		(let ((buffer (if crypter (crypter buffer #t) buffer)))
			;(print-dump "buffer ->: " buffer)
			(write-buffer buffer output-port)
			(void)
		)
	)
	
	(define (smart-receive connection)
		(define read-thread (@: connection 'read-thread))
		(if (and read-thread (not (equal? read-thread (current-thread))))
			(async-channel-get (@: connection 'input-channel))
			(let ((input-port (@: connection 'input-port)) (crypter (@: connection 'crypter)))
				(receive input-port crypter)
			)
		)
	)
	(define (smart-send connection buffer)
		(define send-thread (@: connection 'send-thread))
		(if (and send-thread (not (equal? send-thread (current-thread))))
			(async-channel-put (@: connection 'output-channel) buffer)
			(let ((output-port (@: connection 'output-port)) (crypter (@: connection 'crypter)))
				(send buffer output-port crypter)
			)
		)
	)
	
	(define (disconnect connection)
		(begin
			(let ((read-thread (@: connection 'read-thread)))
				(if read-thread (kill-thread read-thread) (void))
			)
			(let ((send-thread (@: connection 'send-thread)))
				(if send-thread (kill-thread send-thread) (void))
			)
			(close-input-port (@: connection 'input-port))
			(close-output-port (@: connection 'output-port))
			(void)
		)
	)
	
	(define (get-packet-id buffer)
		(bytes-ref buffer 0)
	)
)
