#lang racket

(require "bin.rkt")
(define product-bins-file "../data/product-bins.tsv")
(define order-file "challenge-2-order.txt")

; make a map from product ids -> bins w qtys
(define product-to-bins-map 
  (foldl (lambda (cur acc)
           (match-let* ([(list bin-id product-id qty-str) cur]
                        [qty (string->number qty-str)])
             (if (hash-has-key? acc product-id)
               (hash-update acc
                            product-id
                            (lambda (v) (cons (list bin-id qty) v)))
               (hash-set acc
                         product-id
                         (list (list bin-id qty))))))
         (hash)
         (map (lambda (l) (string-split l "\t"))
              (file->lines product-bins-file))))

(define order
  (map (lambda (l)
         (match (string-split l ", ")
           [(list product-id qty) (list product-id (string->number qty))]))
       (file->lines order-file)))

; pick a single item from the largest bin to the smallest
(define (bins-for-item item)
  (sort (hash-ref product-to-bins-map item) > #:key second))

(define (pick-item item qty bins)
  (let* ([bin (first bins)]
         [qty-in-bin (second bin)]
         [bin-id (first bin)])
    (if (>= qty-in-bin qty)
      (list (list bin-id item qty (- qty-in-bin qty)))
      (cons (list bin-id item qty-in-bin 0) (pick-item item (- qty qty-in-bin) (rest bins))))))

(define (plan-for-order order)
  (sort
    (apply append
           (map
             (match-lambda [(list item qty) (pick-item item qty (bins-for-item item))])
             order))
    string<?
    #:key first))

(define plan (plan-for-order order))

; -----------------------------------

; ## Difficulties
; 
; | Cost in seconds | Description |
; |----------------|--------------|
; | 600 | base cost for picking |
; | 1800 | multiple warehouses |
; | 60 | move from a room to another room |
; | 300 | picking from shelf 3 (tow motor) |
; | 600 | picking from shelf 4 (tow motor and closes bay with cones) |
; | 30 | moving to each small bin |
; | 120 | moving to each large bin |

(define (score-for-plan plan)
  (let* ([bin-strs (map first plan)]
         [bins (map str-to-bin bin-strs)])
    (+ 600 ; base cost for picking
       60  ; transition to first room
       (score-for-transitions (first bins) (rest bins))
       (apply + (map score-for-bin bins))))) 



(define (score-for-transitions first-bin xs)
  (if (empty? xs)
    0
    (+ (score-for-transition first-bin (first xs)) (score-for-transitions (first xs) (rest xs)))))

(define (score-for-transition first-bin second-bin)
  (let* ([same-warehouse? (string=? (bin-warehouse first-bin) (bin-warehouse second-bin))]
         [same-room? (and same-warehouse? (string=? (bin-room first-bin) (bin-room second-bin)))])
    (+ (if same-warehouse? 0 1800)
       (if same-room? 0 60))))


(define (score-for-bin bin)
  (+ (score-for-bin-size bin)
     (score-for-high-shelves bin)))

(define (score-for-bin-size bin)
  (if (string=? "L" (bin-size bin)) 120 30))

(define (score-for-high-shelves bin)
  (match (bin-shelf bin)
    [4 400]
    [3 300]
    [_ 0]))

(score-for-plan plan)

; ------------------------

(define (format-plan plan)
  (append
    (list "| Bin | Product | To Pick | Remaining |"
          "| --- | ------- | ------- | --------- |")
    (map (lambda (pick) (string-append "| " (string-join (map ~a pick) " | ") " |")) plan)
    (list "" (string-append "Picking time: " (~a (score-for-plan plan))) "")))

(display (string-join (format-plan plan) "\n"))

