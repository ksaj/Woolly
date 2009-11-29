(in-package #:woolly-gl)

(sheeple:defproto =subwindow= (=widget= woolly:=subwindow=)
  (mouse-down-in-main-body))

(sheeple:defreply sheeple:init-object :after ((ss =subwindow=)
					      &key &allow-other-keys)
  (let ((ww (woolly:width ss))
	(hh (woolly:height ss))
	(cc (woolly:container ss)))
    (setf (woolly:width cc) ww
	  (woolly:height cc) (max (- hh 20) 0)
	  (mouse-down-in-main-body ss) nil)))

(sheeple:defreply woolly:mouse-down :around ((ss =subwindow=) mb xx yy)
  (let ((ww (woolly:width ss))
	(hh (woolly:height ss)))
    (setf (mouse-down-in-main-body ss) nil)
    (cond
      ;; in drag bar
      ((and (< -1 xx (- ww 20))
	    (< (- hh 21) yy hh))  (setf (woolly:dragging ss)
					(cons xx yy)))

      ;; in iconify region
      ((and (< (- ww 21) xx ww)
	    (< (- hh 21) yy hh))  (setf (woolly:closed ss)
					(not (woolly:closed ss)))
                                  t)

      ;; in main body
      ((and (not (woolly:closed ss))
	    (< -1 xx ww)
	    (< -1 yy (- hh 20)))  (setf (mouse-down-in-main-body ss)
					(woolly:mouse-down
					            (woolly:container ss)
						    mb xx yy)))

      ;; missed entirely
      (t nil))))

(sheeple:defreply woolly:mouse-up :after ((ss =subwindow=) mb xx yy)
  (setf (woolly:dragging ss) nil
	(mouse-down-in-main-body ss) nil))

(sheeple:defreply woolly:mouse-up :around ((ss =subwindow=) mb xx yy)
  (cond
    ((mouse-down-in-main-body ss) (setf (mouse-down-in-main-body ss) nil)
                                  (woolly:mouse-up (woolly:container ss)
						   mb xx yy))
    (t (sheeple:call-next-reply))))

(sheeple:defreply woolly:mouse-move :around ((ss =subwindow=) xx yy)
  (cond
    ((mouse-down-in-main-body ss) (woolly:mouse-move (woolly:container ss)
						     xx yy))
    (t (sheeple:call-next-reply))))

(sheeple:defreply woolly:draw ((ss =subwindow=))
  (let ((ww (woolly:width ss))
	(hh (woolly:height ss)))
    (gl:with-pushed-matrix
      (gl:translate 0 (- hh 20) 0)
      (draw-filled-box (- ww 20) 20 '(0.5 0.5 0.5) '(0.75 0.75 0.75))
      (with-clip-to (5 0 (- ww 30) hh)
	(gl:color 0 0 0)
	(woolly:draw-string (woolly:font ss) (woolly:title ss) :xx 5 :yy 5))
      (gl:translate (- ww 20) 0 0)
      (draw-filled-box 20 20 '(0.75 0.75 0.5)))

    (unless (woolly:closed ss)
      (draw-filled-box ww (- hh 20) '(0.25 0.25 0.25 0.95) '(0.5 0.5 0.5 0.8))

      (with-clip-to (0 0 ww (- hh 20))
	(woolly:draw (woolly:container ss))))))
