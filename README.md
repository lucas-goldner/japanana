# Japanana - Japanese Grammar

A new Flutter project to learn Japanese grammar.

For running:

```bash
$ git submodule update --init --recursive
```

Run integration tests:

```bash
patrol test -t integration_test/patrol -d 'iPhone 15'

OR

patrol test -t integration_test/patrol -d 'iPhone 15' --no-uninstall
```

## iOS / macOS dependencies

Native plugins are integrated with **Swift Package Manager**. There is no
Podfile and CocoaPods is not used — `flutter build ios` and
`flutter build macos` resolve everything through SPM, with no `pod install`
step.

Swift Package Manager is enabled by default on Flutter stable, so this needs
no setup. If a build unexpectedly tries to run `pod install`, it means SPM has
been explicitly disabled on that machine; re-enable it with:

```bash
flutter config --enable-swift-package-manager
```
