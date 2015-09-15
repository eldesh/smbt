(* vim: set et ts=4: *)
(* Smbt, an SML build tool
 *  Copyright (c) 2012-2015 Filip Sieczkowski, Gian Perrone & Sunrin SHIMURA
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

structure SMLSharpCompiler :> COMPILER =
struct
    open CompilerUtil 
    val modTime = OS.FileSys.modTime
    val name = "SML#"

    fun compileOne smlsharp src out smlflags =
      if Time.<(modTime out, modTime src)
         handle SysErr => true
      then let
          val command = (String.concatWith " " [smlsharp, smlflags, "-c", src, "-o", out])
          val () = print (command ^ "\n")
          val () = exec command
      in
          true
      end
      else false

    fun outFileOf src = if String.isSuffix ".sml" src
                        then (String.substring(src, 0,String.size src - 4)) ^ ".o"
                        else if String.isSuffix ".c" src
                        then (String.substring(src, 0,String.size src - 2)) ^ ".o"
                        else raise Fail (src ^ " isn't sml file")

    fun compile (srcs,ffisrcs,lnkopts,cflags,hdr,opts) =
        let
            val _ = print " - Invoking SML#\n"
            val lnkopts = String.concatWith " " lnkopts
            val cflags  = String.concatWith " " cflags
            val smlsharp = case selectOpt opts "smlsharp" of
                SOME t => t
              | NONE => "smlsharp"

            val cc = case selectOpt opts "cc" of
                SOME t => t
              | NONE => "cc"

            val smlflags = case selectOpt opts "smlflags" of
                               SOME t => t
                             | NONE => ""
                                        
            fun compileWith cmd sources flags = List.map (fn src => let
                                                              val outFile = outFileOf src
                                                          in
                                                              compileOne cmd src outFile flags
                                                          end) sources
            val _ = print (" - Compiling\n")
            val resSml = compileWith smlsharp srcs smlflags
            val resC   = compileWith cc ffisrcs cflags
            val _ = case selectOpt opts "output" of
                        NONE => ()
                      | SOME output => let
                          val entry = case selectOpt opts "entry" of
                                          SOME t => t
                                        | NONE  => raise Fail "SML# requires entry point interface file to output executable file"
                          val _ = print (" - Linking\n")
                          val objs = String.concatWith " " (List.map outFileOf ffisrcs)
                          val _ = if List.exists (fn x => x) (resSml @ resC)
                                  then exec (String.concatWith " " [smlsharp, "-o", output, entry, objs, lnkopts])
                                  else ()

                          val _ = print (" - Output: " ^ statFile output ^ "\n")
                      in
                          ()
                      end
        in
            ()
        end

    fun interactive (srcs,ffisrcs,lnkopts,cflags,hdr,opts) =
      let
          val _ = print "interactive mode under SML# is incomplete. Project files won't be loaded.\n"
          val _ = print " - Invoking SML# (interactive)\n"
          val smlsharp = case selectOpt opts "smlsharp" of
                             SOME t => t
                           | NONE => "smlsharp"

          val rlwrap = case selectOpt opts "rlwrap" of
                           SOME "true" => "rlwrap"
                         | _ => ""

          val cmd = String.concatWith " " [rlwrap, smlsharp]

          val _ = exec cmd

          val _ = print (" - Interactive session finished.\n")
      in
          ()
      end


end



