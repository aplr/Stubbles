<h1>
    <img src="https://raw.githubusercontent.com/aplr/Stubbles/main/Logo.png" height="23" />
    Stubbles
</h1>

![Build](https://github.com/aplr/Stubbles/actions/workflows/test.yml/badge.svg?branch=main)
![Documentation](https://github.com/aplr/Stubbles/actions/workflows/docs.yml/badge.svg)

Stubbles is a declarative HTTP stubbing library written in Swift, with support for iOS, tvOS, watchOS and macOS.

## Installation

CodeKit is available via the [Swift Package Manager](https://swift.org/package-manager/) which is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system and automates the process of downloading, compiling, and linking dependencies.

Once you have your Swift package set up, adding Stubbles as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(
        url: "https://github.com/aplr/Stubbles.git",
        .upToNextMajor(from: "0.0.1")
    )
]
```

## Usage

```swift
class ApiTest: XCTestCase {
    override func setUp() {
        Stubbles.shared.start()
        super.setUp()
    }

    override func tearDown() {
        Stubbles.shared.stop()
        super.tearDown()
    }
    
    func testGetTodo() async throws {
        // Arrange
        let todoApi = TodoApi()
        
        let expectedTodo = Todo(id: 1, userId: 1, title: "todo", completed: false)
        
        let stub = Stubbles.shared.stub {
            Endpoint("https://jsonplaceholder.typicode.com/todos/1")
            StubResponse {
                StatusCode(201)
                JsonBody(expectedTodo)
            }
        }
        
        // Act
        let actualTodo = try await todoApi.getTodo(id: 1)
        
        // Assert
        XCTAssertEqual(expectedTodo, actualTodo)
        XCTAssertEqual(stub.calls.count, 1, "Expected request to be sent exactly once.")
    }
}
```

## Documentation

Documentation is available [here](https://stubbles.aplr.io/documentation/stubbles) and provides a comprehensive documentation of the library's public interface.

## License
Stubbles is licensed under the [MIT License](https://github.com/aplr/Stubbles/blob/main/LICENSE).
