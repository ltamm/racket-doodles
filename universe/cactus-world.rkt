#lang racket

(require 2htdp/image)
(require 2htdp/universe)

; Set up grid
(define TILE-SIDE-IN-PIXELS 128)

(struct tile-coord (x-pos y-pos))
(struct pixel-coord (x-pos y-pos))

; tile-coord -> pixel-coord
(define (tiles->pixels number-of-tiles)
  (* TILE-SIDE-IN-PIXELS number-of-tiles))
         
(define (tile-coord->pixel-coord tile-coord)
  (pixel-coord
   (tiles->pixels (tile-coord-x-pos tile-coord))
   (tiles->pixels (tile-coord-y-pos tile-coord))))


; Set up UI
(define CANVAS-WIDTH 3) ; in tiles
(define CANVAS-HEIGHT 3) ; in tiles

(define BACKDROP
  (rectangle (tiles->pixels CANVAS-WIDTH)
             (tiles->pixels CANVAS-HEIGHT)
             "solid" "goldenrod"))

(define CACTUS-IMG (bitmap/file (string->path "cactus.png")))
(define DIRT-IMG (bitmap/file (string->path "dirt.png")))

; Set up cactus
; x and y pos are in tiles
(struct cactus (tile-coord))
(define init-cactus (cactus (tile-coord 1 1)))

; Set up world
(struct world (cactus))
(define init-world (world init-cactus))


; Draw functions
; image, image, tile-coord -> image
(define (place-image-center-tile foreground background tile-coord)
  (let* ([half-tile (/ TILE-SIDE-IN-PIXELS 2)]
         [pixel-coord (tile-coord->pixel-coord tile-coord)]
         [x (+ half-tile (pixel-coord-x-pos pixel-coord))]
         [y (+ half-tile (pixel-coord-y-pos pixel-coord))])
    (place-image foreground x y background)))


(define (render world)
  (let ([cactus (world-cactus world)])
  (place-image-center-tile CACTUS-IMG BACKDROP (cactus-tile-coord cactus))))


; Run the world!
(define (main w)
  (big-bang w
    (to-draw render)))

(main init-world)