;;; reversi_marhs.clp
;;; Trabajo CLIPS Ingenieria del Conocimiento, Febrero 2015
;;; Marco Herrero Serna <me@marhs.de>
;;; Master MULCIA - Universidad de Sevilla

;; Notas:

;;  La estructura está basada en el ejemplo del tres en raya expuesto en clase

;;  El trabajo tiene un fallo, bastante grande, que no he conseguido resolver. 
;;  Durante el transcurso del juego, si el jugador humano pasa por no tener 
;;  ninguna opción para poner ficha, el juego se termina. Se que este problema
;;  tiene algo que ver con la interacción entre módulos, pero no he sido capaz
;;  de averiguar porque no me pasa de manera correcta de un módulo a otro. 

;;  Por lo tanto, he introducido una regla para que cuando uno de los dos
;;  jugadores pasa, el juego termina (aunque en principio no debería ser así)
;;  La regla es (ESTADO::end-pasa), en la línea 1232 , que si se comenta se 
;;  juega pasando.

;;  Por otra parte, existe un fallo que tampoco he conseguido solucionar,
;;  aunque este fallo no "rompe" nada importante:

;;  En la regla donde se comprueba quien gana/pierde/empata comprobando la di-
;;  ferencia entre los puntos de ambos jugadores, no es capaz de hacer saltar
;;  la regla con el > o <. Aunque los puntos sean 12 vs 50, salta el empate.
;;  Estas reglas son (ESTADO::tie), en la linea 1287, están comentadas, y 
;;  las he sustituido por la regla de mostrar la puntuación final directamente.
;;  En la regla pongo una pequeña explicación. 


;; MAIN
;; Definición de las estructuras de control, de inicio y de fin

(defmodule MAIN
    (export ?ALL)) 

;; Plantillas

(deftemplate MAIN::casilla
    (slot fila
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    (slot columna
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    (slot valor
        (type LEXEME)
        (allowed-lexemes x o " ") 
        (default " ")))

;; Contador para las opciones
(defglobal MAIN ?*opciones* = 0)           
;; Contador para llevar los puntos al final de la partida
(defglobal MAIN ?*puntos-human* = 0)
(defglobal MAIN ?*puntos-comp* = 0)

;; Opciones para el humano
(deftemplate MAIN::opcion
    (slot fila
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    (slot columna
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    (slot id
        (default-dynamic (bind ?*opciones* (+ ?*opciones* 1)))))

;; Opciones para el ordenador
(deftemplate MAIN::heuristica
    (slot fila
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    (slot columna
        (type INTEGER)
        (range 1 8)
        (default ?NONE))
    ;; Aqui guarda la evaluacion de la casilla
    (slot heur
        (type INTEGER)
        (range -100 100)
        (default 1))
    (slot id
        (default-dynamic (bind ?*opciones* (+ ?*opciones* 1)))))

;;      Tablero
(deffacts MAIN::tablero
    (casilla (fila 1) (columna 1))
    (casilla (fila 1) (columna 2))
    (casilla (fila 1) (columna 3))
    (casilla (fila 1) (columna 4))
    (casilla (fila 1) (columna 5))
    (casilla (fila 1) (columna 6))
    (casilla (fila 1) (columna 7))
    (casilla (fila 1) (columna 8))
    (casilla (fila 2) (columna 1))
    (casilla (fila 2) (columna 2))
    (casilla (fila 2) (columna 3))
    (casilla (fila 2) (columna 4))
    (casilla (fila 2) (columna 5))
    (casilla (fila 2) (columna 6))
    (casilla (fila 2) (columna 7))
    (casilla (fila 2) (columna 8))
    (casilla (fila 3) (columna 1))
    (casilla (fila 3) (columna 2))
    (casilla (fila 3) (columna 3))
    (casilla (fila 3) (columna 4))
    (casilla (fila 3) (columna 5))
    (casilla (fila 3) (columna 6))
    (casilla (fila 3) (columna 7))
    (casilla (fila 3) (columna 8))
    (casilla (fila 4) (columna 1))
    (casilla (fila 4) (columna 2))
    (casilla (fila 4) (columna 3))
    ;(casilla (fila 4) (columna 4))
    ;(casilla (fila 4) (columna 5))
    (casilla (fila 4) (columna 4) (valor x))
    (casilla (fila 4) (columna 5) (valor o))
    (casilla (fila 4) (columna 6))
    (casilla (fila 4) (columna 7))
    (casilla (fila 4) (columna 8))
    (casilla (fila 5) (columna 1))
    (casilla (fila 5) (columna 2))
    (casilla (fila 5) (columna 3))
    ;(casilla (fila 5) (columna 4))
    ;(casilla (fila 5) (columna 5))
    (casilla (fila 5) (columna 4) (valor o))
    (casilla (fila 5) (columna 5) (valor x))
    (casilla (fila 5) (columna 6))
    (casilla (fila 5) (columna 7))
    (casilla (fila 5) (columna 8))
    (casilla (fila 6) (columna 1))
    (casilla (fila 6) (columna 2))
    (casilla (fila 6) (columna 3))
    ;(casilla (fila 6) (columna 1) (valor x))
    ;(casilla (fila 6) (columna 2) (valor o))
    ;(casilla (fila 6) (columna 3) (valor x))
    (casilla (fila 6) (columna 4))
    (casilla (fila 6) (columna 5))
    (casilla (fila 6) (columna 6))
    ;(casilla (fila 6) (columna 6) (valor o))
    (casilla (fila 6) (columna 7))
    (casilla (fila 6) (columna 8))
    (casilla (fila 7) (columna 1))
    (casilla (fila 7) (columna 2))
    (casilla (fila 7) (columna 3))
    (casilla (fila 7) (columna 4))
    (casilla (fila 7) (columna 5))
    (casilla (fila 7) (columna 6))
    (casilla (fila 7) (columna 7))
    (casilla (fila 7) (columna 8))
    (casilla (fila 8) (columna 1))
    (casilla (fila 8) (columna 2))
    (casilla (fila 8) (columna 3))
    (casilla (fila 8) (columna 4))
    (casilla (fila 8) (columna 5))
    (casilla (fila 8) (columna 6))
    (casilla (fila 8) (columna 7))
    (casilla (fila 8) (columna 8)))

;;      Inicio del juego/elecciones

(defrule MAIN::eleccion-jugador-inicio
;; Selecciona el jugador de inicio
    (not (turno ?))
    =>
    (printout t "Selecciona quien lleva las negras (c/h):")
    (assert (turno (read))))

(defrule MAIN::eleccion-jugador-inicio-incorrecta
;; Comprueba que la eleccion de inicio haya sido correcta
    ?eleccion <- (turno ?respuesta&~c&~h)
    (not (ficha-c ?))
    (not (ficha-h ?))
    =>
    (retract ?eleccion)
    (printout t "Opción incorrecta, elige de nuevo." crlf))

(defrule MAIN::eleccion-ficha-o
;; Asigna las negras a ordenador, blancas a humano
    ?eleccion <- (turno h)
    (not (ficha-h ?))
    (not (ficha-c ?))
    =>
    (printout t "Juegas con negras, yo con blancas, empiezas tú" crlf)
    (assert (ficha-h o))
    (assert (ficha-c x)))

(defrule MAIN::eleccion-ficha-c
;; Asigna las negras a humano, blancas a ordenador
    ?eleccion <- (turno c)
    (not (ficha-h ?))
    (not (ficha-c ?))
    =>
    (printout t "Juegas con blancas, yo con negras, empiezo yo" crlf)
    (assert (ficha-c o))
    (assert (ficha-h x)))


;; Main LOOP
(defrule MAIN::fin
;; Si ambos jugadores pasan, el juego termina 
    (pasa h)
    (pasa c)
    =>
    (assert (fin-juego)))

(defrule MAIN::turno-human
    (ficha-h ?)
    (ficha-c ?)
    ?turno <- (turno h)
    =>
    (focus DIBUJO ESTADO HUMAN)
    (retract ?turno)
    (assert (turno c)))

(defrule MAIN::turno-computer
    (ficha-h ?)
    (ficha-c ?)
    ?turno <- (turno c)
    =>
    (focus DIBUJO ESTADO COMPUTER)
    (retract ?turno)
    (assert (turno h)))

;; DIBUJO -     Modulo
;; --------------------------------------------

(defmodule DIBUJO
    (import MAIN ?ALL))

(defrule DIBUJO::dibuja-tablero
  (casilla (fila 1) (columna 1) (valor ?c11))
  (casilla (fila 1) (columna 2) (valor ?c12))
  (casilla (fila 1) (columna 3) (valor ?c13))
  (casilla (fila 1) (columna 4) (valor ?c14))
  (casilla (fila 1) (columna 5) (valor ?c15))
  (casilla (fila 1) (columna 6) (valor ?c16))
  (casilla (fila 1) (columna 7) (valor ?c17))
  (casilla (fila 1) (columna 8) (valor ?c18))
  (casilla (fila 2) (columna 1) (valor ?c21))
  (casilla (fila 2) (columna 2) (valor ?c22))
  (casilla (fila 2) (columna 3) (valor ?c23))
  (casilla (fila 2) (columna 4) (valor ?c24))
  (casilla (fila 2) (columna 5) (valor ?c25))
  (casilla (fila 2) (columna 6) (valor ?c26))
  (casilla (fila 2) (columna 7) (valor ?c27))
  (casilla (fila 2) (columna 8) (valor ?c28))
  (casilla (fila 3) (columna 1) (valor ?c31))
  (casilla (fila 3) (columna 2) (valor ?c32))
  (casilla (fila 3) (columna 3) (valor ?c33))
  (casilla (fila 3) (columna 4) (valor ?c34))
  (casilla (fila 3) (columna 5) (valor ?c35))
  (casilla (fila 3) (columna 6) (valor ?c36))
  (casilla (fila 3) (columna 7) (valor ?c37))
  (casilla (fila 3) (columna 8) (valor ?c38))
  (casilla (fila 4) (columna 1) (valor ?c41))
  (casilla (fila 4) (columna 2) (valor ?c42))
  (casilla (fila 4) (columna 3) (valor ?c43))
  (casilla (fila 4) (columna 4) (valor ?c44))
  (casilla (fila 4) (columna 5) (valor ?c45))
  (casilla (fila 4) (columna 6) (valor ?c46))
  (casilla (fila 4) (columna 7) (valor ?c47))
  (casilla (fila 4) (columna 8) (valor ?c48))
  (casilla (fila 5) (columna 1) (valor ?c51))
  (casilla (fila 5) (columna 2) (valor ?c52))
  (casilla (fila 5) (columna 3) (valor ?c53))
  (casilla (fila 5) (columna 4) (valor ?c54))
  (casilla (fila 5) (columna 5) (valor ?c55))
  (casilla (fila 5) (columna 6) (valor ?c56))
  (casilla (fila 5) (columna 7) (valor ?c57))
  (casilla (fila 5) (columna 8) (valor ?c58))
  (casilla (fila 6) (columna 1) (valor ?c61))
  (casilla (fila 6) (columna 2) (valor ?c62))
  (casilla (fila 6) (columna 3) (valor ?c63))
  (casilla (fila 6) (columna 4) (valor ?c64))
  (casilla (fila 6) (columna 5) (valor ?c65))
  (casilla (fila 6) (columna 6) (valor ?c66))
  (casilla (fila 6) (columna 7) (valor ?c67))
  (casilla (fila 6) (columna 8) (valor ?c68))
  (casilla (fila 7) (columna 1) (valor ?c71))
  (casilla (fila 7) (columna 2) (valor ?c72))
  (casilla (fila 7) (columna 3) (valor ?c73))
  (casilla (fila 7) (columna 4) (valor ?c74))
  (casilla (fila 7) (columna 5) (valor ?c75))
  (casilla (fila 7) (columna 6) (valor ?c76))
  (casilla (fila 7) (columna 7) (valor ?c77))
  (casilla (fila 7) (columna 8) (valor ?c78))
  (casilla (fila 8) (columna 1) (valor ?c81))
  (casilla (fila 8) (columna 2) (valor ?c82))
  (casilla (fila 8) (columna 3) (valor ?c83))
  (casilla (fila 8) (columna 4) (valor ?c84))
  (casilla (fila 8) (columna 5) (valor ?c85))
  (casilla (fila 8) (columna 6) (valor ?c86))
  (casilla (fila 8) (columna 7) (valor ?c87))
  (casilla (fila 8) (columna 8) (valor ?c88))
  (turno ?t)
  =>
  ;(printout t "[MODULO DIBUJO -------------------]" crlf)
  ;(printout t "         Acaba de jugar: [" ?t "]" crlf crlf)
  (printout t crlf "         1   2   3   4   5   6   7   8  " crlf crlf)

  (printout t "    1    " ?c11 " | " ?c12 " | " ?c13 " | " ?c14 " | " ?c15 " | " ?c16 " | " ?c17 " | " ?c18 "   1" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    2    " ?c21 " | " ?c22 " | " ?c23 " | " ?c24 " | " ?c25 " | " ?c26 " | " ?c27 " | " ?c28 "   2" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    3    " ?c31 " | " ?c32 " | " ?c33 " | " ?c34 " | " ?c35 " | " ?c36 " | " ?c37 " | " ?c38 "   3" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    4    " ?c41 " | " ?c42 " | " ?c43 " | " ?c44 " | " ?c45 " | " ?c46 " | " ?c47 " | " ?c48 "   4" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    5    " ?c51 " | " ?c52 " | " ?c53 " | " ?c54 " | " ?c55 " | " ?c56 " | " ?c57 " | " ?c58 "   5" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    6    " ?c61 " | " ?c62 " | " ?c63 " | " ?c64 " | " ?c65 " | " ?c66 " | " ?c67 " | " ?c68 "   6" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    7    " ?c71 " | " ?c72 " | " ?c73 " | " ?c74 " | " ?c75 " | " ?c76 " | " ?c77 " | " ?c78 "   7" crlf)
  (printout t "        ---+---+---+---+---+---+---+--- " crlf)
  (printout t "    8    " ?c81 " | " ?c82 " | " ?c83 " | " ?c84 " | " ?c85 " | " ?c86 " | " ?c87 " | " ?c88 "   8" crlf crlf)

  (printout t "         1   2   3   4   5   6   7   8  " crlf crlf)
  (return))

;; HUMAN -      Modulo
;; --------------------------------------------

(defmodule HUMAN
    (import MAIN ?ALL)
    (export ?ALL))

(defrule HUMAN::inicio-turno-human
    ;; Regla SOLO para mostrar que el modulo se activa y se inicia
    ;; Lo he puesto para intentar averiguar si HUMAN se activa correctamente
    (declare (salience 20))
    (not (inicio-turno))
    =>
    ;(printout t "[MODULO HUMAN]---------------" crlf)
    (assert (inicio-turno)))

(defrule HUMAN::calcula-opciones
    (declare (salience 10))
    (not (eleccion ?))
    =>
    (printout t "   Calculando opciones" crlf)
    (focus OPCIONESH))

(defrule HUMAN::no-hay-opciones
    (not (eleccion ?))
    (not (opcion))
    (not (contador-opciones))
    =>
    (bind ?*opciones* 0)
    (printout t "   No tienes movimientos" crlf)
    (assert (pasa h)))

(defrule HUMAN::genera-contador-opciones
    (not (eleccion ?))
    (not (contador-opciones ?))
    (exists (opcion))
    =>
    (printout t "   Opciones:" crlf)
    (assert (contador-opciones ?*opciones*)))

(defrule HUMAN::muestra-opciones
    (not (eleccion ?))
    (opcion (fila ?f) (columna ?c) (id ?id))
    ?h <- (contador-opciones ?id)
    =>
    (printout t "   * (" ?id ") Casilla [" ?f "," ?c "]" crlf)
    (retract ?h)
    (assert (contador-opciones (- ?id 1))))

(defrule HUMAN::eleccion
    (contador-opciones 0)
    =>
    (printout t "   Elige movimiento (id):")
    (assert (eleccion (read))))

(defrule HUMAN::remove-pasa
    ;; Si hay una eleccion, significa que ha jugado, por lo que se elimina pasa
    ;; en el caso de que hubiese pasado en la ronda anterior
    (eleccion ?e&>0)
    ?p <- (pasa h)
    =>
    (retract ?p))

(defrule HUMAN::eleccion-incorrecta
    ?h1 <- (contador-opciones 0)
    ?h2 <- (eleccion ?id&~0)
    (not (opcion (id ?id)))
    =>
    (printout t " * Elección incorrecta" crlf)
    (retract ?h1 ?h2)
    (assert (contador-opciones 0)))

(defrule HUMAN::eleccion-correcta-limpieza
    (eleccion ?id&~0)
    (opcion (fila ?f) (columna ?c) (id ?id))
    ?h1 <- (opcion (id ~?id))
    =>
    (retract ?h1))

(defrule HUMAN::flip-arrriba
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c)
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f) (< ?f3 ?f2)))
                    (columna ?c)
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c)
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-abajo
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c)
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f) (> ?f3 ?f2)))
                    (columna ?c)
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c)
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-derecha
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (columna ?c2&:(< ?c2 (- ?c 1)))
                (fila ?f)
                (valor ?human))
    (not (casilla   (columna ?c3&:(and (< ?c3 ?c) (> ?c3 ?c2)))
                    (fila ?f)
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (columna ?c1&:(= ?c1 (+ ?c2 1)))
                    (fila ?f)
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))


(defrule HUMAN::flip-izquierda
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (columna ?c2&:(> ?c2 (+ ?c 1)))
                (fila ?f)
                (valor ?human))
    (not (casilla   (columna ?c3&:(and (> ?c3 ?c) (< ?c3 ?c2)))
                    (fila ?f)
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (columna ?c1&:(= ?c1 (- ?c2 1)))
                    (fila ?f)
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-dia-arrd
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c2&:(= ?c2 (+ ?c (- ?f ?f2))))
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f2) (> ?f3 ?f)))
                    (columna ?c3&:(= ?c3 (+ ?c (- ?f ?f3))))
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c1&:(= ?c1 (+ ?c (- ?f ?f1))))
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-dia-arri
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c2&:(= ?c (+ ?c2 (- ?f ?f2))))
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f2) (> ?f3 ?f)))
                    (columna ?c3&:(= ?c (+ ?c3 (- ?f ?f3))))
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c1&:(= ?c (+ ?c1 (- ?f ?f1))))
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-dia-abjd
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c2&:(= ?c2 (+ ?c (- ?f2 ?f))))
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f2) (< ?f3 ?f)))
                    (columna ?c3&:(= ?c3 (+ ?c (- ?f3 ?f))))
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c1&:(= ?c1 (+ ?c (- ?f1 ?f))))
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::flip-dia-abji
    (ficha-h ?human)
    (ficha-c ?comp)
    (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c2&:(= ?c (+ ?c2 (- ?f2 ?f))))
                (valor ?human))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f2) (< ?f3 ?f)))
                    (columna ?c3&:(= ?c (+ ?c3 (- ?f3 ?f))))
                    (valor " "|?human)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c1&:(= ?c (+ ?c1 (- ?f1 ?f))))
                    (valor ?comp))
    =>
    (modify ?h (valor ?human)))

(defrule HUMAN::ficha-final
    (declare (salience -3))
    (ficha-h ?human)
    (ficha-c ?comp)
    ?ini <- (inicio-turno)
    ?ele <- (eleccion ?id)
    ?tot <- (contador-opciones 0)
    ?opcion <- (opcion (fila ?f) (columna ?c) (id ?id))
    (not (opcion (id ~?id)))
    ?ficha <- (casilla (fila ?f) (columna ?c) (valor " "))
    =>
    (bind ?*opciones* 0)
    (retract ?opcion ?tot ?ele ?ini)
    (modify ?ficha (valor ?human))
    (focus DIBUJO ESTADO COMPUTER)
    (return))

;; OPCIONESH -   Modulo
;; --------------------------------------------

;; Aqui se añaden las opciones que tiene un jugador a la hora de poner.
;; Como definí arriba, las opciones son de tipo
;; (opcion (fila x) (columna y))

(defmodule OPCIONESH
  (import MAIN ?ALL))

(defrule OPCIONESH::opciones-derh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (fila ?f) (columna ?c) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (fila ?f) (columna ?c1&:(= (- ?c 1) ?c1)) (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (fila ?f) (columna ?c2&:(< ?c2 ?c1) ) (valor ?human))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (fila ?f) (columna ?c3&:(and (< ?c3 ?c) (> ?c3 ?c2)) )
                            (valor " "|?human)))
    (not (opcion (fila ?f) (columna ?c)))
    =>
    (assert (opcion (fila ?f) (columna ?c))))

(defrule OPCIONESH::opciones-izqh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (fila ?f) (columna ?c) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (fila ?f) (columna ?c1&:(= (+ ?c 1) ?c1)) (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (fila ?f) (columna ?c2&:(> ?c2 ?c1) ) (valor ?human))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (fila ?f) (columna ?c3&:(and (> ?c3 ?c1) (< ?c3 ?c2)) )
                            (valor " "|?human)))
    (not (opcion (fila ?f) (columna ?c)))
    =>
    (assert (opcion (fila ?f) (columna ?c))))

(defrule OPCIONESH::opciones-arrh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (columna ?c) (fila ?f) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (columna ?c) (fila ?f1&:(= (+ ?f 1) ?f1)) (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (columna ?c) (fila ?f2&:(> ?f2 ?f1) ) (valor ?human))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (columna ?c) (fila ?f3&:(and (> ?f3 ?f1) (< ?f3 ?f2)) )
                            (valor " "|?human)))
    (not (opcion (fila ?f) (columna ?c)))
    =>
    (assert (opcion (fila ?f) (columna ?c))))

(defrule OPCIONESH::opciones-abjh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (columna ?c) (fila ?f) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (columna ?c) (fila ?f1&:(= (- ?f 1) ?f1)) (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (columna ?c) (fila ?f2&:(< ?f2 ?f1) ) (valor ?human))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (columna ?c) (fila ?f3&:(and (< ?f3 ?f1) (> ?f3 ?f2)) )
                            (valor " "|?human)))
    (not (opcion (fila ?f) (columna ?c)))
    =>
    (assert (opcion (fila ?f) (columna ?c))))

(defrule OPCIONESH::opciones-dia-arrdh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla 	(fila ?f1&:(= (+ ?f 1) ?f1))
                (columna ?c1&:(= (- ?c 1) ?c1))
                (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla	(fila ?f2&:(> ?f2 ?f))
                (columna ?c2&:(= (- ?c ?c2) (- ?f2 ?f)))
                (valor ?human))
    (not (casilla   (fila ?f3&:(> ?f3 ?f)&:(< ?f3 ?f2))
                    (columna ?c3&:(= ?c3 (- ?c (- ?f3 ?f))))
                    (valor  " "|?human)))
    (not (opcion 	(fila ?f)
                    (columna ?c)))
  =>
    (assert (opcion (fila ?f)
					(columna ?c))))

(defrule OPCIONESH::opciones-dia-arrih
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla 	(fila ?f1&:(= (+ ?f 1) ?f1))
                (columna ?c1&:(= (+ ?c 1) ?c1))
                (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla	(fila ?f2&:(> ?f2 ?f))
                (columna ?c2&:(= (- ?c2 ?c) (- ?f2 ?f)))
                (valor ?human))
    (not (casilla (fila ?f3&:(> ?f3 ?f)&:(< ?f3 ?f2))
                  (columna ?c3&:(= (- ?c3 ?c) (- ?f3 ?f)))
                  (valor  " "|?human)))
    (not (opcion  (fila ?f)
                  (columna ?c)))
  =>
    (assert (opcion 	(fila ?f)
                        (columna ?c))))

(defrule OPCIONESH::opciones-dia-abjdh
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla 	(fila ?f1&:(= (- ?f 1) ?f1))
                (columna ?c1&:(= (- ?c 1) ?c1))
                (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla	(fila ?f2&:(< ?f2 ?f))
                (columna ?c2&:(= (- ?c ?c2) (- ?f ?f2)))
                (valor ?human))
    (not (casilla   (fila ?f3&:(< ?f3 ?f)&:(> ?f3 ?f2))
                    (columna ?c3&:(= (- ?c ?c3) (- ?f ?f3)))
                    (valor  " "|?human)))
    (not (opcion 	(fila ?f)
                    (columna ?c)))
  =>
    (assert (opcion 	(fila ?f)
                        (columna ?c))))

(defrule OPCIONESH::opciones-dia-abjih
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla 	(fila ?f1&:(= (- ?f 1) ?f1))
                (columna ?c1&:(= (+ ?c 1) ?c1))
                (valor ?comp))
    ; Existe una ficha propia por la izq no adyacente
    (casilla	(fila ?f2&:(< ?f2 ?f))
                (columna ?c2&:(= (- ?c2 ?c) (- ?f ?f2)))
                (valor ?human))
    (not (casilla  (fila ?f3&:(< ?f3 ?f)&:(> ?f3 ?f2))
                   (columna ?c3&:(= (- ?c3 ?c) (- ?f ?f3)))
                   (valor  " "|?human)))
    (not (opcion   (fila ?f)
                   (columna ?c)))
      =>
    (assert (opcion (fila ?f)
                    (columna ?c))))
;; COMPUTER -  Modulo
;; --------------------------------------------

(defmodule COMPUTER
    (import MAIN ?ALL)
    (export ?ALL))

(defrule COMPUTER::inicio-turno-computer
    (declare (salience 20))
    (not (inicio-turno))
    =>
    ;(printout t "[MODULO COMPUTER]---------------" crlf)
    (assert (inicio-turno)))

(defrule COMPUTER::calcula-opciones
    (declare (salience 10))
    (not (eleccion ?))
    =>
    (focus OPCIONESC))

(defrule COMPUTER::no-hay-opciones
    (not (eleccion ?))
    (not (heuristica))
    =>
    (printout t "   [c] No tengo movimientos" crlf)
    (assert (pasa c)))

(defrule COMPUTER::remove-pasa
    (eleccion)
    ?p <- (pasa c)
    =>
    (retract ?p))

(defrule COMPUTER::genera-contador-opciones
    (not (eleccion ?))
    (not (contador-opciones ?))
    (exists (heuristica))
    =>
    (focus NIVEL-0)
    (assert (contador-opciones ?*opciones*)))

(defrule COMPUTER::muestra-opciones
    (not (eleccion ?))
    (heuristica (fila ?f) (columna ?c) (id ?id))
    ?h <- (contador-opciones ?id)
    =>
    (retract ?h)
    (assert (contador-opciones (- ?id 1))))

(defrule COMPUTER::eleccion
    (not (eleccion))
    (contador-opciones 0)
    (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    (not (heuristica (heur ?h1&:(> ?h1 ?h))))
    =>
    (printout t "   [c] He elegido (" ?f "," ?c ") con Heuristica = " ?h crlf)
    (assert (eleccion ?id)))

(defrule COMPUTER::eleccion-incorrecta
    ;; Esto deberia borrarse, ya que no tendria que aparecer ninguna eleccion
    ;; incorrecta por el ordenador, pero lo dejo por ahora como medida de 
    ;; seguridad
    ?h1 <- (contador-opciones 0)
    ?h2 <- (eleccion ?id)
    (not (heuristica (id ?id)))
    =>
    (printout t " * Elección incorrecta" crlf)
    (retract ?h1 ?h2)
    (assert (contador-opciones 0)))

(defrule COMPUTER::eleccion-correcta-limpieza
    (eleccion ?id)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    ?h1 <- (heuristica (id ~?id))
    =>
    (retract ?h1))

(defrule COMPUTER::flip-arrriba
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c)
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f) (< ?f3 ?f2)))
                    (columna ?c)
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c)
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-abajo
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c)
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f) (> ?f3 ?f2)))
                    (columna ?c)
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c)
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-derecha
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (columna ?c2&:(< ?c2 (- ?c 1)))
                (fila ?f)
                (valor ?comp))
    (not (casilla   (columna ?c3&:(and (< ?c3 ?c) (> ?c3 ?c2)))
                    (fila ?f)
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (columna ?c1&:(= ?c1 (+ ?c2 1)))
                    (fila ?f)
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))


(defrule COMPUTER::flip-izquierda
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (columna ?c2&:(> ?c2 (+ ?c 1)))
                (fila ?f)
                (valor ?comp))
    (not (casilla   (columna ?c3&:(and (> ?c3 ?c) (< ?c3 ?c2)))
                    (fila ?f)
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (columna ?c1&:(= ?c1 (- ?c2 1)))
                    (fila ?f)
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-dia-arrd
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c2&:(= ?c2 (+ ?c (- ?f ?f2))))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f2) (> ?f3 ?f)))
                    (columna ?c3&:(= ?c3 (+ ?c (- ?f ?f3))))
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c1&:(= ?c1 (+ ?c (- ?f ?f1))))
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-dia-arri
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(> ?f2 (+ ?f 1)))
                (columna ?c2&:(= ?c (+ ?c2 (- ?f ?f2))))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (< ?f3 ?f2) (> ?f3 ?f)))
                    (columna ?c3&:(= ?c (+ ?c3 (- ?f ?f3))))
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (- ?f2 1)))
                    (columna ?c1&:(= ?c (+ ?c1 (- ?f ?f1))))
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-dia-abjd
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c2&:(= ?c2 (+ ?c (- ?f2 ?f))))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f2) (< ?f3 ?f)))
                    (columna ?c3&:(= ?c3 (+ ?c (- ?f3 ?f))))
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c1&:(= ?c1 (+ ?c (- ?f1 ?f))))
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::flip-dia-abji
    (ficha-h ?human)
    (ficha-c ?comp)
    (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ;; Casilla limite
    (casilla    (fila ?f2&:(< ?f2 (- ?f 1)))
                (columna ?c2&:(= ?c (+ ?c2 (- ?f2 ?f))))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(and (> ?f3 ?f2) (< ?f3 ?f)))
                    (columna ?c3&:(= ?c (+ ?c3 (- ?f3 ?f))))
                    (valor " "|?comp)))
    ;; Casilla a flip
    ?h <- (casilla  (fila ?f1&:(= ?f1 (+ ?f2 1)))
                    (columna ?c1&:(= ?c (+ ?c1 (- ?f1 ?f))))
                    (valor ?human))
    =>
    (modify ?h (valor ?comp)))

(defrule COMPUTER::ficha-final
    (declare (salience -3))
    (ficha-h ?human)
    (ficha-c ?comp)
    ?ini <- (inicio-turno)
    ?ele <- (eleccion ?id)
    ?tot <- (contador-opciones 0)
    ?opcion <- (heuristica (fila ?f) (columna ?c) (id ?id))
    (not (heuristica (id ~?id)))
    ?ficha <- (casilla (fila ?f) (columna ?c) (valor " "))
    =>
    (bind ?*opciones* 0)
    (retract ?opcion ?tot ?ele ?ini)
    (modify ?ficha (valor ?comp))
    (focus DIBUJO ESTADO HUMAN)
    (return))


;;   Estrategia NIVEL-0 - Modulo
;;--------------------------------------

(defmodule NIVEL-0
    (import MAIN ?ALL)
    (import COMPUTER ?ALL))

(defrule NIVEL-0::esquinas ;; 1
    ?cas <- (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    ;; Comprobacion para que no empeore la heuristica
    (test (< ?h 50))
    (test (or   (and (= ?f 1) (= ?c 1))
                (and (= ?f 1) (= ?c 8))
                (and (= ?f 8) (= ?c 1))
                (and (= ?f 8) (= ?c 8))))
    =>
    (printout t "   Modificando heur: " ?h "-> 1 ("?f ?c")" crlf)
    (modify ?cas (heur 50)))

(defrule NIVEL-0::esquina-peligrosa ;; 2
    (ficha-h ?human)
    ?cas <- (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    ;; Comprobacion para que no empeore la heuristica 
    (test (> ?h -1))
    ;; Comprueba que sea una diagonal pegada a la esquina
    (test (or   (and (= ?f 2) (= ?c 2))
                (and (= ?f 2) (= ?c 7))
                (and (= ?f 7) (= ?c 2))
                (and (= ?f 7) (= ?c 7))))
    =>
    ;; Para ver cuando se modifica una heurística, descomentar esta línea
    ;(printout t "   Modificando heur: " ?h "-> -10 ("?f ?c")" crlf)
    (modify ?cas (heur -10)))

(defrule NIVEL-0::esquinas-peligrosas ;; 2
    (ficha-h ?human)
    ?cas <- (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    ;; Comprobacion para que no empeore la heuristica 
    (test (> ?h 0))
    ;; Comprueba que sea una casilla cercana a la esquina
    (test (or   (and (= ?f 2) (= ?c 1))
                (and (= ?f 1) (= ?c 2))
                (and (= ?f 1) (= ?c 7))
                (and (= ?f 2) (= ?c 8))
                (and (= ?f 7) (= ?c 1))
                (and (= ?f 8) (= ?c 2))
                (and (= ?f 7) (= ?c 8))
                (and (= ?f 8) (= ?c 7))))
    =>
    ;; Para ver cuando se modifica una heurística, descomentar esta línea
    ;(printout t "   Modificando heur: " ?h "-> -1 ("?f ?c")" crlf)
    (modify ?cas (heur -1)))

(defrule NIVEL-0::lado-fuerte ;; 2
    (ficha-h ?human)
    ?cas <- (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    ;; Comprobacion para que no empeore la heuristica 
    (test (< ?h 5))
    (test (or   (and (= ?f 3) (= ?c 1))
                (and (= ?f 1) (= ?c 3))
                (and (= ?f 1) (= ?c 6))
                (and (= ?f 3) (= ?c 8))
                (and (= ?f 6) (= ?c 1))
                (and (= ?f 8) (= ?c 3))
                (and (= ?f 6) (= ?c 8))
                (and (= ?f 8) (= ?c 6))))
    =>
    ;; Para ver cuando se modifica una heurística, descomentar esta línea
    ;(printout t "   Modificando heur: " ?h "-> 5 ("?f ?c")" crlf)
    (modify ?cas (heur 5)))

(defrule NIVEL-0::lado-debil ;; 2
    (ficha-h ?human)
    ?cas <- (heuristica (fila ?f) (columna ?c) (heur ?h) (id ?id))
    ;; Comprobacion para que no empeore la heuristica 
    (test (< ?h 2))
    (test (or   (and (= ?f 4) (= ?c 1))
                (and (= ?f 1) (= ?c 4))
                (and (= ?f 1) (= ?c 5))
                (and (= ?f 4) (= ?c 8))
                (and (= ?f 5) (= ?c 1))
                (and (= ?f 8) (= ?c 4))
                (and (= ?f 5) (= ?c 8))
                (and (= ?f 8) (= ?c 5))))
    =>
    ;; Para ver cuando se modifica una heurística, descomentar esta línea
    ;(printout t "   Modificando heur: " ?h "-> 2 ("?f ?c")" crlf)
    (modify ?cas (heur 2)))

;; OPCIONESC -   Modulo
;; --------------------------------------------

;; Aqui se anaden las opciones que tiene un ordenador a la hora de poner.
;; Como defini arriba, las opciones son de tipo
;; (opcion (fila x) (columna y))

(defmodule OPCIONESC
  (import MAIN ?ALL))


(defrule OPCIONESC::opciones-der
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (fila ?f) (columna ?c) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (fila ?f) (columna ?c1&:(= (- ?c 1) ?c1)) (valor ?human))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (fila ?f) (columna ?c2&:(< ?c2 ?c1) ) (valor ?comp))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (fila ?f) (columna ?c3&:(and (< ?c3 ?c) (> ?c3 ?c2)) )
                            (valor " "|?comp)))
    (not (heuristica (fila ?f) (columna ?c)))
    =>
    (assert (heuristica (fila ?f) (columna ?c))))

(defrule OPCIONESC::opciones-izq
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (fila ?f) (columna ?c) (valor " "))
    ; Existe una ficha contraria adyacente por la izquierda
    (casilla (fila ?f) (columna ?c1&:(= (+ ?c 1) ?c1)) (valor ?human))
    ; Existe una ficha propia por la izq no adyacente
    (casilla (fila ?f) (columna ?c2&:(> ?c2 ?c1) ) (valor ?comp))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (fila ?f) (columna ?c3&:(and (> ?c3 ?c1) (< ?c3 ?c2)) )
                            (valor " "|?comp)))
    (not (heuristica (fila ?f) (columna ?c)))
    =>
    (assert (heuristica (fila ?f) (columna ?c))))

(defrule OPCIONESC::opciones-arr
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (columna ?c) (fila ?f) (valor " "))
    (casilla (columna ?c) (fila ?f1&:(= (+ ?f 1) ?f1)) (valor ?human))
    (casilla (columna ?c) (fila ?f2&:(> ?f2 ?f1) ) (valor ?comp))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (columna ?c) (fila ?f3&:(and (> ?f3 ?f1) (< ?f3 ?f2)) )
                            (valor " "|?comp)))
    (not (heuristica (fila ?f) (columna ?c)))
    =>
    (assert (heuristica (fila ?f) (columna ?c))))

(defrule OPCIONESC::opciones-abj
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla (columna ?c) (fila ?f) (valor " "))
    (casilla (columna ?c) (fila ?f1&:(= (- ?f 1) ?f1)) (valor ?human))
    (casilla (columna ?c) (fila ?f2&:(< ?f2 ?f1) ) (valor ?comp))
    ; No existe ningun hueco entre c2 y c1
    (not (casilla (columna ?c) (fila ?f3&:(and (< ?f3 ?f1) (> ?f3 ?f2)) )
                            (valor " "|?comp)))
    (not (heuristica (fila ?f) (columna ?c)))
    =>
    (assert (heuristica (fila ?f) (columna ?c))))

(defrule OPCIONESC::opciones-dia-arrd
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    (casilla 	(fila ?f1&:(= (+ ?f 1) ?f1))
                (columna ?c1&:(= (- ?c 1) ?c1))
                (valor ?human))
    (casilla	(fila ?f2&:(> ?f2 ?f))
                (columna ?c2&:(= (- ?c ?c2) (- ?f2 ?f)))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(> ?f3 ?f)&:(< ?f3 ?f2))
                    (columna ?c3&:(= ?c3 (- ?c (- ?f3 ?f))))
                    (valor  " "|?comp)))
    (not (heuristica 	(fila ?f)
                    (columna ?c)))
  =>
    (assert (heuristica (fila ?f)
					(columna ?c))))

(defrule OPCIONESC::opciones-dia-arri
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    (casilla 	(fila ?f1&:(= (+ ?f 1) ?f1))
                (columna ?c1&:(= (+ ?c 1) ?c1))
                (valor ?human))
    (casilla	(fila ?f2&:(> ?f2 ?f))
                (columna ?c2&:(= (- ?c2 ?c) (- ?f2 ?f)))
                (valor ?comp))
    (not (casilla (fila ?f3&:(> ?f3 ?f)&:(< ?f3 ?f2))
                  (columna ?c3&:(= (- ?c3 ?c) (- ?f3 ?f)))
                  (valor  " "|?comp)))
    (not (heuristica  (fila ?f)
                  (columna ?c)))
  =>
    (assert (heuristica 	(fila ?f)
                        (columna ?c))))

(defrule OPCIONESC::opciones-dia-abjd
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    (casilla 	(fila ?f1&:(= (- ?f 1) ?f1))
                (columna ?c1&:(= (- ?c 1) ?c1))
                (valor ?human))
    (casilla	(fila ?f2&:(< ?f2 ?f))
                (columna ?c2&:(= (- ?c ?c2) (- ?f ?f2)))
                (valor ?comp))
    (not (casilla   (fila ?f3&:(< ?f3 ?f)&:(> ?f3 ?f2))
                    (columna ?c3&:(= (- ?c ?c3) (- ?f ?f3)))
                    (valor  " "|?comp)))
    (not (heuristica 	(fila ?f)
                    (columna ?c)))
  =>
    (assert (heuristica 	(fila ?f)
                        (columna ?c))))

(defrule OPCIONESC::opciones-dia-abji
    (ficha-h ?human)
    (ficha-c ?comp)
    (casilla 	(fila ?f)
                (columna ?c)
                (valor " "))
    (casilla 	(fila ?f1&:(= (- ?f 1) ?f1))
                (columna ?c1&:(= (+ ?c 1) ?c1))
                (valor ?human))
    (casilla	(fila ?f2&:(< ?f2 ?f))
                (columna ?c2&:(= (- ?c2 ?c) (- ?f ?f2)))
                (valor ?comp))
    (not (casilla  (fila ?f3&:(< ?f3 ?f)&:(> ?f3 ?f2))
                   (columna ?c3&:(= (- ?c3 ?c) (- ?f ?f3)))
                   (valor  " "|?comp)))
    (not (heuristica   (fila ?f)
                   (columna ?c)))
      =>
    (assert (heuristica (fila ?f)
                    (columna ?c))))
;; ESTADO -     Modulo
;; --------------------------------------------

(defmodule ESTADO
    ;(import HUMAN ?ALL)
    ;(import COMPUTER ?ALL)
    (import MAIN ?ALL))
(defrule ESTADO::comprobando-estado
    (declare (salience -20))
    =>
    ;(printout t "[MODULE ESTADO] ----------------" crlf)
    (return))

(defrule ESTADO::end-pasa
    (pasa ?)
    =>
    (assert (fin-juego)))

(defrule ESTADO::fin-del-juego
    (not (casilla (valor " ")))
    =>
    (assert (fin-juego)))

(defrule ESTADO::calcula-fichas-human
    (ficha-h ?human)
    (ficha-c ?comp)
    (fin-juego)
    ?h <- (casilla (valor ?human))
    =>
    (retract ?h)
    (bind ?*puntos-human* (+ ?*puntos-human* 1)))

(defrule ESTADO::calcula-fichas-comp
    (ficha-h ?human)
    (ficha-c ?comp)
    (fin-juego)
    ?h <- (casilla (valor ?comp))
    =>
    (retract ?h)
    (bind ?*puntos-comp* (+ ?*puntos-comp* 1)))

(defrule ESTADO::elimina-casillas-vacias
    ?h <- (casilla (valor " "))
    (fin-juego)
    =>
    (retract ?h))

;; Estas tres reglas se usan para mostrar el final de la partida, pero no
;; terminan de funcionar. Sobre todo mira la de Tie, que aunque es simple
;; la regla se activa cuando no deberia (test (= ?*...)

;(defrule ESTADO::comp-win-fichas
    ;(declare (salience -10))
    ;(not (casilla ))
    ;(test (> ?*puntos-comp* ?*puntos-human*))
    ;=>
    ;(printout t "? Yo gano con " ?*puntos-comp* " vs " ?*puntos-human* " fichas" crlf)
    ;(halt))  

;(defrule ESTADO::human-win-fichas
    ;(declare (salience -10))
    ;(not (casilla ))
    ;(test (< ?*puntos-comp* ?*puntos-human*))
    ;=>
    ;(printout t (> 32 ?*puntos-comp*) "Tu ganas con " ?*puntos-human* " vs " ?*puntos-comp* " fichas" crlf)
    ;(halt))  

;(defrule ESTADO::tie
    ;(declare (salience -10))
    ;(not (casilla))
    ;(test       (= ?*puntos-comp* ?*puntos-human*) )
    ;=>
    ;(printout t (= ?*puntos-comp* ?*puntos-human*) " TIE" crlf)
    ;(halt))

(defrule ESTADO::end-game
    (not (casilla))
    (fin-juego)
    =>
    (printout t "Fin del juego. Tu: " ?*puntos-human* " - Yo: " ?*puntos-comp* crlf)
    (halt))

