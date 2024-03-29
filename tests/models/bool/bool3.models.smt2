(set-option :produce-assignments true)
(set-option :produce-models true)
(set-logic ALL)
(declare-const x Bool)
(declare-const y Bool)
(assert (or (! (and x y) :named foo) (! (and (not x) (not y)) :named bar)))
(check-sat)
(get-model)
(get-assignment)