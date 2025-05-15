{ 
  config,
  yo,
  ...
} : let
  enabled = yo.helpers.enableFeature "caddy";
in {
  # ... module logic
}
