(* vim: set et ts=4: *)
(* Smbt, an SML build tool
 *  Copyright (c) 2012 Filip Sieczkowski & Gian Perrone
 * 
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appear in all copies and that
 * both the copyright notice and this permission notice and warranty
 * disclaimer appear in supporting documentation, and that the name of
 * the above copyright holders, or their entities, not be used in
 * advertising or publicity pertaining to distribution of the software
 * without specific, written prior permission.
 * 
 * The above copyright holders disclaim all warranties with regard to
 * this software, including all implied warranties of merchantability and
 * fitness. In no event shall the above copyright holders be liable for
 * any special, indirect or consequential damages or any damages
 * whatsoever resulting from loss of use, data or profits, whether in an
 * action of contract, negligence or other tortious action, arising out
 * of or in connection with the use or performance of this software.
 *
*)

(** Signature for interfaces to compilers. **)
signature COMPILER =
sig
    (** The compiler interface's internal representation **)
    type t

    val name : string

    val empty : t

    val addSources : t -> string list -> t
    val addFFISources : t -> string list -> t
    val addLinkOpts : t -> string list -> t
    val addCFlags : t -> string -> t
    val setExportHeader : t -> string -> t
    val setOutput : t -> string -> t
    val setOption : t -> (string * string) -> t

    val generateFiles : t -> t
    val invoke : t -> unit
end

(** Implements common functionality that may be shared easily across compilers and tools. **)
structure ToolOpt =
struct
    fun exec s =
        let
            val _ = if (!Config.verbose) then
                        print (s ^ "\n") else ()
        in
            if OS.Process.isSuccess (OS.Process.system s) then ()
                else raise Fail ("Invoking command `" ^ s ^ "' failed")
        end
end
