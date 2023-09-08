import Foundation

public struct WebRequestConfig {
    public static var timeout = 3
}

public enum WebRequest<T: Codable> {
    case error(HttpError)
    case response(T)

    public static func get(url: String) -> WebRequest<T> {
        Self.run(url: url, method: "GET")
    }

    public static func post(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "POST", body: body.data)
    }

    public static func put(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "PUT", body: body.data)
    }

    public static func delete(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "DELETE", body: body.data)
    }

    private static var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    private static func run(url: String, method: String, body: Data? = nil, headers: [String: String]? = nil) -> WebRequest<T> {
        var responseJson: Data?
        var responseError: HttpError?

        print("\(method) \(url)")
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: url) else {
            return .error(.invalidUrl)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = {
            var allHeaders = Self.defaultHeaders
            for (key, value) in headers ?? [:] {
                allHeaders[key] = value
            }
            return allHeaders
        }()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error as? NSError {
                let httpError = HttpError.make(from: error.code)
                responseError = httpError
                print("error: \(httpError)")
                semaphore.signal()
                return
            }
            responseJson = data
            semaphore.signal()
        }
        task.resume()

        let waitResult = semaphore.wait(timeout: .now() + .seconds(WebRequestConfig.timeout))
        if case .timedOut = waitResult {
            print("Request timed out")
            task.cancel()
            return .error(.timeoutError)
        }
        if let error = responseError {
            return .error(error)
        }
        if let json = responseJson, let response = try? T(json: json) {
            return .response(response)
        } else {
            return .error(.unserializablaResponse)
        }
    }
}
