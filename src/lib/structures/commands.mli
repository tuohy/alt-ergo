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

(* Sat entry *)

type sat_decl_aux =
  | Decl of Id.typed
  | Assume of string * Expr.t * bool
  | PredDef of Expr.t * string (*name of the predicate*)
  | RwtDef of (Expr.t Typed.rwt_rule) list
  | Optimize of Expr.t * bool
  | Query of string *  Expr.t * Ty.goal_sort
  | ThAssume of Expr.th_elt
  | Push of int
  | Pop of int

type sat_tdecl = {
  st_loc : Loc.t;
  st_decl : sat_decl_aux
}

val print : Format.formatter -> sat_tdecl -> unit
