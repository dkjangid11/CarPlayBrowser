# CarPlay Browser

An iOS app that shows a web browser (YouTube by default) on a CarPlay display. It uses a
`CPMapTemplate` for the CarPlay navigation entitlement and puts a `WKWebView` in the CarPlay window.

## Features

- Back, forward, reload and home buttons on the CarPlay map screen
- Resumes the last page when CarPlay reconnects
- Error page with retry when a page fails to load
- Home page is set from the phone app (CarPlay has no keyboard)

## Building

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open CarPlayBrowser.xcodeproj
```

Unsigned IPAs (for TrollStore) are built by the GitHub Actions workflow in `.github/workflows/build-ipa.yml`
and by `codemagic.yaml`. Both embed `CarPlayBrowser.entitlements` into the binary with `ldid`, because
an unsigned build would otherwise lose the `com.apple.developer.carplay-maps` entitlement.
