#! /usr/bin/env bash

version=$1

echo 'x86_64-linux'
nix hash file $(nix-prefetch-url https://github.com/inlets/inlets-pro/releases/download/$version/inlets-pro --type sha256 --print-path | awk 'NR==2')

echo 'x86_64-darwin'
nix hash file $(nix-prefetch-url https://github.com/inlets/inlets-pro/releases/download/$version/inlets-pro-darwin --type sha256 --print-path | awk 'NR==2')

echo 'aarch64-linux'
nix hash file $(nix-prefetch-url https://github.com/inlets/inlets-pro/releases/download/$version/inlets-pro-arm64 --type sha256 --print-path | awk 'NR==2')

echo 'aarch64-darwin'
nix hash file $(nix-prefetch-url https://github.com/inlets/inlets-pro/releases/download/$version/inlets-pro-darwin-arm64 --type sha256 --print-path | awk 'NR==2')
