{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      crane,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        inherit (pkgs) lib;

        rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        src = craneLib.cleanCargoSource ./.;

        commonArgs = {
          inherit src;
          strictDeps = true;
          buildInputs = [

          ];

        };

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        individualCrateArgs = commonArgs // {
          inherit cargoArtifacts;
          inherit (craneLib.crateNameFromCargoToml { inherit src; }) version;
        };

        fileSetForCrate =
          crate:
          lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./Cargo.toml
              ./Cargo.lock
              (craneLib.fileset.commonCargoSources ./crates/wruff)
            ];
          };

        wruff-bot = craneLib.buildPackage (
          individualCrateArgs
          // {
            src = fileSetForCrate ./crates/wruff-bot;
          }
        );

        wruff-api = craneLib.buildPackage (
          individualCrateArgs
          // {
            src = fileSetForCrate ./crates/wruff-api;
          }
        );
      in
      {
        checks = {
          inherit wruff-bot wruff-api;
        };

        packages = {
          inherit wruff-bot wruff-api;
          default = wruff-api;
        };

        devShells.default = craneLib.devShell {
          checks = self.checks.${system};
          packages = with pkgs; [
            bacon
            sqlx-cli
          ];
        };
      }
    );
}
