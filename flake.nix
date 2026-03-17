{
  description = "build containerd-shim-wasmtime-v1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
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

      containerd-shim-wasmtime-v1 = rustPlatform.buildRustPackage rec {
        pname = "runwasi";
        version = "0-unstable-2026-03-02";
        doCheck = false;
        src = pkgs.fetchurl {
          url = "https://github.com/containerd/runwasi/archive/refs/heads/main.tar.gz";
          hash = "sha256-2QeDkfOlKSJHzPg1pP9G49HuF2S6vRIHGit8XsbHPYw=";
        };

        cargoHash = "sha256-lsiCdfxQ0BpavoV1ar0yXPa/16AgDl31umoBCguPowE=";

        buildAndTestSubdir = ".";

        cargoBuildFlags = [
          "--bin"
          "containerd-shim-wasmtime-v1"
        ];

        nativeBuildInputs = with pkgs; [
          protobuf
          pkg-config
          dbus-glib
          libelf
          libseccomp
          libclang
          zstd
          openssl_3
          cmake
          gnumake
          gcc
        ];

        CMAKE_POLICY_VERSION_MINIMUM = 3.5;

        LIBCLANG_PATH = pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            libclang
          ]
        );
        WASMEDGE_STANDALONE_ARCHIVE = "${wasmedgeArchive}";

        buildInputs = with pkgs; [
          systemd
          dbus-glib
          libelf
          libseccomp
          libclang
          zstd
          openssl_3
        ];

      };
    in
    {
      packages.${system}.default = containerd-shim-wasmtime-v1;

    };
}
