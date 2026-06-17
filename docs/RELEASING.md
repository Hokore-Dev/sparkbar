# Releasing SparkBar

SparkBar is distributed as a **signed and notarized** macOS app so users can
open it with a normal double-click — no Gatekeeper right-click dance.

The release pipeline (`.github/workflows/release.yml`) runs on every `v*` tag.
It is **dormant until you add the Apple secrets below**: without them the build
falls back to an ad-hoc signature and skips notarization.

## One-time setup

### 1. Enroll in the Apple Developer Program

Notarization requires a paid **Apple Developer Program** membership ($99/year).
Enroll at <https://developer.apple.com/programs/>. Note your **Team ID**
(10-char string, e.g. `AB12CD34EF`) from the membership page.

### 2. Create a Developer ID Application certificate

In Xcode → Settings → Accounts → Manage Certificates → **+** →
**Developer ID Application**, or via the developer portal. Then export it as a
`.p12`:

- Keychain Access → My Certificates → right-click the
  *Developer ID Application: …* cert → **Export** → save as `cert.p12` with a
  password.
- The signing identity string is the full certificate name, e.g.
  `Developer ID Application: Your Name (AB12CD34EF)`. Find it with:

  ```bash
  security find-identity -v -p codesigning
  ```

### 3. Create an App Store Connect API key (for notarytool)

App Store Connect → Users and Access → **Integrations / Keys** → **+**.
Give it the **Developer** role. Download the `AuthKey_XXXXXXXX.p8` (only
downloadable once). Record the **Key ID** and the team's **Issuer ID** (UUID
shown above the key list).

### 4. Add the GitHub repository secrets

Settings → Secrets and variables → Actions → **New repository secret**:

| Secret name            | Value                                                                 |
| ---------------------- | --------------------------------------------------------------------- |
| `MACOS_CERT_P12`       | base64 of `cert.p12` → `base64 -i cert.p12 \| pbcopy`                  |
| `MACOS_CERT_PASSWORD`  | the password you set when exporting the `.p12`                        |
| `MACOS_SIGN_IDENTITY`  | `Developer ID Application: Your Name (TEAMID)`                        |
| `AC_API_KEY_ID`        | the App Store Connect Key ID                                          |
| `AC_API_ISSUER_ID`     | the App Store Connect Issuer ID (UUID)                                |
| `AC_API_KEY_P8`        | base64 of the `.p8` → `base64 -i AuthKey_XXXX.p8 \| pbcopy`           |

> If any of these are missing the workflow still succeeds, but the artifact is
> only ad-hoc signed (Gatekeeper will warn users).

## Cutting a release

```bash
# 1. Bump the version in app/Info.plist (CFBundleShortVersionString) and,
#    if needed, homebrew/Casks/sparkbar.rb.
# 2. Tag and push.
git tag v1.1.0
git push origin v1.1.0
```

The workflow builds, signs, notarizes, staples, and publishes a GitHub Release
with `SparkBar.zip` attached, and prints its SHA-256.

## Updating the Homebrew tap

The cask lives in a separate tap repo, **`Hokore-Dev/homebrew-tap`**, at
`Casks/sparkbar.rb`. After a release:

1. Copy the new `version` and the printed `sha256` into the tap's
   `Casks/sparkbar.rb` (the canonical copy is `homebrew/Casks/sparkbar.rb`
   in this repo).
2. Commit & push the tap.

Users then get the update with:

```bash
brew upgrade --cask sparkbar
```
