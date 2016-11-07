# TBUIAutoTest

Generating UI test label automatically.

## Articles

[为 UIAutomation 添加自动化测试标签的探索](http://yulingtianxia.com/blog/2016/03/28/Add-UITest-Label-for-UIAutomation/)

## Installation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate TBUIAutoTest into your Xcode project using CocoaPods, specify it in your `Podfile`:


```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
target 'MyApp' do
	pod 'TBUIAutoTest'
end
```

You need replace "MyApp" with your project's name.

Then, run the following command:

```bash
$ pod install
```

<!--### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TBUIAutoTest into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "yulingtianxia/TBUIAutoTest"
```

Run `carthage update` to build the framework and drag the built `TBUIAutoTestKit.framework` into your Xcode project.-->

### Manual

Just drag the "TBUIAutoTest" document folder into your project.

## Usage

Turn on TBUIAutoTest:

```
[[NSUserDefaults standardUserDefaults] registerDefaults:@{kAutoTestUIKey: @(YES)}];
[[NSUserDefaults standardUserDefaults] synchronize];
```

Turn off showing infomation when long press view:

```
[TBUIAutoTest sharedInstance].longPressEnabled = NO;
```