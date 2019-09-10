#lang racket

(require racket/gui map-widget "gpx-reader.rkt")

; based on https://alex-hhh.github.io/2018/06/racket-map-widget.html
; used to generate GPS track of my cycling trip
; gpx file not included! 

(define track (read-gpx-trackpoints (open-input-file "explore.gpx")))
(define toplevel (new frame% [label "Map Demo"] [width 1000] [height 1000]))
(define map (new map-widget% [parent toplevel]))

(send toplevel show #t)
(send map add-track track #f)
(send map resize-to-fit)