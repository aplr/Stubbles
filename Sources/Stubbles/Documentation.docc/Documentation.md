# ``Stubbles``

Stubbles is a declarative HTTP stubbing library written in Swift that makes testing your HTTP requests a breeze on all platforms.

## Overview

Stubbles provides structures for declaring HTTP requests as well as their respective responses when testing your Swift app or framework. It intercepts all outgoing HTTP requests, matches them with your declared stub requests, and responds to them.

## Installation

Stubbles is available via the [Swift Package Manager](https://swift.org/package-manager/) which is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system and automates the process of downloading, compiling, and linking dependencies.

Once you have your Swift package set up, adding Stubbles as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(
        url: "https://github.com/aplr/Stubbles.git",
        .upToNextMajor(from: "0.0.1")
    )
]
```

## License

Stubbles is licensed under the [MIT License](https://github.com/aplr/Stubbles/blob/main/LICENSE).


<!--## Topics-->
<!---->
<!--### Documentation-->
<!---->
<!--- <doc:Advanced>-->
<!--- <doc:Combine>-->
