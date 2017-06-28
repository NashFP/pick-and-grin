#lang racket

(provide (struct-out bin)
         str-to-bin)

(struct bin (warehouse room bay shelf position size) #:transparent)

(define (str-to-bin s)
  (match (regexp-match #px"W(\\d+)-R(\\d+)-B(\\d+)-S(\\d+)-([A-Z0-9]+)-([SL])" s)
    [#f #f]
    [(list _ warehouse room bay shelf position size) (bin warehouse room bay shelf position size)]))

