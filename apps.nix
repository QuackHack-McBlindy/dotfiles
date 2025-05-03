# apps.nix
{ self, ... }: {
  edit = self.apps.${system}.yo-edit;
}
