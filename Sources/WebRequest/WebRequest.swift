import Foundation

public struct WebRequestConfig {
    public static var timeout: TimeInterval = 3
}

public enum WebRequest<T: Codable> {
    case failure(HttpError)
    case response(T)

    // MARK: sync functions
    public static func get(url: String, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "GET", headers: headers)
    }

    public static func post(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "POST", body: body.data, headers: headers)
    }

    public static func put(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "PUT", body: body.data, headers: headers)
    }

    public static func delete(url: String, body: Codable, headers: [String: String]? = nil) -> WebRequest<T> {
        Self.run(url: url, method: "DELETE", body: body.data, headers: headers)
    }

    // MARK: async functions

    public static func get(url: String, headers: [String: String]? = nil, callback: @escaping (WebRequest<T>) -> Void) {
        _ = Self.run(url: url, method: "GET", headers: headers, callback: callback)
    }

    public static func post(url: String, body: Codable, headers: [String: String]? = nil, callback: @escaping (WebRequest<T>) -> Void) {
        _ = Self.run(url: url, method: "POST", body: body.data, headers: headers, callback: callback)
    }

    public static func put(url: String, body: Codable, headers: [String: String]? = nil, callback: @escaping (WebRequest<T>) -> Void) {
        _ = Self.run(url: url, method: "PUT", body: body.data, headers: headers, callback: callback)
    }

    public static func delete(url: String, body: Codable, headers: [String: String]? = nil, callback: @escaping (WebRequest<T>) -> Void) {
        _ = Self.run(url: url, method: "DELETE", body: body.data, headers: headers, callback: callback)
    }

    private static var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    private static func run(url: String, method: String, body: Data? = nil, headers: [String: String]? = nil) -> WebRequest<T> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: WebRequest?
        let task = self.run(url: url, method: method, body: body, headers: headers) {
            result = $0
            semaphore.signal()
        }
        let waitResult = semaphore.wait(timeout: .now() + .seconds(Int(WebRequestConfig.timeout)))
        if case .timedOut = waitResult {
            print("Request timed out")
            task?.cancel()
            return .failure(.timeoutError)
        }
        return result ?? .failure(.other)
    }

    private static func run(url: String,
                            method: String,
                            body: Data? = nil,
                            headers: [String: String]? = nil,
                            callback: @escaping (WebRequest<T>) -> Void) -> URLSessionDataTask? {
        print("\(method) \(url)")
        guard let url = URL(string: url) else {
            callback(.failure(.invalidUrl))
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = {
            var allHeaders = Self.defaultHeaders
            for (key, value) in headers ?? [:] {
                allHeaders[key] = value
            }
            return allHeaders
        }()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = WebRequestConfig.timeout
        config.timeoutIntervalForResource = WebRequestConfig.timeout
        let task = URLSession(configuration: config).dataTask(with: request) { data, response, error in
            if let error = error as? NSError {
                let httpError = HttpError.make(from: error.code)
                callback(.failure(httpError))
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                callback(.failure(.other))
                return
            }
            if statusCode >= 200, statusCode < 300 {
                if let json = data, let response = try? T(json: json) {
                    callback(.response(response))
                } else {
                    callback(.failure(.unserializablaResponse(data)))
                }
            } else {
                let body = String(data: data ?? Data(), encoding: .utf8)
                callback(.failure(.invalidHttpCode(code: statusCode, body: body)))
            }
        }
        task.resume()
        return task
    }
}
