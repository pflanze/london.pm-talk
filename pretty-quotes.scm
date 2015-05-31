
(def char-word? char-alphabetic?) ;; XXX replace with implementation
				  ;; that treats words of most human
				  ;; languages correctly.

(def word-char? (both char? char-word?))
(def whitespace-char? (both char? char-whitespace?))

(def. (false.pretty-order v)
  0)

(def. (char.pretty-order v)
  2)

(def. (whitespace-char.pretty-order v)
  1)

(def. (word-char.pretty-order v)
  3)

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


(def pretty-order-cmp
     (on .pretty-order number-cmp))

(TEST
 > (.pretty-order #\.)
 2
 > (.pretty-order #\0)
 2
 > (.pretty-order #\space)
 1
 > (.pretty-order #\a)
 3
 > (pretty-order-cmp #\0 #\a)
 lt
 > (pretty-order-cmp #\0 #f)
 gt
 > (pretty-order-cmp #f #\0)
 lt
 > (pretty-order-cmp #\a #\0)
 gt
 > (pretty-order-cmp #\a #\.)
 gt
 > (pretty-order-cmp #\. #\space)
 gt
 )


(def (list-pretty-quotes l #!optional maybe-prev-c)
     (if (pair? l)
	 (let-pair ((c l*) l)
		   (def (choose opening closing)
			(match-cmp
			 (pretty-order-cmp maybe-prev-c (maybe-car l*))
			 ((lt) opening)
			 ((eq) c)
			 ((gt) closing)))
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
 "“Always” is a bit strong."
 > (pretty-quotes "\"Always.\" ")
 "“Always.” "
 )

