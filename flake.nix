{
  inputs = {
    nixpkgs.url = "nixpkgs/23.11";
    utils.url = "github:numtide/flake-utils";
    gitstatus.url = "github:puqeko/gitstatus/nixify";
  };
  outputs = { self, nixpkgs, utils, gitstatus, ... }@inputs: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      p10k = pkgs.stdenv.mkDerivation {
        name = "p10k";
        buildInputs = [ pkgs.zsh ];
        propogatedBuildInputs = [ gitstatus ];
        src = pkgs.lib.sourceFilesBySuffices ./. [ ".zsh" ".zsh-theme" ];
        configurePhase = ''
          ln -vs ${gitstatus} gitstatus
        '';
        buildPhase = ''
          zsh -fc '
          for f in *.zsh-theme internal/*.zsh; do
            zcompile -R -- $f.zwc $f || exit;
          done
          ';
        '';
        installPhase = ''
          mkdir -p $out
          cp *.zsh-theme $out
          cp *.zwc $out
          mkdir -p $out/internal
          cp internal/*.zsh $out/internal
          cp internal/*.zwc $out/internal
          mkdir -p $out/config
          cp config/*.zsh $out/config
        '';
        inherit system;
      };
    in {
      defaultPackage = p10k;
      devShell = pkgs.mkShell {
        inputsFrom = [p10k];
      };
    }
  );
}
