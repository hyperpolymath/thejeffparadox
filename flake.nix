# Nix Flake - RSR Compliant
# Provides reproducible development environment
{
  description = "The Jeff Paradox - LLM diachronic identity experiment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Julia
            julia_19

            # Hugo
            hugo

            # Container tools
            podman
            podman-compose

            # Task runner
            just

            # Linters
            shellcheck
            yamllint
            markdownlint-cli2

            # Security
            trivy
            trufflehog

            # Git
            git
            git-cliff

            # Utilities
            jq
            yq-go
            curl
            wget
          ];

          shellHook = ''
            echo "The Jeff Paradox - Development Environment"
            echo "Run 'just --list' to see available tasks"
          '';
        };

        # Package the container
        packages.container = pkgs.callPackage ./container { };
      }
    );
}
