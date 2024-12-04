[inlets](https://github.com/inlets/inlets) packaged with Nix.

**Nix Shell**
A nix-shell will temporarily modify your $PATH environment variable. This can be used to try a piece of software before deciding to permanently install it. 

```sh
$ nix shell github:welteki/inlets-nix
```

**Nix Profile**
Using `nix profile` permanently modifies a local profile of installed packages. This must be updated and maintained by the user in the same way as with a traditional package manager, foregoing many of the benefits that make Nix uniquely powerful. Using `nix shell` or a NixOS configuration is recommended instead. 

```sh
$ nix profile install github:welteki/inlets-nix
```
