#lang racket

(provide bytes-prefix?)

(define (bytes-prefix? p b)
  (and (>= (bytes-length b) (bytes-length p))
       (bytes=? p (subbytes b 0 (bytes-length p)))))