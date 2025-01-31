(**************************************************************************)
(*                                                                        *)
(*     Alt-Ergo: The SMT Solver For Software Verification                 *)
(*     Copyright (C) 2023 --- OCamlPro SAS                                *)
(*                                                                        *)
(*     This file is distributed under the terms of OCamlPro               *)
(*     Non-Commercial Purpose License, version 1.                         *)
(*                                                                        *)
(*     As an exception, Alt-Ergo Club members at the Gold level can       *)
(*     use this file under the terms of the Apache Software License       *)
(*     version 2.0.                                                       *)
(*                                                                        *)
(*     More details can be found in the directory licenses/               *)
(*                                                                        *)
(**************************************************************************)

type prelude = Fpa | Ria | Nra [@@deriving eq]

let pp_prelude ppf = function
  | Fpa -> Format.fprintf ppf "fpa"
  | Ria -> Format.fprintf ppf "ria"
  | Nra -> Format.fprintf ppf "nra"

type t =
  | Prelude of prelude
  | ADT
  | AC
[@@deriving eq]

let pp ppf = function
  | Prelude p -> pp_prelude ppf p
  | ADT -> Format.fprintf ppf "adt"
  | AC -> Format.fprintf ppf "ac"

let filename =
  Format.asprintf "<builtins>/%a.ae" pp_prelude

let content = function
  | Fpa -> [%blob "src/preludes/fpa.ae"]
  | Ria -> [%blob "src/preludes/ria.ae"]
  | Nra -> [%blob "src/preludes/nra.ae"]

let all_preludes = [ Fpa; Ria; Nra ]

let all = ADT :: AC :: List.map (fun p -> Prelude p) all_preludes

(* By default we disable Fpa, Ria and Nra preludes to prevent
   regressions. *)
let default_preludes = []

let default = [ ADT; AC ]

let preludes =
  List.filter_map (function | Prelude p -> Some p | _ -> None)
