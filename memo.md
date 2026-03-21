## build

```bash
nix build
```

## how to use runwasi 

- ref
    - [Runwasi Developer Documentation:Installation](https://runwasi.dev/getting-started/installation.html)

```bash
sudo ctr run --rm --runtime=io.containerd.wasmtime.v1 ghcr.io/containerd/runwasi/wasi-demo-app:latest testwasm
[sudo] password for aki: 
ctr: failed to start shim: failed to resolve runtime path: runtime "io.containerd.wasmtime.v1" binary not installed "containerd-shim-wasmtime-v1": file does not exist
```
