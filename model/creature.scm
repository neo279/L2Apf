(module logic racket/base
	(require
		srfi/1
		(only-in racket/function negate)
		(rename-in racket/contract (any all/c))
		"../library/extension.scm"
		"../library/date_time.scm"
		"../library/geometry.scm"
		"../system/structure.scm"
		"map.scm"
		"object.scm"
	)
	(provide (contract-out
		(creature? (-> any/c boolean?))
		(make-creature (-> list? list?))
		(update-creature (-> list? list? (values list? list? list?)))
		(update-creature! (-> box? list? list?))

		(moving? (-> creature? boolean?))
		(casting? (-> creature? boolean?))
		(get-speed (-> creature? integer?))
		(get-position (-> creature? (or/c point/3d? false/c)))
		(creatures-angle (-> creature? creature? (or/c rational? false/c)))
		(creatures-distance (-> creature? creature? integer?))
	))

	(define creature (list
		(cons 'name (negate string=?))
		(cons 'title (negate string=?))

		(cons 'target-id (negate =))

		(cons 'hp (negate =))
		(cons 'mp (negate =))
		(cons 'max-hp (negate =))
		(cons 'max-mp (negate =))

		(cons 'sitting? (negate eq?))
		(cons 'walking? (negate eq?))
		(cons 'in-combat? (negate eq?))
		(cons 'alike-dead? (negate eq?))
		(cons 'casting #t)

		(cons 'angle (negate =))
		(cons 'position (negate point/3d=))
		(cons 'destination (negate point/3d=))
		(cons 'located-at #t)

		(cons 'collision-radius (negate =))
		(cons 'collision-height (negate =))
		(cons 'magical-attack-speed (negate =))
		(cons 'physical-attack-speed (negate =))
		(cons 'move-speed-factor (negate =))
		(cons 'attack-speed-factor (negate =))
		(cons 'run-speed (negate =))
		(cons 'walk-speed (negate =))
		(cons 'swim-run-speed (negate =))
		(cons 'swim-walk-speed (negate =))
		(cons 'fly-run-speed (negate =))
		(cons 'fly-walk-speed (negate =))

		(cons 'clothing (negate alist-equal?))
	))

	(define (creature? object)
		(if (and object (member 'creature (ref object 'type))) #t #f)
	)

	(define (make-creature data)
		(let ((object (make-object data)))
			(let ((type (cons 'creature (ref object 'type))))
				(fold
					(lambda (p r) (if (and p (assoc (car p) creature eq?)) (cons p r) r)) ; If field belongs to creature.
					(cons (cons 'type type) (alist-delete 'type object))
					data
				)
			)
		)
	)

	(define (location-field? pair)
		(member (car pair) (list 'position 'destination 'angle))
	)
	(define (parse-location data)
		(let ((pf (assoc 'position data eq?)) (df (assoc 'destination data eq?)) (af (assoc 'angle data eq?)) (at (cons 'located-at (timestamp))))
			(cond
				((and pf df) (let ((df (cons 'destination (and (cdr df) (not (point/3d= (cdr pf) (cdr df))) (cdr df))))) ; Reset destination if equal to position.
						(if (or af (cdr df)) ; If angle specified or can be calculated.
							(list pf df (or af (cons 'angle (points-angle (cdr pf) (cdr df)))) at) ; Update angle, position, destination, timestamp.
							(list pf df at) ; Update position, destination, timestamp.
						)
				))
				((and pf af) (list pf af at)) ; Update angle, position, timestamp.
				(pf (list pf at)) ; Update position, timestamp.
				(af (list af)) ; Just update angle.
				(else (list))
			)
		)
	)
	(define (update-creature object data)
		(let-values (((ld bd) (partition location-field? data)))
			(struct-update (append bd (parse-location ld)) creature (update-object object data))
		)
	)
	(define (update-creature! object data)
		(let-values (((rest updated changes) (update-creature (unbox object) data)))
			(set-box! object (append rest updated))
			changes
		)
	)

	(define (casting? creature)
		(if (ref creature 'casting) #t #f)
	)

	(define (moving? creature)
		(if (and
			(ref creature 'destination)
			(not (casting? creature))
			; TODO not immobilized effect
		) #t #f)
	)

	(define (get-speed creature)
		(if (moving? creature)
			(if (ref creature 'walking?)
				(or (ref creature 'walk-speed) 0)
				(or (ref creature 'run-speed) 0)
			)
			0
		)
	)
	(define (get-position creature)
		(let ((speed (get-speed creature)) (at (ref creature 'located-at)) (p (ref creature 'position)) (d (ref creature 'destination)))
			(if (and (> speed 0) p at) ; If moving? and located-at is set.
				(let ((cd (* (- (timestamp) at) speed)))
					(if (< cd (distance/3d p d)) (segment-offset/3d p d cd) d) ; Total or calculated distance.
				)
				p
			)
		)
	)

	(define (creatures-angle a b)
		(points-angle (get-position a) (get-position b))
	)

	(define (creatures-distance a b)
		(points-distance (get-position a) (get-position b))
	)
)
