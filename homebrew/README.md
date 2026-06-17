# Homebrew distribution

`Casks/sparkbar.rb` is the canonical Homebrew Cask for SparkBar. To make
`brew install --cask hokore-dev/tap/sparkbar` work, publish it through a tap:

1. **Create the tap repo** (one time):

   ```bash
   gh repo create Hokore-Dev/homebrew-tap --public \
     --description "Homebrew tap for SparkBar"
   ```

2. **Add the cask** to that repo at `Casks/sparkbar.rb` (copy this file).

3. **On every release**, update `version` and `sha256` to match the published
   `SparkBar.zip`. The release workflow already prints the checksum:

   ```bash
   shasum -a 256 SparkBar.zip
   ```

Users then install with:

```bash
brew install --cask hokore-dev/tap/sparkbar
```

> Once the project is popular enough (typically 75+ stars and a stable
> release cadence), it can be submitted to `homebrew/cask` proper so users can
> skip the tap and just run `brew install --cask sparkbar`.
