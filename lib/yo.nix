# lib/yo.nix
{ self, lib, inputs, config }:

let
  # Returns a string of export lines from unique Yo defaults
  genYoEnvDefaults = ''
    ${lib.concatStringsSep "\n" (
      map (param:
        "export ${param.name}='${param.value}'"
      ) (
        lib.unique (map (p: {
          name = p.name;
          value = p.default;
        }) (
          builtins.filter (p: p.default != null)
            (lib.flatten (map (s: s.parameters) (lib.attrValues config.yo.scripts)))
        ))
      )
    )}
  '';
in
{
  inherit genYoEnvDefaults;
}
