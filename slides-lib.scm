
;; http://xahlee.info/comp/unicode_arrows.html
(def rarrow "→")
(def long-rarrow "⟶")

(def (slideshow . slides)
     `(html
       (head
	(title ,title)
	;; <meta name="generator" content="S5" />
	(meta (@ (name "generator")
		 (content "scm/S5")))
	;; <meta name="author" content="Eric A. Meyer" />
	;; <meta name="defaultView" content="slideshow" />
	(meta (@ (name "defaultView")
		 (content "slideshow")))
	(meta (@ (name "controlVis")
		 (content "hidden")))
	(link (@ (rel "stylesheet")
		 (href "ui/default/slides.css")
		 (type "text/css")
		 (media "projection" )
		 (id "slideProj")))
	(link (@ (rel "stylesheet")
		 (href "ui/default/outline.css")
		 (type "text/css")
		 (media "screen")
		 (id "outlineStyle")))
	(link (@ (rel "stylesheet")
		 (href "ui/default/print.css")
		 (type "text/css")
		 (media "print")
		 (id "slidePrint")))
	(link (@ (rel "stylesheet")
		 (href "ui/default/opera.css")
		 (type "text/css")
		 (media "projection")
		 (id "operaFix")))
	(script (@ (src "ui/default/slides.js")
		   (type "text/javascript")))
	,(force perltidy-css))
       (body
	(div (@ (class "layout"))
	     (div (@ (id "controls")))
	     (div (@ (id "currentSlide")))
	     (div (@ (id "header")))
	     (div (@ (id "footer"))
		  (h1 ,date ", " ,location)
		  (h2 ,title)))
	(div (@ (class "presentation"))
	     ,@slides))))

(def (rslideshow . slides)
     (apply slideshow (cons (car slides)
			    (reverse (cdr slides)))))


(def (slide slidetitle . body)
  `(div (@ (class "slide"))
	(h1 ,slidetitle)
	,@body))


;; multi-slides: not using any fancy js effects, just duplicate/modify
;; them, ok?

(def slide*-viewer-names
     '(TWO THREE FOUR FIVE SIX SEVEN))
(def slide*-viewer-map
     (zip slide*-viewer-names
	  (iota (length slide*-viewer-names) 2)))

(defmacro (slide* n . body)
  (let ((n (-> natural? (eval n))))
    (cons 'list
	  (map (lambda (i)
		 `(let ,(filter-map
			 (mcase-lambda
			  (`(`name `num)
			   (if (< i (dec num))
			       `(,name (lambda x #f))
			       `(,name identity))))
			 slide*-viewer-map)
		    (slide ,@body)))
	       (iota n)))))

(TEST
 > (slide* 3 (TWO "ha") (THREE "bla"))
 ((div (@ (class "slide")) (h1 #f) #f)
  (div (@ (class "slide")) (h1 "ha") #f)
  (div (@ (class "slide")) (h1 "ha") "bla")))


;; for inside slide, it seems
;; <div class="handout">
;; [any material that should appear in print but not on the slide]
;; </div>


(def (_tag nm)
     (lambda args
       (cons nm args)))
(defmacro (dtag nm)
  `(def ,nm (_tag ',nm)))

(dtag h2)
(dtag h3)
(dtag h4)
(dtag ul)
(dtag ol)
(dtag li)
(dtag code);?
(dtag pre);?
(dtag br)
(dtag small)
(dtag center)
(dtag p)



(def (ahref href . body)
     `(a (@ (href ,href))
	 ,@body))

(def (link ref)
     ;; heh space before so it doesn't attach to whatever is before hm
     `(" " ,(ahref ref ref)))

(def (http-link ref-without-protocol)
     `(" " ,(ahref (string-append "http://" ref-without-protocol)
		   ref-without-protocol)))

;; (def (footnote . body)
;;      '()) ;; SGH + begin sigh

;; ;; for inline formatting?
;; (def (cod . body)
;;      (small (br) ;;(br);;XX
;; 	    (code body)))

;; for stand-alone division
(define (Cod . body)
  (list (br) ;;(br);;XX
	(pre body)))

(def-once PerlCod
  (memoize
   (lambda maybe-strings
     (let ((str (apply string-append
		       (filter identity maybe-strings))))
       (warn "PerlCod" str)
       (string->uninterned-symbol (xbacktick "./perl-format-string" str))))))

(def (get-perltidy-css)
     (xbacktick "./perl-format-getcss"))

(def (save-perltidy-css)
     (string.print-file (get-perltidy-css) "perltidy.css"))

(def perltidy-css
     (delay (string->uninterned-symbol (xbacktick "cat" "perltidy.css"))))


;; Git specific ---------------------------------------------
(def (mang fullcmd)
     `(" "(a (@ (href ,(string-append
			"https://www.kernel.org/pub/software/scm/git/docs/"
			fullcmd
			".html")))
	     ,fullcmd)))
(def (git cmd)
     (mang (string-append "git-" cmd)))
;; /Git specific ---------------------------------------------


(def (img/width path w-percent)
     `(img (@ (src ,path)
	      (width ,(string-append
		       (number->string (integer (* w-percent 0.78))) "%")))))

(def (red . body)
     `(font (@ (color
		;;"rgb(245, 60, 60)"
		,(.html-colorstring (rgb8 245 60 60)))) ,@body))


;; --- main -------------------------------------------------
(def (gen)
     (lo)
     (sxml>>pretty-xhtml-file (force slides) "html/index.html"))

