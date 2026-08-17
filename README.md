# supaclank/homebrew-tap

Homebrew tap for [Clank](https://github.com/supaclank/clank).

```bash
brew install supaclank/tap/clank         # clank + clankd + clank-host (prebuilt, macOS)
brew install supaclank/tap/clank-voice   # optional push-to-talk engine (built from source)
```

## Layout

- `Casks/clank.rb` — **generated**; rewritten by goreleaser on every
  `v*` tag pushed to supaclank/clank (see its `.goreleaser.yaml` and
  `.github/workflows/release.yml`). Do not edit by hand.
- `Formula/clank-voice.rb` — hand-maintained. Builds `clank-voice` from
  the release's source tarball because its cgo sherpa-onnx dependency
  can't be shipped prebuilt. Bump `url` + `sha256` per release:

  ```bash
  ./scripts/bump-voice.sh v0.3.0
  ```
