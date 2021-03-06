(require :asdf)
(asdf:operate 'asdf:load-op 'woolly-gl :verbose nil)

(rename-package 'woolly-gl 'toolkit)

(defun test ()
  (let ((font (asdf:component-pathname
	          (asdf:find-component
		      (asdf:find-component (asdf:find-system 'woolly nil)
					   "okolaks")
		      "okolaksRegular.ttf")))
	(font-size 20)
	(sub-font-size 12))

    ;; prepare the default font...
    (setf (woolly:font woolly:=widget=) (sheeple:object :parents toolkit:=font=
							:em-size font-size
							:pathname font))

    (setf (woolly:font woolly:=subwindow=)
	                                (sheeple:object :parents toolkit:=font=
							:em-size sub-font-size
							:pathname font))

    (let ((app (sheeple:object :parents toolkit:=app=))
	  (win (sheeple:object :parents toolkit:=window=
			       :title "Woolly Window 1"
			       :width 480
			       :height 320))
	  (default-button (sheeple:object :parents toolkit:=button=
					  :offset-x 10
					  :offset-y 260
					  :width 100
					  :height 40)))
	 
      (woolly:display-window win)

      (woolly:add win (sheeple:object :parents default-button
				      :label "Green"))

      (let ((sub (sheeple:object :parents toolkit:=subwindow=
				 :title "This Is My SubWindow!"
				 :offset-x 10
				 :offset-y 40
				 :width 210
				 :height 200))
	    (quit-button (sheeple:object :parents default-button
					 :offset-y 10
					 :label "Quit")))

	(sheeple:defreply woolly:clicked :after ((bb quit-button) mb xx yy)
	   (woolly:exit-main-loop app))

	(woolly:add sub quit-button)
	(woolly:add sub (sheeple:object :parents toolkit:=subwindow=
					:title "Small"
					:offset-x 10
					:offset-y 60
					:width 100
					:height 80))
	(woolly:add win sub))

      (woolly:add win (sheeple:object :parents default-button
				      :offset-x 120
				      :label "Blue"))

      (woolly:add win (sheeple:object :parents toolkit:=checkbox=
				      :offset-x 230
				      :offset-y 160
				      :width 100
				      :height 30
				      :label "Check Me!"))

      (woolly:add win (sheeple:object :parents toolkit:=label=
				      :offset-x 230
				      :offset-y 260
				      :width 200
				      :height 40
				      :label "This is a label."))

      (woolly:main-loop app))))
