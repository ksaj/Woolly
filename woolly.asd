
(asdf:defsystem #:woolly
    :author "Patrick Stein <pat@nklein.com>"
    :maintainer "Patrick Stein <pat@nklein.com>"
    :licence "Public Domain"
    :depends-on (#:sheeple #:zpb-ttf)
    :components ((:module "woolly"
		  :components ((:file "package")
		               (:file "utils"     :depends-on ("package"))
			       (:file "font"      :depends-on ("utils"))
		               (:file "app"       :depends-on ("utils"))
			       (:file "widget"    :depends-on ("font"))
			       (:file "button"    :depends-on ("widget"))
		               (:file "container" :depends-on ("widget"))
			       (:file "subwindow" :depends-on ("container"))
			       (:file "window"    :depends-on ("container")))
		  )))
