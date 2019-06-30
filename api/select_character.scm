(module api racket/base
	(require
		racket/contract
		racket/async-channel
		"../library/extension.scm"
		"../library/structure.scm"
		"../library/network.scm"
		"../packet/game/client/select_character.scm"
		"../packet/game/server/player_character.scm"
		"../packet/game/client/enter_world.scm"
		"../model/protagonist.scm"
		"../system/read_thread.scm"
		"../system/send_thread.scm"
		"../system/timers.scm"
		"../system/events.scm"
		"refresh_manor_list.scm"
		"refresh_quest_list.scm"
		"refresh_skill_list.scm"
	)
	(provide select-character)

	(define (select-character connection character)
		(send connection (game-client-packet/select-character (list
			(cons 'id (unbox character))
		)))

		(let loop ()
			(let ((buffer (receive connection)))
				(case (get-packet-id buffer)
					((#x15) (let ((packet (game-server-packet/player-character buffer)))
						(let ((world (@: connection 'world)) (me (create-protagonist (@: packet 'me))))
							(set-box! character (unbox me))
							(hash-set! world 'me character)
						)

						(refresh-manor-list connection)
						(refresh-quest-list connection)
						(send connection (game-client-packet/enter-world))
						(refresh-skill-list connection)
					))
					(else (loop))
				)
			)
		)

		(begin
			(set-box-field! connection 'input-channel (make-async-channel))
			(let ((read (thread (bind read-thread connection))))
				(set-box-field! connection 'read-thread read)
			)
			(set-box-field! connection 'output-channel (make-async-channel))
			(let ((send (thread (bind send-thread connection))))
				(set-box-field! connection 'send-thread send)
			)
			(let* ((tc (make-async-channel)) (th (thread (bind time-thread tc))))
				(begin
					(set-box-field! connection 'time-channel tc)
					(set-box-field! connection 'time-thread th)
				)
			)
			(let ((events (make-event-channel connection)))
				(set-box-field! connection 'event-channel events)
				events
			)
		)
	)
)
