#lang racket/base
(provide (struct-out point))
(struct point (x y) #:transparent)