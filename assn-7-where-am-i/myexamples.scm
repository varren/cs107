;;
;; Function: celsius->fahrenheit
;; -----------------------------
;; Simple conversion function to bring a Celsius
;; degree amount into Fahrenheit.
;;

(define (celsius->farenheit celsius)
  (+ (* 1.8 celsius) 32))

;; Predicate function: leap-year?
;; ------------------------------
;; Illustrates the use of the 'or, 'and, and 'not
;; special forms. The question mark after the
;; function name isn't required, it's just customary
;; to include a question mark at the end of a
;; function that returns a true or false.
;;
;; A year is a leap year if it's divisible by 400, or
;; if it's divisible by 4 but not by 100.
;;
(define(leap-year? year)
  (or (and (zero? (remainder year 4))
	   (not (zero? (remainder year 100))))
      (zero? (remainder year 100) )))      
;;
;; Function: factorial
;; -------------------
;; Traditional recursive formulation of the most obvious recursive
;; function ever. Note the use of the built-in zero?
;; to check to see if we have a base case.
;;
;; What's more impressive about this function is that it demonstrates
;; how Scheme can represent arbitrarily large integers. Type
;; in (factorial 1000) and see what you get. Try doing *that* with
;; C or Java.
;;
(define (factorial number)
  (if (zero? number) 1
      (* number (factorial (- number 1)))))

;;
;; Function: fibonacci
;; -------------------
;; Traditional recursive implementation of
;; the fibonacci function. This particular
;; implementation is pretty inefficient, since
;; it makes an exponential number of recursive
;; calls.
;;
(define (fibonacci n)
  (if (< n 2) n
      (+ (fibonacci(- n 1)) (fibonacci(- n 2)))))
;;
;; Function: fast-fibonacci
;; ------------------------
;; Relies on the services of a helper function to
;; generate the nth fibonacci number much more quickly. The
;; key observation here: the nth number is the Fibonacci
;; sequence starting out 0, 1, 1, 2, 3, 5, 8 is the (n-1)th
;; number in the Fibonacci-like sequence starting out with
;; 1, 1, 2, 3, 5, 8. The recursion basically slides down
;; the sequence n or so times in order to compute the answer.
;; As a result, the recursion is linear instead of binary, and it
;; runs as quickly as factorial does.
;;

(define (fast-fibonacci-helper n base-0 base-1)
  (if (zero? n) base-0  
      (fast-fibonacci-helper (- n 1) base-1 (+ base-0 base-1) )))


(define (fast-fibonacci n)
  (fast-fibonacci-helper n 0 1))

; Function: sum
; -------------
; Computes the sum of all of the numbers in the specified
; number list. If the list is empty, then the sum is 0.
; Otherwise, the sum is equal to the value of the car plus
; the sum of whatever the cdr holds.
;;

(define (sum ls)
  (if (null? ls) 0
      (+ (car ls) (sum (cdr ls)))))
;;
;; Function: triple-everything
;; ---------------------------
;; Takes a list of integers (identified by sequence)
;; and generates a copy of the list, except that
;; every integer in the new list has been tripled.
;;

(define (triple-everything ls)
  (if (null? ls) '()
      (cons (* (car ls) 3) (triple-everything (cdr ls)))))
;; Function: generate-partial-concatenations
;; -----------------------------------------
;; Takes a list of strings and generates a new list of the
;; same length, where the nth element of the new list is
;; the running concatenation of the original list's first
;; n elements.
;;
;; It takes '("a" "b" "c") and generates ("a" "ab" "acb").
;; It takes '("CS" "107" "L") and generates ("CS" "CS107" "CS107L").
;;
;; This particular implementation relies on a helper function,
;; just like fast-fibonacci does. The helper procedure not
;; only tracks what portion of the list remains to be seen, but
;; the accumulation of all strings seen so far as well.
;;
(define(gpc-helper ls currElem)
  (if (null? ls) '()
      (cons (string-append currElem (car ls)) 
	    (gpc-helper (cdr ls) (string-append currElem (car ls))))))  

(define  (generate-partial-concatenations ls)
     (gpc-helper ls ""))


;;
;; Function: power
;; ---------------
;; Assumes that exponent is a non-negative integer. This
;; particular implemnentation is the realization of the following
;; inductive definition (all divisions are integer divisions)
;;
;; n^m = 1 if m is 0
;; = (n^(m/2))^2 if m is even
;; = n * (n^(m/2))^2 if m is odd
;;
(define (power base exp)
  (cond ((zero? exp) 1)
	((zero? (remainder exp 2))
	 (* (power base (quotient exp 2)) 
	    (power base (quotient exp 2))))
	(else (* base 
		 (power base (quotient exp 2)) 
		 (power base (quotient exp 2))))))

;;
;; Function: pwr
;; -------------
;; Functionally identical to the implementation of power, except
;; that pwr uses a let expression to bind a local symbol called root
;; to the result of the recursive call.
;;

(define (pwr base exp)
  (if (zero? exp) 1
      (let ((root (pwr base (quotient exp 2))))
	(if(zero? (remainder exp 2)) 
	   (* root root)
	   (* base root root)))))
;;
;; Function: flatten
;; -----------------
;; Takes an arbitrary list and generates a another list where all atoms of the
;; original are laid down in order as top level elements.
;;
;; In order for the entire list to be flattened, the cdr of the
;; list needs to be flattened. If the car of the entire list is a primitive
;; (number, string, character, whatever), then all we need to do is
;; cons that primitive onto the front of the recursively flattened cdr.
;; If the car is itself a list, then it also needs to be flattened.
;; The flattened cdr then gets appended to the flattened car.
;;
(define (flatten ls)
  (cond ((null? ls) '())
	((list? (car ls)) (append (flatten(car ls)) 
				  (flatten (cdr ls))))
	(else (cons (car ls) (flatten (cdr ls)) ))))

;;
;; Function: partition
;; -------------------
;; Takes a pivot and a list and produces a pair two lists.
;; The first of the two lists contains all of those element less than the
;; pivot, and the second contains everything else. Notice that
;; the first list pair every produced is (() ()), and as the
;; recursion unwinds exactly one of the two lists gets a new element
;; cons'ed to the front of it.
;;
(define (partition pivot ls)
  (if(null? ls)'(()())
     (let ((split (partition pivot (cdr ls))))
       (if (< (car ls) pivot)
	   (list (cons (car ls) (car split))
		 (cadr split))
	   (list (car split) 
		 (cons (car ls)(car(cdr split))))))))
;;
;; Function: quicksort
;; -------------------
;; Implements the quicksort algorithm to sort lists of numbers from
;; high to low. If a list is of length 0 or 1, then it is trivially
;; sorted. Otherwise, we partition to cdr of the list around the car
;; to generate two lists: those in the cdr that are smaller than the car,
;; and those in the cdr that are greater than or equal to the car.
;; We then recursively quicksort the two lists, and then splice everything
;; together in the proper order.
;;
(define (quicksort ls)
  (if (<= (length ls) 1) ls
      (let ((split (partition (car ls) (cdr ls))))
	(append (quicksort (car split)) ;; recursively sort first half
		(list (car ls)) ;; package pivot as a list
		(quicksort (cadr split)))))) ;; recursively sort second half
;;
;; Function: sorted?
;; -----------------
;; Returns true if and only if the specified list of numbers is sorted
;; from low to high. In other words, it confirms that all neighboring
;; pairs of integers respect the <= predicate.
;;

(define (sorted? ls)
  (or (< (length ls) 2)
      (and (<= (car ls) (cadr ls))
	   (sorted? (cdr ls)))))

;;
;; Function: sorted?
;; -----------------
;; Returns true if and only if the specified list is sorted
;; according to the specified predicate function. In other words,
;; true is returned if and only if each neighboring pair respects
;; the provided comparison function.
;;
(define (isSorted? ls cmpFn)
  (or (< (length ls) 2)
      (and (cmpFn (car ls) (cadr ls))
	   (isSorted? (cdr ls) cmpFn))))

;;
;; Function: merge
;; ---------------
;; Takes the two lists, each of which is assumed to be sorted
;; according to the specified comparator function, and synthesizes
;; an fresh list which is the sorted merge of the incoming two.
;;
;; If one of the lists is empty, then merge can just return the
;; other one. If not, then the specified comp is used to determine
;; which of the two cars deserves to be at the front. Recursion (what else?)
;; is then used to generate the merge of everything else, and the winning
;; car is consed to the front of it.
;;
(define (merge ls1 ls2 cmpFn)
  (cond ((null? ls1) ls2)
	((null? ls2) ls1)
	((cmpFn (car ls1) (car ls2))
	 (cons (car ls1) (merge (cdr ls1) ls2 cmpFn)))
	(else 
	 (cons (car ls2) (merge  ls1 (cdr ls2) cmpFn)))))

;;
;; Function: prefix-of-list
;; ------------------------
;; Accepts a list and returns a new list with just the
;; first k elements. If k is greater than the original
;; list length, the entire list is replicated. If k is
;; negative, then don't except it to work. :)
;;

(define (prefix-of-list ls k)
  (if(or (null? ls)(zero? k))'()
     (cons (car ls) (prefix-of-list (cdr ls) (- k 1)))))

;;
;; Function: mergesort
;; -------------------
;; Sorts the incoming list called ls so that all neighboring
;; pairs of the final list respect the specified comparator function.
;;
;; mergesort works by taking the unsorted list, generating copies of
;; the front half and the back half, recursively sorting them, and then
;; merging the two. Classic mergesort.
;;
;; The reverse call is a bit hokey, but it brings the back half to
;; the front so that our prefix-of-list function has access to the
;; back-end elements. The fact that the elements are in the reverse
;; of the original order is immaterial, since we don't care about
;; the original order.just the order after it's been sorted.
;;

(define (mergesort ls comp)
  (if (<= (length ls) 1) ls
      (let ((front-length (quotient (length ls) 2))
	    (back-length (- (length ls) (quotient (length ls) 2))))
	(merge (mergesort (prefix-of-list ls front-length) comp)
	       (mergesort (prefix-of-list (reverse ls) back-length) comp)
	       comp))))


;; Function: distance-from-origin
;; ------------------------------
;; Returns the Euclidean distance of the specified
;; two-dimensional point (expressed as a list of
;; two numbers) from the origin. Thank you, Pythagorean Theorem.
;;
(define (distance-from-origin point)
  (sqrt (+ (* (car point) (car point))
	   (* (cadr point) (cadr point)))))

;;
;; Function: distance-from-origin<?
;; --------------------------------
;; Returns true if and only if the first point
;; is strictly closer to the origin that the second
;; one.
;;
(define (distance-from-origin<? point1 point2)
  (< (distance-from-origin point1) 
     (distance-from-origin point2)))

;;
;; Function: unary-map
;; -------------------
;; We pretend that the map function doesn't exist, and we write
;; our own. As you can see, it isn't all that difficult to get
;; a unary version of map working.
;;

(define (unary-map fn ls)
  (if (null? ls) '()
      (cons (fn (car ls))(unary-map fn (cdr ls)))))
;;
;; Function: average
;; -----------------
;; Quick, clean way to compute the average of a set of numbers without
;; using any exposed car-cdr recursion. This is the canonical example
;; illustrating why apply belongs in a functional language.
;;
(define (average ls)
  (/ (apply + ls) (length ls)))


;;
;; Function: depth
;; ---------------
;; Computes the depth of a list, where depth is understood
;; to be the largest number of open left parentheses to the left
;; of some primitive. We assume that () doesn't appear anywhere
;; in the overall list.
;;
(define (depth ls)
  (if (or (not (list? ls)) (null? ls)) 0
      (+ 1 (apply max (map depth ls)))))  


;;
;; Function: flatten-list
;; ----------------------
;; Flattens a list just like the original flatten does, but
;; it uses map, apply, and append instead of exposed car-cdr recursion.
;;

(define (flatten-list ls)
  (cond ((null? ls) '())
	((not(list? ls)) (list ls))
	(else (apply append (map flatten-list ls)))))

;;
;; Function: translate
;; -------------------
;; Takes the specified list and the specified delta and generates
;; a new list where every element of the original is shifted by the
;; specified delta.
;;
(define (translate ls delta)
  (define (shift number)
    (+ number delta))
  (map shift ls)) 


;;
;; Function: translate
;; -------------------
;; Takes the specified list and the specified delta and generates
;; a new list where every element of the original is shifted by the
;; specified delta. This version uses the lambda construct
;; to define a nameless function in place.
;;

(define (lambda-translate ls delta)
  (map (lambda (num) (+ num delta)) ls))

;;
;; Function: power-set
;; ------------------
;; The power set of a set is the set of all its subsets.
;; The key recursive breakdown is:
;;
;; The power set of {} is {{}}. That's because the empty
;; set is a subset of itself.
;; The power set of a non-empty set A with first element a is
;; equal to the concatenation of two sets:
;; - the first set is the power set of A - {a}. This
;; recursively gives us all those subsets of A that
;; exclude a.
;; - the second set is once again the power set of A - {a},
;; except that a has been prepended aka consed to the
;; front of every subset.
;;
(define (power-set ls)
  (if (null? ls) '(())
      (let ((power-set-rest (power-set (cdr ls))))
	(append power-set-rest 
	      (map (lambda(value)(cons (car ls) value))
		   power-set-rest)))))


				 
;;
;; Function: remove
;; ----------------
;; Generates a copy of the incoming list, except that
;; all elements that match the specified element in the equal?
;; sense are excluded.
;;

(define (remove ls elem)
  (cond ((null? ls) '())
	((equal? (car ls) elem) (remove (cdr ls) elem))
	(else (cons (car ls) (remove (cdr ls) elem)))))                                                              				  
;;
;; Function: permutations
;; ----------------------
;; Generates all of the permutations of the specified list, operating
;; on the understanding that each of the n elements appears as the first
;; element of 1/n of the permutations. The best approach uses mapping
;; to generate n different sets, where each of these sets are those
;; permutations with the nth element at the front. We use map to transform
;; each element x into the subset of permutations that have x at the
;; front. The mapping function that DOES that transformation is itself
;; a call to map, which manages to map an anonymous cons-ing routine
;; over all of the permutations of the list without x. This is
;; as dense as it gets.
;;
(define (premutations ls)
  (if (null? ls ) '(())
      (apply append 
	     (map (lambda (value)
		    (map (lambda (premutation) (cons value premutation))
			 (premutations (remove ls value))))
		    ls))))


;; Function: k-subsets
;; -------------------
;; k-subsets constructs a list of all those subsets
;; of the specified set whose size just happens to equal k.
;;
;; Examples: (k-subsets '(1 2 3 4) 2) -> ((1 2) (1 3) (1 4) (2 3) (2 4) (3 4))
;; (k-subsets '(1 2 3 4 5 6) 1) -> ((1) (2) (3) (4) (5) (6))
;; (k-subsets '(a b c d) 0) -> (())
;; (k-subsets '(a b d d) 5) -> ()
(define (k-subsets set k)
  (cond ((eq? (length set) k) (list set))
	((zero? k) '(()) )
	((or (negative? k)(> k (length set))) '())
	(else (let ((k-1subset-rest (k-subsets (cdr set) (- k 1)))
		    (k-subset-rest (k-subsets (cdr set) k)))
		(append 
		 (map (lambda(value)(cons (car set) value ))
		      k-1subset-rest)
		 k-subset-rest)))))
		
;; Function: is-up-down?
;; ---------------------
;; Returns true if and only if the specified list is an up-down list
;; according to the specified predicate.
;;
;; Examples: (is-up-down? '() <) -> #t
;; (is-up-down? '(1) <) -> #t
;; (is-up-down? '(1 2 2 3) <) -> #f
;; (is-up-down? '(1 6 2 4 3 5) <) -> #f
;; (is-up-down? '(1 6 2 4 3 5) >) -> #f ;; down-up, but not up-down
;; (is-up-down? '(4 8 3 5 1 7 6 2) <) -> #f
(define (is-up-down? list comp)
  (or (null? list) 
      (null? (cdr list))
      (and (comp (car list) (cadr list))
	   (is-up-down? (cdr list) 
			(lambda(one two)(comp two one))))))

;; Function: up-down-permute
;; --------------------------
;; up-down-permute generates all those permutations of a list that
;; just happen to be up-down permutations.
;;
;; Examples: (remove 3 '(1 2 3 4 5 4 3 2 1)) -> (1 2 4 5 4 2 1)
;; (up-down-permute '()) -> (())
;; (up-down-permute '(1)) -> ((1))
;; (up-down-permute '(1 2)) -> ((1 2))
;; (up-down-permute '(1 2 3)) -> ((1 3 2) (2 3 1))
;; (up-down-permute '(1 2 3 4 5)) ->
;; ((1 3 2 5 4) (1 4 2 5 3) (1 4 3 5 2) (1 5 2 4 3) (1 5 3 4 2)
;; (2 3 1 5 4) (2 4 1 5 3) (2 4 3 5 1) (2 5 1 4 3) (2 5 3 4 1)
;; (3 4 1 5 2) (3 4 2 5 1) (3 5 1 4 2) (3 5 2 4 1)
;; (4 5 1 3 2) (4 5 2 3 1))

(define (gen-permuataions num-list cmp permute)
  (lambda (value)
    (apply append
	   (map (lambda (premutation) 
		  (if (cmp value (car premutation))
		      (list (cons value premutation))
		      '()))
		(permute (remove num-list value))))))

(define (up-down-permute num-list)
(if (<= (length num-list) 1)(list num-list)
     (apply append 
	    (map (gen-permuataions num-list < down-up-permute) num-list)))) 

(define (down-up-permute num-list)
  (if (<= (length num-list) 1)(list num-list)
     (apply append 
	    (map (gen-permuataions num-list > up-down-permute) num-list))))


;; 