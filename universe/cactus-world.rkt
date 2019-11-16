#lang racket

(require 2htdp/image)
(require 2htdp/universe)

; Physics stuff
(define INITIAL-VELOCITY -10)
(define GRAVITY 0.75)

; Set up references to tiles
(define CACTUS-IMG (bitmap/file (string->path "cactus.png")))
(define DIRT-IMG (bitmap/file (string->path "dirt.png")))

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

; Draw functions
; image, image, tile-coord -> image
(define (place-image-center-tile foreground background tile-coord)
  (let* ([half-tile (/ TILE-SIDE-IN-PIXELS 2)]
         [pixel-coord (tile-coord->pixel-coord tile-coord)]
         [x (+ half-tile (pixel-coord-x-pos pixel-coord))]
         [y (+ half-tile (pixel-coord-y-pos pixel-coord))])
    (place-image foreground x y background)))

(define (place-cactus cactus background)
  (let* ([half-tile (/ TILE-SIDE-IN-PIXELS 2)]
         [cactus-coord (cactus-pixel-coord cactus)]
         [x (+ half-tile (pixel-coord-x-pos cactus-coord))]
         [y (+ (- (+ TILE-SIDE-IN-PIXELS (pixel-coord-y-pos cactus-coord)) (/ (image-height CACTUS-IMG) 2))
               (cactus-velocity cactus))])
    (place-image CACTUS-IMG x y background)))

; Set up UI
(define CANVAS-WIDTH 3) ; in tiles
(define CANVAS-HEIGHT 3) ; in tiles

(define BACKDROP
  (rectangle (tiles->pixels CANVAS-WIDTH)
             (tiles->pixels CANVAS-HEIGHT)
             "solid" "goldenrod"))

(define DIRT-TILES
  (list
   (tile-coord 0 2)
   (tile-coord 1 2)
   (tile-coord 2 2)))

(define (place-dirt-tile dt image)
  (place-image-center-tile DIRT-IMG image dt))

(define background
  (foldl place-dirt-tile BACKDROP DIRT-TILES))

; Set up cactus
; x and y pos are in tiles
(struct cactus (pixel-coord velocity jumping?))
(define init-cactus (cactus (tile-coord->pixel-coord (tile-coord 1 1)) 0 #f))

; Set up world
; map is currently a list of dirt tiles
(struct world (cactus))
(define init-world (world init-cactus))

(define (render world)
  (let ([cactus (world-cactus world)])
    (place-cactus cactus background)))

(define (handle-key w k)
  (let ([c (world-cactus w)])
    (if (and (key=? k " ")
             (not (cactus-jumping? c)))
        (world (cactus (cactus-pixel-coord c) INITIAL-VELOCITY #t))
        w)))

(define (tock w)
  (let* ([curr-cactus (world-cactus w)]
         [velocity (cactus-velocity curr-cactus)]
         [cactus-coord (cactus-pixel-coord curr-cactus)]
         [x (pixel-coord-x-pos cactus-coord)]
         [y (pixel-coord-y-pos cactus-coord)]
         [next-cactus-coord (pixel-coord x (+ y velocity))]
         [next-velocity (+ velocity GRAVITY)]
         [next-cactus (cactus next-cactus-coord next-velocity #t)])
    
    ; Update cactus position
    (if (not (cactus-jumping? curr-cactus))
        w
        (if ( > (pixel-coord-y-pos next-cactus-coord) 128)
            (world (cactus (pixel-coord x 128) 0 #f)) ; end of the road
            (world next-cactus)))))
   
; Run the world!

(define (main w)
  (big-bang w
    (name "Cactus Hop")
    (to-draw render)
    (on-key handle-key)
    (on-tick tock)))

(main init-world)