# Homebrew Cask for SparkBar.
#
# Source of truth lives here; copy/sync it into a tap repo named
# `Hokore-Dev/homebrew-tap` (path: Casks/sparkbar.rb) so users can run:
#
#     brew install --cask hokore-dev/tap/sparkbar
#
# `version` and `sha256` must match a published GitHub release asset
# (SparkBar.zip). The release workflow already prints the sha256 via
# `shasum -a 256 SparkBar.zip` — paste that value here on each release.
cask "sparkbar" do
  version "1.1.0"
  sha256 "REPLACE_WITH_RELEASE_ZIP_SHA256"

  url "https://github.com/Hokore-Dev/sparkbar/releases/download/v#{version}/SparkBar.zip"
  name "SparkBar"
  desc "Claude usage in the macOS menu bar — session & weekly limits, alerts"
  homepage "https://github.com/Hokore-Dev/sparkbar"

  depends_on macos: ">= :monterey"

  app "SparkBar.app"

  zap trash: [
    "~/Library/Preferences/com.hokore.sparkbar.plist",
  ]
end
