{ pkgs, lib, ... }:

let
  customGum = pkgs.gum.overrideAttrs (old: {
    # Use nativeBuildInputs instead of buildInputs for wrapper tools
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    
    # Proper post-install hook for wrapping
    postInstall = ''
      wrapProgram "$out/bin/gum" \
        ${lib.concatMapStringsSep " \\\n" (var: "--set-default ${var.name} '${var.value}'") [
          { name = "GUM_CHOOSE_CURSOR"; value = "🦆 ➤"; }
          { name = "GUM_CHOOSE_CURSOR_FOREGROUND"; value = "214"; }
          { name = "GUM_CHOOSE_HEADER"; value = "🦆 CHOOSE YOUR PICK!"; }
          { name = "GUM_CHOOSE_HEADER_FOREGROUND"; value = "45"; }
          { name = "GUM_CHOOSE_SELECTED_PREFIX"; value = "✅ "; }
          { name = "GUM_CHOOSE_UNSELECTED_PREFIX"; value = "⚪ "; }
          { name = "GUM_CHOOSE_CURSOR_PREFIX"; value = "🔥 "; }
          { name = "GUM_CHOOSE_ITEM_FOREGROUND"; value = "15"; }
          { name = "GUM_CHOOSE_SELECTED_FOREGROUND"; value = "46"; }
          { name = "GUM_CHOOSE_HEIGHT"; value = "12"; }
          { name = "GUM_CHOOSE_SHOW_HELP"; value = "true"; }
          { name = "GUM_CHOOSE_NO_LIMIT"; value = "true"; }
          # ... Add ALL your other variables in this pattern
        ]}
    '';
  });
in {
  environment.systemPackages = [ customGum ];
}
