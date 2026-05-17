{
  description = "build containerd-shim-wasmtime-v1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
    }:
    let
      system = "x86_64-linux";

      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };

      rustToolchain = pkgs.rust-bin.stable."1.86.0".default.override {
        targets = [ "wasm32-wasip1" ];
      };

      rustPlatform = pkgs.makeRustPlatform {
        cargo = rustToolchain;
        rustc = rustToolchain;
      };

      wasmedgeArchive = pkgs.fetchurl {
        url = "https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-fmt-patch-debian11_x86_64_static.tar.gz";
        sha256 = "sha256-CuSU8OJR1/4bB+QhoZic4qnyvzKEHOMIbfwI7xjJ/Pg=";
      };

      containerd-shim-wasmtime-v1 = rustPlatform.buildRustPackage {
        pname = "runwasi";
        version = "0-unstable-2026-03-02";
        src = runwasi-src;
        cargoHash = "sha256-lsiCdfxQ0BpavoV1ar0yXPa/16AgDl31umoBCguPowE=";

        doCheck = false;
        buildAndTestSubdir = ".";
        cargoBuildFlags = [
          "--bin"
          "containerd-shim-wasmtime-v1"
        ];

        nativeBuildInputs = [
          pkgs.protobuf
          pkgs.pkg-config
          pkgs.cmake
          pkgs.llvmPackages.clang
        ];

        CMAKE_POLICY_VERSION_MINIMUM = 3.5;
        LIBCLANG_PATH = pkgs.lib.makeLibraryPath ([
          pkgs.llvmPackages.libclang
        ]);
        WASMEDGE_STANDALONE_ARCHIVE = "${wasmedgeArchive}";

        buildInputs = [
          pkgs.systemd
          pkgs.dbus-glib
          pkgs.libelf
          pkgs.libseccomp
          pkgs.zstd
          pkgs.openssl_3
        ];

      };
    in
    {
      packages.${system}.default = containerd-shim-wasmtime-v1;

    };
}
