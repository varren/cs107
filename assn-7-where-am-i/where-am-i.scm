;; The Where-Am-I helper functions:
;; originally written by Nick Parlante

;;
;;  the 2-D POINT type  (x and y coordinates)
;;  impelemented as a list length 2
;;
;;  the CIRCLE type (a radius and a center point)
;;  implemented as a list length 2-- first element is the radius and
;;  the second is the center point
;;
;;  For convenience, I do not insist that you treat these as ADT's-
;;  so if you want to use CAR to get the x coordinate, or build you own
;;  circles without going through MAKE-CIRCLE that will be ok.
;; 
;; POINT functions:
;;  make-pt   create a new point
;;  x         get the x coordinate of a point
;;  y         get the y coordinate of a point
;;  dist      return the distance between two points
;;
;; CIRCLE functions
;;  make-circle   create a new circle
;;  radius        get the radius of a circle
;;  center        get the center of a circle
;;  intersect     given two circles, returns a list of the points
;;                of intersection for those circles.
;;                For the purposes of this program I have
;;                bastardized the definition of 'intersect' a little
;;                to give better results when the measurements are
;;                inexact.  Don't worry about that, just use the points
;;                returned.  Someone who is interested in Math or Geometry
;;                might be interested to see how I compute the intersection.

(define (make-pt x y) 
  (list x y))

(define (x pt) 
  (car pt))

(define (y pt) 
  (cadr pt))

(define (dist pt1 pt2) 
  (let ((dx (- (x pt1) (x pt2)))
        (dy (- (y pt1) (y pt2))))
    (sqrt (+ (* dx dx) (* dy dy)))))

;;
;; 2D vector operations - used by the intersection function
;; vectors are a lot like points.  You won't need these.
;; 

(define (add v1 v2)
  (list (+ (car v1) (car v2))
	(+ (cadr v1) (cadr v2))))

(define (sub v1 v2)
  (list (- (car v1) (car v2))
	(- (cadr v1) (cadr v2))))

(define (len v)
  (sqrt (+ (* (car v) (car v))
	   (* (cadr v) (cadr v)))))

(define (scale v factor)
  (list (* (car v) factor) 
	(* (cadr v) factor)))

(define (normalize v)
  (scale (list (- (cadr v)) (car v)) (/ (len v))))


(define (make-circle radius center) 
  (list radius center))

(define (radius circle) 
  (car circle))

(define (center circle) 
  (cadr circle))

;;
;; Function: intersect
;; -------------------
;; Return a list of the points of intersection of the two circles.
;; The circles may not have the same center point
;;

(define (intersect circle1 circle2)
  (if (equal? (center circle1) (center circle2))
      (error "Intersect cannont handle circles with the same center point.")
      (let* ((c1 (center circle1))
	     (r1 (radius circle1))
	     (c2 (center circle2))
	     (r2 (radius circle2))
	     (d (dist c1 c2)))
      ;; first check to see if the circles are too far apart to intersect,
      ;; or if one circle is within another.
	(if (or (> d (+ r1 r2)) (> r1 (+ d r2)) (> r2 (+ d r1)))
	    ;; if there is no real intersection, use the closest tangent points on each
	    ;; circle.  This is the bastardization above.
	    (list (add c1 (scale (sub c2 c1) (/ r1 d)))  ;; c1-> towards c2
		  (add c2 (scale (sub c1 c2) (/ r2 d)))) ;; c2-> towards c1
    ;;otherwise the circles intersect normally, and I did some hairy
    ;;geometry to show that the following computes the two points
    ;;of intersection.
    (let* ((r12 (* r1 r1))
           (r22 (* r2 r2))
           (d2 (* d d))
           (d1 (/ (+ r12 (- r22) d2) 2 d))
           (h (sqrt (- r12 (* d1 d1))))
           (towards (scale (sub c2 c1) (/ d1 d))) ;;vector c1->c2
           (perp (scale (normalize towards) h)))
      (list (add c1 (add towards perp))
            (add c1 (add towards (scale perp -1)))))))))

;;
;; Function: prefix-of-list
;; ------------------------
;; Accepts the incoming list and returns one
;; with the same first k elements and nothing more.
;;

(define (prefix-of-list ls k)
  (if (or (zero? k) (null? ls)) '()
      (cons (car ls) (prefix-of-list (cdr ls) (- k 1)))))

;;
;; Function: partition
;; -------------------
;; Takes a pivot and a list and produces a pair two lists.
;; The first of the two lists contains all of those element less than the 
;; pivot, and the second contains everything else.  Notice that
;; the first list pair every produced is (() ()), and as the
;; recursion unwinds exactly one of the two lists gets a new element
;; cons'ed to the front of it.  
;; 

(define (partition pivot num-list cmp)
  (if (null? num-list) '(() ())
      (let ((split-of-rest (partition pivot (cdr num-list) cmp)))
	(if (cmp (car num-list) pivot)
	    (list (cons (car num-list) (car split-of-rest)) (cadr split-of-rest))
	    (list (car split-of-rest) (cons (car num-list) (car (cdr split-of-rest))))))))

;;
;; Function: quicksort
;; -------------------
;; Implements the quicksort algorithm to sort lists of numbers from
;; high to low.  If a list is of length 0 or 1, then it is trivially
;; sorted.  Otherwise, we partition to cdr of the list around the car
;; to generate two lists: those in the cdr that are smaller than the car,
;; and those in the cdr that are greater than or equal to the car.  
;; We then recursively quicksort the two lists, and then splice everything
;; together in the proper order.
;;

(define (quicksort num-list cmp)
  (if (<= (length num-list) 1) num-list
      (let ((split (partition (car num-list) (cdr num-list) cmp)))
	(append (quicksort (car split) cmp) 
		(list (car num-list)) 
		(quicksort (cadr split) cmp)))))

;;
;; Function: remove
;; ----------------
;; Generates a copy of the specified list, except that all
;; instances that match the specified elem in the equal? sense
;; are excluded.
;;

(define (remove elem ls)
  (cond ((null? ls) '())
	((equal? (car ls) elem) (remove elem (cdr ls)))
	(else (cons (car ls) (remove elem (cdr ls))))))
                  
;; 
;; Function: all-guesses
;; ---------------------
;; Given a list of distances and a list of stars, return a list of all
;; the possible guesses.  A single guess is a list of circles which pairs
;; each distance with one of the stars.
;; 

(define (all-guesses distances stars)
  (if (or (null? distances) (null? stars)) '(())
      (apply append 
	     (map (lambda (star)
		    (map (lambda (pair) 
			   (cons (list (car distances) star) pair))
			 (all-guesses (cdr distances) (remove star stars))
			 )
		    )
		  stars))))

(define *distances-1* '(2.65 5.55 5.25))
(define *stars-1* '((0 0) (4 6) (10 0) (7 4) (12 5)))

(define *distances-2* '(2.5 11.65 7.75))
(define *stars-2* '((0 0) (4 4) (10 0)))


;; 
;; Function: intersection-points
;; ---------------------
;; Takes a list of circles and returns a list of all the points where the circles intersect. 
;; The list of points may contain duplicates. 
;; 
;; #|kawa:5|# (intersection-points '((1 (0 0)) (1 (1 0))))
;;     ((0.5 0.8660254037844386) (0.5 -0.8660254037844386))
;; #|kawa:6|# (intersection-points '((1 (0 0)) (1 (1 0)) (1 (1 1))))
;;     ((0.5 0.8660254037844386) (0.5 -0.8660254037844386)
;;     (2.7755575615628914E-16 1.0) (1.0 2.7755575615628914E-16)
;;     (0.1339745962155614 0.5) (1.8660254037844386 0.5))
;;

(define (intersection-points circles-list)
  (if (or (null? circles-list) 
	  (null? (cdr circles-list))) '()
	  (append (apply append 
			 (map (lambda (value)(intersect (car circles-list) value)) 
			      (cdr circles-list)))
		  (intersection-points (cdr circles-list)))))

;; 
;; Function: distance-product 
;; ---------------------
;; Takes a point and a list of points and returns the product of the 
;; distances between that point and all the points in the list.
;; The point itself may be in the list. In that case, it should be removed so that it doesn't
;; force the product to be zero. Use the dist function provided as part of the point
;; type. You may assume the list contains at least two different points
;; 
;; #|kawa:7|# (distance-product '(2 0) '((0 0) (2 0) (6 0)))
;;     8.0
;; #|kawa:8|# (distance-product '(3 3) '((2 5) (7 8) (10 1) (3 2)))
;;     104.23531071570709
;;

(define (distance-product point list-of-points)
  (apply * (map (lambda(value)(dist point value)) 
		(remove point list-of-points))))

;; 
;; Function: rate-points
;; ---------------------
;; Takes a list of points and returns a list where each point is annotated to show its distance-product
;; from the other points. So the point (2 0) in the above example gets replaced by (8 (2 0)).
;; 
;; #|kawa:9|# (rate-points '((0 0) (2 0) (6 0)))
;;     ((12.0 (0 0)) (8.0 (2 0)) (24.0 (6 0)))
;; #|kawa:10|# (rate-points '((2 5) (7 8) (10 1) (3 2)))
;;     ((164.92422502470643 (2 5)) (320.22492095400696 (7 8))
;;     (481.66378315169186 (10 1)) (161.24515496597098 (3 2)))
;;

(define (rate-points ls)
  (map (lambda(value)(list (distance-product value ls) value)) ls))

;; 
;; Function: sort-points
;; ---------------------
;; 
;; Takes a list of rated points, and sorts them in ascending order of rating
;; 
;; #|kawa:11|# (sort-points (rate-points '((2 5) (7 8) (10 1) (3 2))))
;;     ((161.24515496597098 (3 2)) (164.92422502470643 (2 5))
;;     (320.22492095400696 (7 8)) (481.66378315169186 (10 1)))
;; #|kawa:12|# (sort-points (rate-points '((0 0) (2 0) (6 0))))
;;     ((8.0 (2 0)) (12.0 (0 0)) (24.0 (6 0)))
;;

(define (sort-points ls)
  (quicksort ls (lambda(one two)(< (car one) (car two)))))

;; 
;; Function: clumped-points
;; ---------------------
;;
;; Takes a list of points, rates
;; them, sorts them, and then returns the half of the points with the smallest ratings.
;; clumped-points should return the points without the ratings.
;; 
;; #|kawa:12|# (clumped-points '((0 0) (2 0) (6 0)))
;;      ((2 0))
;; #|kawa:13|# (clumped-points '((0 0) (2 0) (6 0) (1 0)))
;;      ((1 0) (2 0))
;;

(define (clumped-points ls) 
  (apply append (map cdr (prefix-of-list (sort-points (rate-points ls)) 
					 (quotient (length ls) 2)))))

;; 
;; Function: average-point
;; ---------------------
;; 
;; Take a list of points and averages them all down to a single
;; point. The average point is obtained by averaging all the x values to get an x value
;; and all the y values to get a y value. average-point should also include the distance
;; rating indicating how far the average point was from all the points
;;
;; #|kawa:14|# (average-point '((0 0) (2 0) (6 0)))
;;     (5.925925925925926 (8/3 0))
;; #|kawa:15|# (average-point '((0 0) (2 0) (6 0) (1 0) (5 4) (4 5)))
;;     (590.8865213418864 (3 3/2))
;; 
;;

(define (average-point ls)
  (let ((avg-point
	 (list (/ (apply + (map radius ls)) (length ls))
	       (/ (apply + (map center ls)) (length ls)))))
    (list (distance-product avg-point ls) avg-point)))

;; 
;; Function: best-estimate
;; ---------------------
;; Takes a guess (a list of
;; circles), computes all the points of intersection, winnows those points down to those
;; which are most clumped, and returns their average point.
;;
;; #|kawa:16|# (best-estimate '((1 (0 0)) (1 (2 0)) (0.1 (1 0))))
;;     (5.942527670663184E-4 (1.0016666666666667 0.033291640592396886))
;;

(define (best-estimate ls)
 (average-point (clumped-points (intersection-points ls))))

;; 
;; Function: where-am-i
;; ---------------------
;;
;; Compute all the possible guesses, use best-estimate to get an answer out of
;; each one, and sort the estimates in increasing order of distance rating. The result is a
;; list of rated points.
;;
;; #|kawa:17|# (where-am-i '(2.5 11.65 7.75) '((0 0) (4 4) (10 0)))
;;     ((5.164102748844367E-6 (11.481441859657613 2.001220110464802))
;;     (0.3394092159986836 (-1.8429290506186957 -1.216560811506545))
;;     (0.6676116235553851 (7.76704142138513 0.4622501635210244))
;;     (0.7871787994250546 (2.128838984322123 0.5892556509887895))
;;     (4.398427430402362 (3.9811875000000003 6.126803974552016))
;;     (45.38616651704703 (4.326820849071189 4.1540809322972985))) 
;;

(define (where-am-i distances stars)
 (sort-points
  (map  best-estimate 
	(all-guesses distances stars))))
