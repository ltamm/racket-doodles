#lang racket

(require 2htdp/image)
(require 2htdp/universe)

; Set up UI
(define WIDTH 500)
(define HEIGHT 500)

(define BACKDROP (rectangle WIDTH HEIGHT "solid" "goldenrod"))
(define CACTUS-IMG (bitmap/file (string->path "cactus.png")))
(define DIRT-IMG (bitmap/file (string->path "dirt.png")))

; Set up cactus 
(struct cactus (x-pos y-pos))
(define init-cactus (cactus (/ WIDTH 2) (/ HEIGHT 2)))

; Set up world
(struct world (cactus))
(define init-world (world init-cactus))


; Draw function
(define (render world)
  (let ([cactus (world-cactus world)])
  (place-image CACTUS-IMG
               (cactus-x-pos cactus)
               (cactus-y-pos cactus)
               BACKDROP)))


; Run the world!
(define (main w)
  (big-bang w
    (to-draw render)))

;(main init-world)