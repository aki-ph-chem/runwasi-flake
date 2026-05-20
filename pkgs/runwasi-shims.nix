{
  lib,
  fetchurl,
  rustPlatform,
  runwasi-src,

  protobuf,
  pkg-config,
  cmake,
  llvmPackages,
  systemd,
  dbus-glib,
  libelf,
  libseccomp,
  zstd,
  openssl_3,
}:
let
  wasmedgeArchive = fetchurl {
    url = "https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-fmt-patch-debian11_x86_64_static.tar.gz";
    sha256 = "sha256-CuSU8OJR1/4bB+QhoZic4qnyvzKEHOMIbfwI7xjJ/Pg=";
  };
  makeShim =
    {
      binName,
      cargoHash,
      extraBuildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
    }:
    rustPlatform.buildRustPackage {
      pname = "runwasi";
      version = "0-unstable-2026-03-02";
      src = runwasi-src;
      inherit cargoHash;

      doCheck = false;
      buildAndTestSubdir = ".";
      cargoBuildFlags = [
        "--bin"
        binName
      ];

      nativeBuildInputs = [
        protobuf
        pkg-config
        cmake
        llvmPackages.clang
      ]
      ++ extraNativeBuildInputs;

      CMAKE_POLICY_VERSION_MINIMUM = 3.5;
      LIBCLANG_PATH = lib.makeLibraryPath [
        llvmPackages.libclang
      ];
      WASMEDGE_STANDALONE_ARCHIVE = "${wasmedgeArchive}";

      buildInputs = [
        systemd
        dbus-glib
        libelf
        libseccomp
        zstd
        openssl_3
      ]
      ++ extraBuildInputs;

    };
in
{
  containerd-shim-wasmtime-v1 = makeShim {
    binName = "containerd-shim-wasmtime-v1";
    cargoHash = "sha256-lsiCdfxQ0BpavoV1ar0yXPa/16AgDl31umoBCguPowE=";

  };
}
