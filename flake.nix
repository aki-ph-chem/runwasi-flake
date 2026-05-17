{
  description = "build containerd-shim-wasmtime-v1 (x86_64-linux only)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    runwasi-src = {
      url = "github:containerd/runwasi?rev=cf51126b59adffc18538c839922125e74e512b0d";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      runwasi-src,
      flake-utils,
    }:

    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable."1.86.0".default.override {
          targets = [ "wasm32-wasip1" ];
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };

        shims = pkgs.callPackages ./pkgs/runwasi-shims.nix {
          inherit rustPlatform runwasi-src;
        };

      in
      {
        packages = shims // {
          default = shims.containerd-shim-wasmtime-v1;
        };
      }
    );
}
