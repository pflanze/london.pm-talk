
(define title "Using a functional programming style on Perl 5")
(define presenter "Christian Jaeger")
(define location "London Perl Mongers Technical Meeting")
(define date "May 28 2015")


(def (show-complement f)
     (lambda (x)
       (if (f #t)
	   #f
	   x)))

(def (inner-inner-leaking SHOW1 SHOW2 #!optional force-for-loop?)
     (PerlCod
      (SHOW2 "use Scalar::Util 'weaken';

sub Weakened ($) {
    my ($ref)= @_;
    weaken $_[0];
    $ref
}

")
      ;; ^ mention that it's in FP::lazy -- ehr, still don't know
      ;; where it should go!
      "func outer ($n) {
    my $inner; $inner= func ($n, $tot) {"(SHOW1 " # leaks memory!")"
        $n > 0 ? &$inner($n-1, $tot*$n) : $tot
    }; 
    "(if (SHOW2 #t)
	 "Weakened($inner)->"
	 "&$inner")"($n, 1);
}"((if force-for-loop? identity SHOW2) "

for (1..1e6) { outer 10 };")))


(define slides
  (delay
    (slideshow

     ;; first slide is treated specially in the layout by the js/css backend
     (slide title 
	    (h2 presenter)
	    (h4 (http-link "LeafPair.com")) ;; XX indent wrong
	    (p (i "Note: a few changes have been applied since the presentation. You can see them in the commit history at "(link "https://github.com/pflanze/london.pm-talk") ".")))

     (slide "Why functional programming in Perl?"
	    "I ..."
	    (ul
	     (li "used Perl as primary language 1998-2005")
	     (li "am using Scheme since 2005 if possible")
	     (li "am still using Perl a lot")
	     (li "am offering consulting in Perl")))

     (slide "Overview"
	    (ol
	     (li "Functional Programming?")
	     (li "Can Perl do it?")
	     (li "Combinators")
	     (li "Linked lists, lazy evaluation")
	     (li "Haskell style lazy sequences")
	     ;;(li "Examples (CSV/XML, skip)")
	     ))

     (slide "Functional programming?"
	    (p "A functional program")
	    (ul
	     (li "uses only pure functions and constants"
		 (ul
		  (li "a function is pure when:"
		      (ul
		       (li "it doesn't have any other effect than returning a result value")
		       (li "its result value depends only on its arguments")))
		  (li "functions may take functions as arguments, and/or return functions")))
	     (li "can only have other effects by way of instructing a
non-functional program to do them")
	     (li "can use method calls if all method implementations are pure")))

     (slide "Functional programming: why?"
	    (ul
	     ;; if only pure functions are used, then 
	     (li "dependencies and flow of data are directly visible from expressions"
		 ;; " (functional programs can be relied on not to  have invisibl ..)"
		 )
	     (li "no contortions necessary to test"
		 (PerlCod "TEST { null ->cons(1)->cons(2)->array }
  [2,1];"))
	     (li "the ultimate detangling "rarrow" reliable composability")
	     ;; (mention  compose  later on)
	     ))

     ;; (show TEST, repl ?)

     ;; ===== cases ========================================
     ;; A ------------------------------------
     (slide* 2
	     "Perl can do it, Right?"
	     (ul
	      (li "higher-order functions"
		  (PerlCod "my @b= map { $_*$_ } @a;\n"
			   (TWO "# hm, map is not taking a function as argument")))
	      (li "closures (functions created by other functions)"
		  (PerlCod "sub new_counter {
    my ($n)=@_;
    sub {
        $n++ "(TWO "# Ok, that's not actually pure")"
    }
}"))
	      (li "iteration using recursion"
		  (PerlCod "sub odd  { my ($n)=@_; $n == 0 ? 0 : even ($n - 1) }
sub even { my ($n)=@_; $n == 0 ? 1 : odd ($n - 1) }
"(TWO "# oh, Out of memory!")))))

     (slide* 1
	     "Perl can do it better"
	     (ul
	      (li "higher-order functions"
		  (PerlCod "
sub array_map {
    my ($f, $a)=@_;
    [ map { &$f($_) } @$a ]
}

sub square {
    my ($x)= @_;
    $x * $x
}

my $b= array_map *square, $a;
"))))

     (slide* 1
	     "Perl can do it better II"
	     (ul
	      (li "higher-order functions"
		  (PerlCod "use Method::Signatures;

func array_map ($f, $a) {
    [ map { &$f($_) } @$a ]
}

func square ($x) {
    $x * $x
}

my $b= array_map *square, $a;
"))))

     (slide* 3
	     "Perl can do it better III"
	     (ul
	      (li "iteration by recursion"
		  (PerlCod "sub odd  { my ($n)=@_; $n == 0 ? 0 : even ($n - 1) }
sub even { my ($n)=@_; $n == 0 ? 1 : odd ($n - 1) }
odd 137001 "(values "# Out of memory!"))
		  (p "to:")
		  (PerlCod "use Method::Signatures;
use Sub::Call::Tail;"(TWO "
use strict; use warnings; use warnings FATAL => 'uninitialized';") (THREE "
# no stringification;")"

func odd ($n) { $n == 0 ? 0 : tail even ($n - 1) }
func even ($n) { $n == 0 ? 1 : tail odd ($n - 1) }
odd 137001 # -> 1"))))

     ;; mention trampolining? nah (perhaps say it)
     ;; (mention stack trace topic? (trampolines don't solve this anyw))
     ;; XX make TCO switchable? !

     ;; B ------------------------------------
     (slide* 4
	     "Perl can do it already?, cont"
	     (ul
	      (li "local (nested) functions"
		  (PerlCod "func outer ($n) {
    my $inner= func ($n, $tot) {
        $n > 0 ? &$inner($n-1, $tot*$n) : $tot "(TWO "# Global symbol \"$inner\"")"
    };
    &$inner($n, 1);
}"))
	      (THREE
	       (list
		(p "change to:")
		(inner-inner-leaking FOUR false/1)))))

     (slide* 2
	     "Perl can do it with some help"
	     (inner-inner-leaking (show-complement TWO) TWO #t)
	     ;; ^ so big now that need to turn graphic off when shown:
	     ((show-complement TWO)
	      (img/width "closure-refcycle.svg" 50)))

     (slide ".. or with a trick"
	    (p "Fixpoint combinator")
	    (PerlCod "# in FP::fix
func fix ($f) {
    sub {
	tail &$f (fix($f), @_)
    }
}

func outer ($n) {
    my $inner= fix func ($inner, $n, $tot) {
        $n > 0 ? &$inner($n-1, $tot*$n) : $tot
    }; 
    &$inner($n, 1);
}
"))
     ;; not yet showing capturing and inner closure (lazy) issue

     (slide "Combinators"
	    (ul
	     (li (pretty-quotes "\"A combinator is a higher-order function that uses only function application and earlier defined combinators to define a result from its arguments.\"  ")
		 (small
		  (nobr "("(https-link "en.wikipedia.org/wiki/Combinator"))")"))
	     (li
	      "example: function composition"
	      `(table
		(@ (cols 2)
		   (border 0)
		   (cellpadding 8))
		(tr
		 (td (@ (colspan 2))
		     ,(PerlCod "func compose ($f,$g) { sub { &$f (&$g (@_)) } }

func inc ($x) { $x + 1 }
func square ($x) { $x * $x }")))
		(tr
		 (td ,(PerlCod "*squareinc= compose *square, *inc;"))
		 (td ,(PerlCod "# equivalent to
func squareinc ($x) {
    square (inc $x)
}")))))))
   
     (slide "Linked lists and lazy evaluation"
	    (p "Functional list generation:")
	    (PerlCod "repl> $l= [ 2, undef ]
$VAR1 = [ 2, undef ];
repl> $m= [ 1, $l ]
$VAR1 = [ 1, [ 2, undef ] ];
repl> $l
$VAR1 = [ 2, undef ];

repl> (cons 1, cons 2, null) -> array
$VAR1 = [ 1, 2 ];")
	    (p "Haskell:")
	    ;; Cod prefixes a br which we don't want here  erck. todo rg fix
	    (pre "Prelude> 1 : 2 : []
[1,2]"))
   
     (slide "Lazy evaluation"
	    (p "evaluating expressions only when necessary")
	    (PerlCod "repl> $x = lazy { warn \"evaluating!\"; 2*3 }
$VAR1 = bless( .. , 'FP::Lazy::Promise' );
repl> force $x
evaluating! at (eval 104) line 1.
$VAR1 = 6;
repl> force $x
$VAR1 = 6;

repl> $x = lazy { 1 / 0 }
$VAR1 = bless( .. , 'FP::Lazy::Promise' );
repl> force $x
Illegal division by zero at (eval 112) line 1."))
   
     (slide "Haskell style"
	    (Cod "*Main> let ones = 1 : ones
*Main> take 5 ones
[1,1,1,1,1]

*Main> let alternating = True:False:alternating
*Main> take 5 alternating
[True,False,True,False,True]
")
	    (p "Using functional-perl:")
	    (PerlCod "repl> func ones () { my $ones; $ones= lazy { cons 1, $ones };
                              Weakened $ones }
repl> ones->take(5)->array
$VAR1 = [ 1,1,1,1,1 ];
"))

     (slide "Haskell style: lazy sequences"
	    (p "Infinite stream calculated on demand:")
	    (PerlCod "Prelude> let fibs = 1:1:zipWith (+) fibs (tail fibs)
Prelude> take 10 fibs
[1,1,2,3,5,8,13,21,34,55]")
	    (p "Using functional-perl:")
	    (PerlCod "func fibs () {
    my $fibs; $fibs=
      cons 1, cons 1, lazy { stream_zip_with *add, $fibs, rest $fibs };
    $fibs
}
main> fibs->stream_take(10)->array
$VAR1 = [ 1,1,2,3,5,8,13,21,34,55 ];"))

     (slide ""
	    (p "Thanks for listening!")
	    (p "Questions?")
	    (p "Get the code from " (link "https://github.com/pflanze/functional-perl"))
	    (p "and discuss it on " (http-link "functional-perl.org"))))))
