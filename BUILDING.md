# Building SlowQuitApps locally

## Requirements

- Xcode (tested with 27.0 on macOS 27.0).
- An `Apple Development` certificate. A free Apple ID is enough: Xcode >
  Settings > Accounts > Manage Certificates... > **+** > Apple Development.

Sign with the same certificate every time. macOS ties the Accessibility
permission to the signature, so an ad-hoc build loses the permission on every
rebuild.

## Build

```
$ scripts/build-local.sh            # build and sign into ./build
$ scripts/build-local.sh --install  # also replace /Applications/SlowQuitApps.app and launch it
```

- `SIGN_IDENTITY` (default `Apple Development`, `-` for ad-hoc). Use the full
  name if you have more than one identity. If the script can't find the
  identity, it signs ad-hoc.
- `CONFIGURATION` (default `Release`).

The script sets `MACOSX_DEPLOYMENT_TARGET=12.0`, because current Xcode rejects
the project's `10.14`.

## Permissions

**Accessibility (required):** launch the app, then turn it on in System
Settings > Privacy & Security > Accessibility, and restart the app:

```
$ killall SlowQuitApps; open /Applications/SlowQuitApps.app
```

The app then hides from the Dock. To check it's running, use
`pgrep -l SlowQuitApps`. After you change certificates, reset the permission
and grant it again:

```
$ tccutil reset Accessibility com.dteoh.SlowQuitApps
```

**Launch at login (optional):** the app offers this on first run. Register it
from the copy in `/Applications`, because the helper finds the app by its path.
It uses the deprecated `SMLoginItemSetEnabled`, which hasn't been tested on
current macOS. If it fails, add the app in System Settings > General > Login
Items. To turn it off, run
`defaults write com.dteoh.SlowQuitApps disableAutostart -bool YES`.

## `sqa` helper

```
$ ln -s /Applications/SlowQuitApps.app/Contents/MacOS/sqa /usr/local/bin/sqa
```

Don't use `sqa install|update|uninstall`. They go through Homebrew and replace
your build.
