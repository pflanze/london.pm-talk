
(def char-word? char-alphabetic?) ;; XXX replace with implementation
				  ;; that treats words of most human
				  ;; languages correctly.

(def (non-word? v)
     (or (not v)
	 (not (char-word? v))))

(def (maybe-car l)
     (if (null? l)
	 #f
	 (car l)))

(def. (string.first s)
  (string-ref s 0))

(TEST
 > (.first "Hello")
 #\H
 ;; > (%try-error (.first ""))
 ;; *** ERROR IN (console)@5.1 -- (Argument 2) Out of range
 )

(def pretty-opening-doublequote (.first "“"))
(def pretty-closing-doublequote (.first "”"))
(def pretty-opening-singlequote (.first "‘"))
(def pretty-closing-singlequote (.first "’"))

(def (list-pretty-quotes l #!optional maybe-prev-c)
     (if (pair? l)
	 (let-pair ((c l*) l)
		   (def (choose opening closing)
			(if (non-word? maybe-prev-c)
			    (if (non-word? (maybe-car l*))
				c
				opening)
			    (if (non-word? (maybe-car l*))
				closing
				c)))
		   (cons (case c
			   ((#\")
			    (choose pretty-opening-doublequote
				    pretty-closing-doublequote))
			   ((#\')
			    (choose pretty-opening-singlequote
				    pretty-closing-singlequote))
			   (else
			    c))
			 (list-pretty-quotes l* c)))
	 l))

(def pretty-quotes (compose* list.string
			     list-pretty-quotes
			     string.list))

(TEST
 > (pretty-quotes "")
 ""
 > (pretty-quotes "'Hey")
 "‘Hey" ;; well
 > (pretty-quotes "Al'")
 "Al’" ;; dito
 > (pretty-quotes "El' 'lama")
 "El’ ‘lama" ;; ?
 > (pretty-quotes "You are 'nice'")
 "You are ‘nice’"
 > (pretty-quotes "You are 'nice' and such.")
 "You are ‘nice’ and such."
 > (pretty-quotes "You are 'nice'.")
 "You are ‘nice’."
 > (pretty-quotes "\"Always\" is a bit strong.")
 "“Always” is a bit strong.")

