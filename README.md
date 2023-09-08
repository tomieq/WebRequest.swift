# WebRequest

WebRequest is Swift library for makink sync web requests. It has generic type so can work woth Codable structs/classes.

```swift
struct SampleDto {
    let id: Int
    let title: String
    let body: String
}
let response: WebRequest<SampleDto> = .get(url: "https://jsonplaceholder.typicode.com/todos/1")
```

Default timeout is 3 seconds, but you can override it with `WebRequestConfig` object:
```swift
WebRequestConfig.timeout = 5 // seconds
```

### Swift Package Manager
```
    
    dependencies: [
        .package(url: "https://github.com/tomieq/WebRequest.swift.git", .branch("master"))
    ],
    
    ...
    
    .executableTarget(
        name: "YourApp",
        dependencies: [
                       .product(name: "WebRequest", package: "WebRequest.swift")
                       ]),
```
