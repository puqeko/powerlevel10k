{
  inputs = {
    nixpkgs.url = "nixpkgs/23.11";
    utils.url = "github:numtide/flake-utils";
    gs.url = "github:puqeko/gitstatus/nixify";
  };
  outputs = { self, nixpkgs, utils, gs, ... }@inputs: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      gitstatus = gs.outputs.packages.${system}.default;
      p10k = pkgs.stdenv.mkDerivation {
        name = "p10k";
        buildInputs = [ pkgs.zsh ];
        propogatedBuildInputs = [ gitstatus ];
        src = pkgs.lib.sourceFilesBySuffices ./. [ ".zsh" ".zsh-theme" ];
        configurePhase = ''
          ln -vs ${gitstatus}/share/gitstatus gitstatus
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
          cp -v *.zsh-theme $out
          cp -v *.zwc $out
          mkdir -p $out/internal
          cp -v internal/*.zsh $out/internal
          cp -v internal/*.zwc $out/internal
          mkdir -p $out/config
          cp -v config/*.zsh $out/config
          ln -vs ${gitstatus}/share/gitstatus $out/gitstatus
        '';
        inherit system;
      };
    in {
      packages.default = p10k;
      devShell = pkgs.mkShell {
        inputsFrom = [p10k];
      };
    }
  );
}
