# Creating a Swift 3 CocoaPod

## Installation

Uninstalled and reinstalled **cocoapods**.

Installed **xcpretty** gem to enhance output of command line builds:

```sh
gem install xcpretty
```

## Configuration

Changed **osx_image** setting in **.travis.yml** to point to `xcode8` instead of `xcode7.3`

```
osx_image: xcode8
```

To fix Travis build, in Xcode Build Settings, set `Use Legacy Swift Language Version` to **NO**.

## Git repo

Some **.gitignore** file somewhere is excluding either the `xcshareddata` or `xcshemes` directory, so I had to manually add the **xcscheme** file:

```sh
git add -f <xcscheme file name>
```

## Fixing Local Command-Line Builds

### Issue: Compiler warnings and errors for Swift 3 syntax and APIs.

Use **xcode-select** to temporarily switch toolchains:

```sh
sudo xcode-select --switch /Applications/Xcode-beta.app
```

### Issue: A build only device cannot be used to run this target. 

Add the following parameter to your xcodebuild or xctool command:

```sh
-destination 'platform=iOS Simulator,name=iPhone 6,OS=10.0'
```

...and dropped the version number from the sdk parameter:

```sh
-sdk iphonesimulator 
```