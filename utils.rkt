#lang racket

(provide bytes-prefix?
         bytes-contains?)

(define (bytes-prefix? p b)
  (and (>= (bytes-length b) (bytes-length p))
       (bytes=? p (subbytes b 0 (bytes-length p)))))

(define (bytes-contains? haystack needle)
  (if (in-bytes needle haystack)
      #t
      #f))