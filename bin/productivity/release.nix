# dotfiles/bin/productivity/release.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo = {
    scripts = {
      release = {
        description = "Bumps project version & commit, tag, and push to Git.";
        category = "⚡ Productivity";
        parameters = [
          { name = "confirm"; description = "Rquire confirmation"; optional = false; default = true; type = "bool"; } 
        ];
        code = ''
          ${cmdHelpers}
          CONFIRM="$confirm"
          
          # get info from /.git.
          # ...

# Determine which version manifests exist
#HAS_CARGO=0
#HAS_PYPROJECT=0
#HAS_FLAKE=0

#[ -f "Cargo.toml" ] && HAS_CARGO=1
#[ -f "pyproject.toml" ] && HAS_PYPROJECT=1
#[ -f "flake.nix" ] && HAS_FLAKE=1

# At least one primary manifest must exist
#if [ $HAS_CARGO -eq 0 ] && [ $HAS_PYPROJECT -eq 0 ]; then
#    echo "Error: No Cargo.toml or pyproject.toml found. Cannot determine current version."
#    exit 1
#fi

# Read current version from primary source
#current_version=""
#if [ $HAS_CARGO -eq 1 ]; then
    # Extract version from Cargo.toml (format: version = "x.y.z")
#    current_version=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/' | head -1)
#elif [ $HAS_PYPROJECT -eq 1 ]; then
    # Extract version from pyproject.toml (format: version = "x.y.z")
#    current_version=$(grep '^version =' pyproject.toml | sed 's/version = "\(.*\)"/\1/' | head -1)
#fi

#if [ -z "$current_version" ]; then
#    echo "Error: Could not extract version from manifest."
#    exit 1
#fi

#echo "Current version: $current_version"

# If both manifests exist, verify they have the same version
#if [ $HAS_CARGO -eq 1 ] && [ $HAS_PYPROJECT -eq 1 ]; then
#    cargo_version=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/' | head -1)
#    py_version=$(grep '^version =' pyproject.toml | sed 's/version = "\(.*\)"/\1/' | head -1)
#    if [ "$cargo_version" != "$py_version" ]; then
#        echo "Error: Version mismatch: Cargo.toml ($cargo_version) vs pyproject.toml ($py_version)"
#        exit 1
#    fi
#fi

# Bump patch version
#IFS='.' read -r major minor patch <<< "$current_version"
#new_patch=$((patch + 1))
#new_version="$major.$minor.$new_patch"
#echo "New version: $new_version"

# Update Cargo.toml if present
#if [ $HAS_CARGO -eq 1 ]; then
#    sed -i.bak "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
#    rm Cargo.toml.bak
#    echo "Updated Cargo.toml"
#fi

# Update pyproject.toml if present
#if [ $HAS_PYPROJECT -eq 1 ]; then
#    sed -i.bak "s/^version = \".*\"/version = \"$new_version\"/" pyproject.toml
#    rm pyproject.toml.bak
#    echo "Updated pyproject.toml"
#fi

# Update flake.nix if present
#if [ $HAS_FLAKE -eq 1 ]; then
#    sed -i.bak "s/version = \".*\";/version = \"$new_version\";/" flake.nix
#    rm flake.nix.bak
#    echo "Updated flake.nix"
#fi

# Stage files that were modified
#[ $HAS_CARGO -eq 1 ] && git add Cargo.toml
#[ $HAS_PYPROJECT -eq 1 ] && git add pyproject.toml
#[ $HAS_FLAKE -eq 1 ] && git add flake.nix

#git commit -m "Bump version to $new_version"
#git tag "v$new_version"

# Push to origin (main branch)
#git push origin main --tags

#echo "Released version $new_version"
          
          # if $CONFIRM == true prompt user for confirmation
              
          # 🦆 says ⮞ success message displaying version
#          echo -e "\n\033[38;5;213m╔══════════════════════════════════════╗"
#          echo -e "║  🎉  \033[1;32mSuccessfully pushed dotfiles!\033[0m  \033[38;5;213m ║"
#          echo -e "╚══════════════════════════════════════╝\033[0m"
#          echo -e "\033[38;5;87m🌍 Repository: $REPO\033[0m"
#          echo -e "\033[38;5;154m🌿 Branch: $CURRENT_BRANCH\033[0m\n"
        '';
      };
    };
    
  };}
