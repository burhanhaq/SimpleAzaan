fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build the iPhone app with its Watch app, upload to TestFlight, and submit for external testing

Options: changelog:"What to test" internal_only:true build_only:true (sign and verify the .ipa, no upload)

### ios beta_distribute

```sh
[bundle exec] fastlane ios beta_distribute
```

Submit an already uploaded build for external testing, without rebuilding

Options: build_number:1 changelog:"What to test" (defaults to the latest build)

### ios beta_link

```sh
[bundle exec] fastlane ios beta_link
```

Print the public TestFlight link

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
