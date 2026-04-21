## [1.0.3](https://github.com/ionic-team/ion-ios-camera/compare/1.0.2...1.0.3) (2026-04-21)


### Bug Fixes

* build IONCameraLib as a dynamic framework to prevent SwiftUICore crash on iOS 15/16 ([123ba38](https://github.com/ionic-team/ion-ios-camera/commit/123ba380ba06720bb9885c5706f225c6602cf4bf))

## [1.0.2](https://github.com/ionic-team/ion-ios-camera/compare/1.0.1...1.0.2) (2026-04-20)


### Bug Fixes

* **spm:** revert IONCameraLibShim — unsafeFlags are blocked in remote SPM dependencies ([f1b24e5](https://github.com/ionic-team/ion-ios-camera/commit/f1b24e53cc46ca44dbb0c5eb9114cfe25c470021))

## [1.0.1](https://github.com/ionic-team/ion-ios-camera/compare/1.0.0...1.0.1) (2026-04-20)


### Bug Fixes

* **ci:** remove npm cache from release workflow ([666219e](https://github.com/ionic-team/ion-ios-camera/commit/666219e169c3b2dab8773c20216b1de0986b66aa))
* weak-link SwiftUICore to restore iOS 15/16 compatibility ([#14](https://github.com/ionic-team/ion-ios-camera/issues/14)) ([dab3312](https://github.com/ionic-team/ion-ios-camera/commit/dab3312832dd4ce95b77fd6ed4ff2c013a7a84a1))

## 1.0.0 (2026-04-10)


### Features
- Add complete implementation, including `takePhoto`, `recordVideo`, `cleanTemporaryFiles`, `editPhoto`, `chooseFromGallery` and `playVideo`.
- Create repository.
