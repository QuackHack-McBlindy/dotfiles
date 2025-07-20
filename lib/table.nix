# dotfiles/lib/table.nix
{ lib }:
let
  escapeMD = str: let
    replacements = [
      [ "\\" "\\\\" ]
      [ "*" "\\*" ]
      [ "`" "\\`" ]
      [ "_" "\\_" ]
      [ "[" "\\[" ]
      [ "]" "\\]" ]
      [ "<" "\\<" ]
      [ ">" "\\>" ]
      [ "|" "\\|" ]
    ];
  in lib.foldl (acc: r: lib.replaceStrings [ (builtins.elemAt r 0) ] [ (builtins.elemAt r 1) ] acc) str replacements;

  mkTable = {
    headers,
    rows,
    align ? [],
    escape ? true
  }:
  let
    process = if escape then escapeMD else (x: x);
    safeHeaders = map process headers;
    safeRows = map (map process) rows;
    
    alignments = if align != [] then align else lib.genList (lib.length headers) (_: "left");
    
    toPattern = a:
      if a == "left" then ":---"
      else if a == "center" then ":---:"
      else if a == "right" then "---:"
      else "---";
      
    alignmentRow = "| " + lib.concatStringsSep " | " (map toPattern alignments) + " |";
    
    formatRow = cells: "| " + lib.concatStringsSep " | " cells + " |";
  in
    formatRow safeHeaders + "\n" 
    + alignmentRow + "\n" 
    + lib.concatMapStringsSep "\n" formatRow safeRows;

in {
  inherit mkTable escapeMD;
}
