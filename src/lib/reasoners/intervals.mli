(**************************************************************************)
(*                                                                        *)
(*     Alt-Ergo: The SMT Solver For Software Verification                 *)
(*     Copyright (C) 2013-2023 --- OCamlPro SAS                           *)
(*                                                                        *)
(*     This file is distributed under the terms of OCamlPro               *)
(*     Non-Commercial Purpose License, version 1.                         *)
(*                                                                        *)
(*     As an exception, Alt-Ergo Club members at the Gold level can       *)
(*     use this file under the terms of the Apache Software License       *)
(*     version 2.0.                                                       *)
(*                                                                        *)
(*     ---------------------------------------------------------------    *)
(*                                                                        *)
(*     The Alt-Ergo theorem prover                                        *)
(*                                                                        *)
(*     Sylvain Conchon, Evelyne Contejean, Francois Bobot                 *)
(*     Mohamed Iguernelala, Stephane Lescuyer, Alain Mebsout              *)
(*                                                                        *)
(*     CNRS - INRIA - Universite Paris Sud                                *)
(*                                                                        *)
(*     Until 2013, some parts of this code were released under            *)
(*     the Apache Software License version 2.0.                           *)
(*                                                                        *)
(*     ---------------------------------------------------------------    *)
(*                                                                        *)
(*     More details can be found in the directory licenses/               *)
(*                                                                        *)
(**************************************************************************)

type t

exception NotConsistent of Explanation.t
exception No_finite_bound

val undefined : Ty.t -> t

val is_undefined : t -> bool

val point : Numbers.Q.t -> Ty.t -> Explanation.t -> t

val doesnt_contain_0 : t -> Th_util.answer

val is_positive : t -> Th_util.answer

val is_strict_smaller : t -> t -> bool

val new_borne_sup : Explanation.t -> Numbers.Q.t -> is_le : bool -> t -> t

val new_borne_inf : Explanation.t -> Numbers.Q.t -> is_le : bool -> t -> t

val only_borne_sup : t -> t
(** Keep only the upper bound of the interval,
    setting the lower bound to minus infty. *)

val only_borne_inf : t -> t
(** Keep only the lower bound of the interval,
    setting the upper bound to plus infty. *)

val is_point : t -> (Numbers.Q.t * Explanation.t) option

val intersect : t -> t -> t

val exclude : t -> t -> t

val mult : t -> t -> t

val power : int -> t -> t

val sqrt : t -> t

val root : int -> t -> t

val add : t -> t -> t

val scale : Numbers.Q.t -> t -> t

val affine_scale : const:Numbers.Q.t -> coef:Numbers.Q.t -> t -> t
(** Perform an affine transformation on the given bounds.
    Suposing input bounds (b1, b2), this will return
    (const + coef * b1, const + coef * b2).
    This function is useful to avoid the incorrect roundings that
    can take place when scaling down an integer range. *)

val sub : t -> t -> t

val merge : t -> t -> t

val abs : t -> t

val pretty_print : Format.formatter -> t -> unit

val print : Format.formatter -> t -> unit

val finite_size : t -> Numbers.Q.t option

val borne_inf : t -> Numbers.Q.t * Explanation.t * bool
(** bool is true when bound is large. Raise: No_finite_bound if no
    finite lower bound *)

val borne_sup : t -> Numbers.Q.t * Explanation.t * bool
(** bool is true when bound is large. Raise: No_finite_bound if no
    finite upper bound*)

val div : t -> t -> t

val coerce : Ty.t -> t -> t
(** Coerce an interval to the given type. The main use of that function is
    to round a rational interval to an integer interval. This is particularly
    useful to avoid roudning too many times when manipulating intervals that
    at the end represent an integer interval, but whose intermediate state do
    not need to represent integer intervals (e.g. computing the interval for
    an integer polynome from the intervals of the monomes). *)

val mk_closed :
  Numbers.Q.t -> Numbers.Q.t -> bool -> bool ->
  Explanation.t -> Explanation.t -> Ty.t -> t
(**
   takes as argument in this order:
   - a lower bound
   - an upper bound
   - a bool that says if the lower bound it is large (true) or strict
   - a bool that says if the upper bound it is large (true) or strict
   - an explanation of the lower bound
   - an explanation of the upper bound
   - a type Ty.t (Tint or Treal *)

type bnd = (Numbers.Q.t * Numbers.Q.t) option * Explanation.t
(* - None <-> Infinity
   - the first number is the real bound
   - the second number if +1 (resp. -1) for strict lower (resp. upper) bound,
     and 0 for large bounds
*)

val bounds_of : t -> (bnd * bnd) list

val contains : t -> Numbers.Q.t -> bool

val add_explanation : t -> Explanation.t -> t

val equal : t -> t -> bool

val pick : is_max:bool -> t -> Numbers.Q.t option
(** [pick ~is_max t] returns an elements of the set of intervals [t]. If
    [is_max] is [true], we pick the largest element of [t], if it exists.
    We look for the smallest element if [is_max] is [false]. *)

type interval_matching =
  ((Numbers.Q.t * bool) option * (Numbers.Q.t * bool) option * Ty.t)
    Var.Map.t

(** matchs the given lower and upper bounds against the given interval, and
    update the given accumulator with the constraints. Returns None if
    the matching problem is inconsistent
*)
val match_interval:
  Symbols.bound -> Symbols.bound -> t -> interval_matching ->
  interval_matching option
