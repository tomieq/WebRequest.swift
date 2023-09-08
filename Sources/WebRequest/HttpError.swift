//
//  HttpError.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

public enum HttpError: Error, Equatable {
    case invalidUrl
    case unserializablaResponse
    case noInternet
    case timeoutError
    case serverIsDown
    case dnsError
    case sslError
    case invalidHttpCode(code: Int, body: String?)
    case other
}

extension HttpError {
    static func make(from NSUrlError: Int) -> HttpError {
        var httpError = HttpError.other
        switch NSUrlError {
        case NSURLErrorTimedOut:
            httpError = HttpError.timeoutError
        case NSURLErrorServerCertificateUntrusted,
             NSURLErrorServerCertificateHasBadDate,
             NSURLErrorServerCertificateHasUnknownRoot,
             NSURLErrorServerCertificateNotYetValid,
             NSURLErrorSecureConnectionFailed:
            httpError = HttpError.sslError
        case NSURLErrorCannotFindHost,
             NSURLErrorDNSLookupFailed:
            httpError = HttpError.dnsError
        case NSURLErrorCannotConnectToHost:
            httpError = HttpError.serverIsDown
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost:
            httpError = HttpError.noInternet
        default:
            httpError = HttpError.other
        }
        print("Mapped NSUrlError(\(NSUrlError)) into \(httpError)")
        return httpError
    }
}
