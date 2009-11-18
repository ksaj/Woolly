(in-package #:woolly-gl)

(sheeple:defproto =font= (woolly:=font=)
  ())

(sheeple:defreply woolly:draw-string ((font =font=) (string sheeple:=string=)
				      &key (xx 0) (yy 0) centered)
  (labels ((make-interpolator (ss cc ee)
	     (let ((xx (+ ss (* -2 cc) ee))
		   (yy (* 2 (- cc ss))) 
		   (zz ss))
	       #'(lambda (tt)
		   (+ (* xx tt tt)
		      (* yy tt)
		      zz))))

	   (interpolate (sx sy ex ey int-x int-y &optional (st 0) (et 1))
	     (let ((mx (/ (+ sx ex) 2.0))
		   (my (/ (+ sy ey) 2.0))
		   (mt (/ (+ st et) 2.0)))
	       (let ((nx (funcall int-x mt))
		     (ny (funcall int-y mt)))
		 (let ((dx (- mx nx))
		       (dy (- my ny)))
		   (when (< 1 (+ (* dx dx) (* dy dy)))
		     (interpolate sx sy nx ny int-x int-y st mt)
		     (gl:vertex nx ny)
		     (interpolate nx ny ex ey int-x int-y mt et))))))

	   (render-glyph (glyph)
	     (zpb-ttf:do-contours (contour glyph)
	       (gl:with-primitives :polygon
		 (zpb-ttf:do-contour-segments (start ctrl end) contour
		    (gl:vertex (zpb-ttf:x start) (zpb-ttf:y start))
		    (when ctrl
		      (let ((sx (zpb-ttf:x start))
			    (sy (zpb-ttf:y start))
			    (cx (zpb-ttf:x ctrl))
			    (cy (zpb-ttf:y ctrl))
			    (ex (zpb-ttf:x end))
			    (ey (zpb-ttf:y end)))
			(let ((int-x (make-interpolator sx cx ex))
			      (int-y (make-interpolator sy cy ey)))
			  (interpolate sx sy ex ey int-x int-y))))
		    (gl:vertex (zpb-ttf:x end) (zpb-ttf:y end))))))

	   (render-string (string font-loader &optional (pos 0) prev)
	     (when (< pos (length string))
	       (let ((cur (zpb-ttf:find-glyph (aref string pos) font-loader)))
		 (render-glyph cur)
		 (gl:translate (zpb-ttf:advance-width cur) 0 0)
		 (when prev
		   (gl:translate (zpb-ttf:kerning-offset prev
							 cur
							 font-loader)
				 0
				 0))
		 (render-string string font-loader (1+ pos) cur)))))
    (let* ((font-loader (woolly:zpb-font-loader font))
	   (box (zpb-ttf:string-bounding-box string font-loader :kerning t))
	   (bx1 (aref box 0))
	   (by1 (aref box 1))
	   (bx2 (aref box 2))
	   (by2 (aref box 3)))
      (gl:with-pushed-matrix
	(gl:translate xx yy 0)
	(let ((ss (/ (woolly:em-size font) (zpb-ttf:units/em font-loader))))
	  (gl:scale ss ss 1))
	(when centered
	  (gl:translate (/ (- bx1 bx2) 2) (/ (- by1 by2) 2) 0))
	(gl:with-pushed-attrib (:stencil-func :stencil-test :color)
	  (gl:enable :stencil-test)
	  (gl:clear :stencil-buffer-bit)
	  (gl:stencil-func :always 1 1)
	  (gl:stencil-op :invert :invert :invert)
	  (gl:color-mask nil nil nil nil)
	  (gl:with-pushed-matrix
	    (render-string string font-loader))
	  (gl:color-mask t t t t)
	  (gl:stencil-func :equal 1 1)
	  (gl:stencil-op :keep :keep :keep)
	  (gl:enable :blend)
	  (gl:blend-func :src-alpha :one-minus-src-alpha)
	  (gl:with-primitives :quads
	    (gl:vertex bx1 by1)
	    (gl:vertex bx2 by1)
	    (gl:vertex bx2 by2)
	    (gl:vertex bx1 by2)))))))

