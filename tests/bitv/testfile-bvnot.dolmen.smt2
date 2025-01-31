(set-logic BV)
(push 1)
(assert (distinct #b0110 (bvnot #b1001)))
(check-sat)
(pop 1)

(push 1)
(assert (distinct #b0110 (bvnot (bvnot #b0110))))
(check-sat)
(pop 1)

(push 1)
(assert (distinct #b1101 (bvnot ((_ extract 5 2) #b001011))))
(check-sat)
(pop 1)

(push 1)
(declare-const x (_ BitVec 4))
(assert (distinct x (bvnot (bvnot x))))
(check-sat)
(pop 1)

(push 1)
(declare-const x (_ BitVec 4))
(assert (= x (bvnot (bvadd #b0000 #b0000))))
(assert (distinct x #b1111))
(check-sat)
(pop 1)
