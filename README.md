# O-Week v3.2

#### Contents
  - [About](#about)
  - [Getting Started](#getting-started)
  - [Dependencies & Libraries](#dependencies--libraries)
  - [Screenshots](#screenshots)
  - [Contributors](#contributors)

## About
An **iOS** app for incoming freshmen to use during their first week as a Cornell student. The **Android** branch can be found [here](https://github.com/cornell-dti/o-week-android).

## Getting Started
You will need **Xcode 9.4.1** to run the latest version of this app, which uses Swift 4 compiled for iOS 11.4. Xcode can be downloaded from the Mac App Store. Make sure you are not running a beta version of macOS, as Apple will prevent you from publishing to the App Store if you do.

## Design Choices
 * Document every function and at the start of every class/enum/protocol. [Here](http://nshipster.com/swift-documentation) are the guidelines for documentation.
 * Syntax:
   * Indent with tabs.
   * Put curly braces on a new line, like so:
   ```swift
   if (blah)
   {
      doSomething()
      doSomethingElse()
   }
   ```
   * If a statement fits in a single line, curly braces don't have to go on a new line, like so:
   ```swift
   if (blah) {
      doSomething();
   }
   ```
   This is especially true for <code>get</code> and <code>guard</code> statements, where the curly braces aren't allowed to be on a new line.
   * ClassesShouldBeNamedLikeThis, as should enums and protocols. (upper camel case)
   * functionsShouldBeNamedLikeThis, as should non-static variables or let constants. (lower camel case)
   * STATIC_VARS_SHOULD_BE_NAMED_LIKE_THIS, as should any let constants (or variables whose values shouldn't be changed).
 
## Dependencies & Libraries
Unlike Android, which manages its dependencies through Gradle, iOS requires CocoaPods and the editing of the Podfile in the main project directory. If you don't have CocoaPods installed on your computer, follow the instructions [here](https://cocoapods.org/) under the tabs **Install** and **Get Started**.
 * [PureLayout](https://github.com/PureLayout/PureLayout) is a set of extensions added unto UIView to make setting programmatic constraints easy and readable.
 * [PKHUD](https://github.com/pkluz/PKHUD) is an implementation of **Heads Up Displays** in iOS, used like Toasts in Android to provide feedback for user actions.
 
## Screenshots

_Screenshots showing major parts of app_

<img src="https://raw.githubusercontent.com/cornell-dti/o-week-ios/master/Resources/1.PNG" width="250px" style="margin: 10px; border: 1px rgba(0,0,0,0.4) solid;"> <img src="https://raw.githubusercontent.com/cornell-dti/o-week-ios/master/Resources/2.PNG" width="250px" style="margin: 10px; border: 1px rgba(0,0,0,0.4) solid;"> <img src="https://raw.githubusercontent.com/cornell-dti/o-week-ios/master/Resources/3.PNG" width="250px" style="margin: 10px; border: 1px rgba(0,0,0,0.4) solid;">

## Contributors
2018
 * **David Chu** - Developer Lead

2017
 * **David Chu** - Product Manager
 
2016
 * **David Chu** - Front-End Developer
 * **Vicente Caycedo** - Front-End Developer
 
We are a team within **Cornell Design & Tech Initiative**. For more information, see its website [here](http://cornelldti.org/).
<img src="https://raw.githubusercontent.com/cornell-dti/design/master/Branding/Wordmark/Dark%20Text/Transparent/Wordmark-Dark%20Text-Transparent%403x.png">
