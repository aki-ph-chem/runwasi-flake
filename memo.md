## build

```bash
nix build
```

## install to system

```nix
{
  inputs = {
    # ...
    # containerd-shim-wasmtime-v1
    containerd-shim-wasmtime-v1 = {
      url = "github:aki-ph-chem/runwasi-flake/feat/containerd-shim-wasmtime-v1";
    };
  };


  outputs = inputs @ {
   containerd-shim-wasmtime-v1,
    ...
  }: {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};

      virtualisation = {
        # cotainerd
        containerd = {
          enable = true;
        };
       # others 
      };

      systemd.services.containerd = {
        path = [
          containerd-shim-wasmtime-v1.packages.x86_64-linux.default
        ];
      };

    };
  }
}
```

## how to use runwasi 

- ref
    - [Runwasi Developer Documentation:Installation](https://runwasi.dev/getting-started/installation.html)

```bash
sudo ctr run --rm --runtime=io.containerd.wasmtime.v1 ghcr.io/containerd/runwasi/wasi-demo-app:latest testwasm
[sudo] password for aki: 
ctr: failed to start shim: failed to resolve runtime path: runtime "io.containerd.wasmtime.v1" binary not installed "containerd-shim-wasmtime-v1": file does not exist
```
