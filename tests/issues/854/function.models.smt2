(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-option :produce-models true)
(declare-sort intref 0)
(declare-fun intrefqtmk (Int) intref)
(declare-fun a () Int)
(declare-fun f (Int) Int)
(define-fun aqtunused ((_x Int)) intref (intrefqtmk (f a)))
(assert (= (aqtunused 0) (aqtunused 1)))
(declare-fun a1 () Int)
(assert (not (and (<= 5 a1) (<= a1 15))))
(check-sat)
(get-model)
