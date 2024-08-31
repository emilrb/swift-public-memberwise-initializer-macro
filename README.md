# PublicMemberwiseInitializer Macro

`@PublicMemberwiseInitializer` is a Swift macro that automatically generates a public memberwise initializer for your structs. This simplifies the process of providing public initializers for types that have multiple properties, especially in cases where these types are numerous or subject to frequent changes.

## Problem Statement

In Swift, structs automatically receive an implicit memberwise initializer, but this initializer is restricted to internal or more restrictive access levels. When working on projects with hundreds of types, manually writing public initializers can become tedious and error-prone. This is particularly challenging when these types are maintained by third parties and subject to frequent automated changes.

## Solution

The `@PublicMemberwiseInitializer` macro addresses this issue by automatically generating a public memberwise initializer for any struct to which it is applied. This allows you to avoid the repetitive task of writing or otherwise generating these initializers yourself and ensures that all your types have consistent, publicly accessible initializers.

## Usage

To use the `@PublicMemberwiseInitializer` macro, simply annotate your struct with `@PublicMemberwiseInitializer`. The macro will automatically generate the public initializer for you.

### Example

Consider the following struct definition:

```swift
@PublicMemberwiseInitializer
public struct MyStruct {
    let myString: String
}
```

Without the macro, you would need to manually write a public initializer like this:


```swift
public struct MyStruct {
    let myString: String
    
    public init(myString: String) {
        self.myString = myString
    }
}
```
With @PublicMemberwiseInitializer, the initializer is automatically generated for you, saving time and reducing boilerplate code.

## Benefits

* Reduces Boilerplate: Automatically generates public initializers, eliminating the need for repetitive code.
* Consistency: Ensures that all structs have consistent, public initializers, reducing the risk of errors.
* Scalability: Particularly useful in large codebases with numerous types, or when working with code that is frequently modified by automated processes or third parties.

## Installation

To include this macro in your project, add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/emilrb/swift-public-memberwise-initializer-macro.git", from: "1.0.0")
]
```

## Contributing

Just open a PR.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
