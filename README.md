![SplitKit Title](https://raw.githubusercontent.com/macteo/SplitKit/master/Assets/Export/splitkit-title.png)

# SplitKit

User resizable split view to accommodate two view controllers for iOS.

[![License MIT](https://img.shields.io/cocoapods/l/SplitKit.svg)](https://raw.githubusercontent.com/macteo/splitkit/master/LICENSE) [![Version](https://img.shields.io/cocoapods/v/SplitKit.svg)](https://cocoapods.org/?q=splitkit) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![travis-ci](https://travis-ci.org/macteo/SplitKit.svg?branch=master)](https://travis-ci.org/macteo/SplitKit)
[![codecov.io](https://codecov.io/github/macteo/SplitKit/coverage.svg?branch=master)](https://codecov.io/github/macteo/SplitKit?branch=master)
![Swift 4](https://img.shields.io/badge/language-Swift%204-EB7943.svg) ![iOS 9+](https://img.shields.io/badge/iOS-9+-EB7943.svg)

## Description

Resizable split view that accommodates two view controllers for iOS.

Heavily inspired by the Swift Playgrounds app for iPad, _SplitKit_ gives you the ability to easily present two `UIView`s side by side (or stacked one on top of the other) baked by different `UIViewControllers`. Everything is implemented in a single _.swift_ file to easily drop it in in existing projects. CocoaPods, Carthage and plain Dynamic Framework are supported as well for your convenience. The end user has the ability to resize the views just dragging the separator like each macOS counterpart, when the drag is performed a convenient handle appears to highlight the resizing operation. If the separator is really close to one of the edges, it will snap to it with an enjoyable animation and the handle won't disappear to highlight the hidden view position.

![SplitKit GIF](https://raw.githubusercontent.com/macteo/splitkit/master/Assets/GIFs/splitkit.gif)

## Features

- [x] Horizontal and vertical layouts: one beside the other and one on top of the other.
- [x] Customizable separator and handle: choose the color you prefer to match your app style.
- [x] Draggable handle to resize the views on the fly.
- [x] Snap to the closest edge.
- [x] Automatically keyboard dismiss if the keyboard top margin is crossed while resizing.
- [x] Support iOS 9 leveraging `topLayoutGuide` and `bottomLayoutGuide` through iOS 11 and the new `safeAreaLayoutGuide`.
- [x] Swift 4 ready.
- [x] Inception: nest multiple split controllers one inside the other.
- [x] Example with iOS 11 Drag&Drop support.
- [x] Objective-C compatible.
- [ ] Comprehensive Tests.

## Requirements

- iOS 9.0+
- Xcode 9.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.0.0+ is required to build SplitKit.

To integrate SplitKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'SplitKit'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install [Carthage](https://github.com/Carthage/Carthage) with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SplitKit into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "macteo/SplitKit"
```

Run `carthage update --platform iOS` to build the framework and drag the built `SplitKit.framework` into your Xcode project.

### Dynamic Framework

Add the *SplitKit* Xcode project to your own. Then add the `SplitKit` framework as desired to the embedded binaries of your app's target.

## Usage

In this repository you can find a sample project with few lines of code in the `ViewController` class for a jumpstart.

*Sample code is written in Objective-C, if you find an incompatibility please open an issue. Swift apps are obviously supported too.*

### Integration

Import *SplitKit* modules into your Swift class

```swift
import SplitKit
```

or if you are writing in Objective-C

```objc
@import SplitKit;
```

> Keep in mind the you have to let the project generate the Bridging Header otherwise the integration may fail.

```objc
SPKSplitViewController *splitController = [[SPKSplitViewController alloc] init];
[self addChildViewController:splitController];
splitController.view.frame = self.view.bounds;
splitController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
[self.view addSubview:splitController.view];
[splitController didMoveToParentViewController:self];
splitController.arrangement = SPKArrangementHorizontal;
```

Customize the appearance as desired.
You can use SplitKit directly from a Storyboard.

Enjoy.

## Acknowledgements

* Matteo Gavagnin – [@macteo](https://twitter.com/macteo)

## License

SplitKit is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/macteo/SplitKit/master/LICENSE) for details.
