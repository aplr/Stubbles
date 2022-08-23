# ``Stubbles``

Stubbles is a declarative HTTP stubbing library written in Swift, with support for iOS, tvOS, watchOS and macOS.

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

## Quick Start

This section provides you with a brief introduction on how ``Stubbles`` works and how you can use it to test your network requests.

### Intercepting requests

Stubbles works by intercepting every request made by your application. To start intercepting requests, call ``Stubbles/Stubbles/start()`` on Stubble's ``Stubbles/Stubbles/shared`` instance. If you want to stop intercepting requests, just call ``Stubbles/Stubbles/stop()``.

```swift
// Start intercepting requests
Stubbles.shared.start()

// - Register stubs ...
// - Run network requests ...
// - Run assertions ...

// Stop intercepting requests
Stubbles.shared.stop()
```

> Note: Stubbles exchanges the implementation of `URLSessionConfiguration.protocolClasses` during runtime, which is rather invasive. Make sure to include ``Stubbles`` only in your test targets and not submit it to the App Store, it *could* make reviewers angry.

### Registering stubs

After a request was intercepted, Stubbles tries to match it with every registered ``StubRequest`` by comparing their URL, method, headers and body. If a request was found, it uses it to build a mock response. Otherwise, it sends an empty response with status `200 OK` by default.

To declare and register a `StubRequest` at once, you can use ``Stubbles/Stubbles/stub(_:)``, which allows you to declaratively define a ``StubRequest`` which is automatically registered. It is the same as creating a ``StubRequest`` manually and registering it with ``Stubbles/Stubbles/register(stub:)``.

The example below registers a ``StubRequest`` which matches a `GET` request on `http://jsonplaceholder.typicode.com/todos/1`. `Stubbles` responds with a `200 OK` and the given `Todo`.

```swift
let stubRequest = Stubbles.shared.stub {
    Endpoint("http://jsonplaceholder.typicode.com/todos/1")
    StubResponse {
        StatusCode(200)
        JsonBody(Todo(id: 1, title: "Write Stubbles doc", completed: false))
    }
}
```

### Running network requests

Having set up the stubs, it is now time to run a network request. You can use any networking library as you like, as all of them make use of `UrlSessionConfiguration`, which we are intercepting.

### Running assertions

Each time a ``StubRequest`` is matched, a ``StubRequest/Call`` is filed, containing the underlying `URLRequest`. All calls are available on ``StubRequest/calls``, which you can use for assertions.

The code example below checks if the `stubRequest` we defined before was matched exactly once.

```swift
XCTAssertEqual(stubRequest.calls.count, 1, "Expected request to be sent exactly once.")
```

### Putting it all together

Having discussed all steps in detail, we can now have a look at the big picture. Usually, you will use `Stubbles` within your `XCTest` suite. To make sure requests are intercepted before running a test, call ``Stubbles/Stubbles/start()`` in the `setUp` function.

In order to reset all stubs and stop intercepting requests, put the call to ``Stubbles/Stubbles/stop()`` into the `tearDown` function.

You can find a simple test case in the code example down below. The `TodoApi.getTodo(id:)` does a simple network call using `UrlSession.shared.data(from:)` and returns the decoded `Todo`.

```swift
class ApiTest: XCTestCase {

    override func setUp() {
        // Register request interceptor
        Stubbles.shared.start()
        super.setUp()
    }

    override func tearDown() {
        // Unregister request interceptor
        Stubbles.shared.stop()
        super.tearDown()
    }
    
    func testGetTodo() async throws {
        // Arrange
        let todoApi = TodoApi()

        let expectedTodo = Todo(id: 1, title: "todo", completed: false)
        
        let stubRequest = Stubbles.shared.stub {
            Endpoint("https://jsonplaceholder.typicode.com/todos/1")
            StubResponse {
                StatusCode(200)
                JsonBody(expectedTodo)
            }
        }
        
        // Act
        let actualTodo = try await todoApi.getTodo(id: 1)
        
        // Assert
        XCTAssertEqual(expectedTodo, actualTodo)
        XCTAssertEqual(stubRequest.calls.count, 1, "Expected request to be sent exactly once.")
    }

}
```

## License

Stubbles is licensed under the [MIT License](https://github.com/aplr/Stubbles/blob/main/LICENSE).


<!--## Topics-->
<!---->
<!--### Documentation-->
<!---->
<!--- <doc:Advanced>-->
<!--- <doc:Combine>-->
