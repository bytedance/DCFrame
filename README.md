<p align="center">
  <img src="./Guides/Images/title.png" alt="title" width="800" />
</p>


<p align="center">
    <a href="https://travis-ci.org/github/bytedance/DCFrame">
        <img src="https://travis-ci.org/bytedance/DCFrame.svg?branch=master"
             alt="CI Status">
    </a>
    <a href="https://cocoapods.org/pods/DCFrame">
      <img src="https://img.shields.io/cocoapods/v/DCFrame.svg?style=flat"
           alt="Version" />
    </a>
    <a href="https://cocoapods.org/pods/DCFrame">
        <img src="https://img.shields.io/cocoapods/l/DCFrame.svg?style=flat"
             alt="License">
    </a>
    <a href="https://cocoapods.org/pods/DCFrame">
        <img src="https://img.shields.io/cocoapods/p/DCFrame.svg?style=flat"
             alt="Platform">
    </a>
</p>

------

DCFrame is a UI combination frame, it can be easily achieved:

1. Assemble and manage complex UI modules; 
2. Reuse and migrate UI modules at no cost;
3. Communication between UI modules without coupling.

## Requirements

* Xcode 10.2+
* iOS 9.0+
* Swift 5.0+

## Installation

### Cocoapods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate DCFrame into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'DCFrame' ~> 1.0.7
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate DCFrame into your Xcode project using Carthage, specify it in your `Cartfile`:

```ruby
github "bytedance/DCFrame" ~> 1.0.7
```

## Guides

We can quickly get started with DCFrame through the following guides:

* [Simple List](./Guides/1_simple_list.md): How to create a simple list through DCFrame;
* [Post List](./Guides/2_post_list.md): Through this example we learn to create a more complex combination list;
* [Module Communication](./Guides/3_module_communication.md)：How to perform module event and data sharing in the post list;
* [More Examples](https://github.com/bytedance/DCFrame/tree/master/Example): We provide more examples, simply pull the git repo and run 'DCFrame.xcworkspace' in the 'Example' folder. 

## License

DCFrame is available under the MIT license. See the LICENSE file for more info.
