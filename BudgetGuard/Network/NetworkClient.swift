//
//  NetworkService.swift
//  BudgetGuard
//
//  Created by Igor Guryan on 17.07.2025.
//

import Foundation

public enum NetworkError: LocalizedError {
    case http(code: Int, message: String?)
    case decoding(Error)
    case encoding(Error)
    case noInternet
    case cancelled
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .http(let code, let message):
            return message ?? "Server returned status code \(code)"
        case .decoding:
            return "Не удалось обработать данные от сервера"
        case .encoding:
            return "Не удалось сформировать запрос к серверу"
        case .noInternet:
            return "Отсутствует подключение к Интернету"
        case .cancelled:
            return "Запрос был отменён"
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

public final class NetworkClient {
    
    private let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
    private let TOKEN = "dKrAP3HkxdxX2S6YGyoXScfX"
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    public init(
    ) {
        self.session = URLSession.shared

        let decoder = JSONDecoder()

        let isoWithFrac = ISO8601DateFormatter()
        isoWithFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container  = try decoder.singleValueContainer()
            let rawString  = try container.decode(String.self)

            if let date = isoWithFrac.date(from: rawString) { return date }
            if let date = isoPlain.date(from: rawString) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO‑8601 date: \(rawString)"
            )
        }
        self.jsonDecoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder = encoder
    }

    @discardableResult
    func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await request(endpoint,
                          body: Optional<EmptyBody>.none,
                          responseType: responseType)
    }

    @discardableResult
    func request<Body: Encodable, Response: Decodable>(
        _ endpoint: APIEndpoint,
        body: Body?,
        responseType: Response.Type = Response.self
    ) async throws -> Response {

        let url = try makeURL(for: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")

        if let body {
            do {
                request.httpBody = try await encode(body)
            } catch { throw NetworkError.encoding(error) }
        }

        let (data, urlResponse): (Data, URLResponse)
        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch let urlErr as URLError {
            switch urlErr.code {
            case .notConnectedToInternet, .networkConnectionLost: throw NetworkError.noInternet
            case .cancelled: throw NetworkError.cancelled
            default: throw NetworkError.unknown(urlErr)
            }
        } catch { throw NetworkError.unknown(error) }

        guard let http = urlResponse as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "InvalidResponse", code: 0))
        }

        guard (200..<300).contains(http.statusCode) else {
            throw await makeHTTPError(code: http.statusCode, data: data)
        }
        if Response.self == EmptyBody.self && data.isEmpty {
            guard let result = EmptyBody() as? Response else {
                throw NetworkError.decoding(NSError(
                    domain: "TypeMismatch",
                    code: 0,
                    userInfo:
                        [NSLocalizedDescriptionKey:
                            "Failed to cast EmptyBody to expected response type."]
                ))
            }
            return result
        }

        do {
            if let raw = String(data: data, encoding: .utf8) {
                print("\(http.statusCode) \(endpoint.path)\n\(raw)")
            }
            return try await decode(Response.self, from: data)
        } catch { throw NetworkError.decoding(error) }
    }

    private func makeURL(for endpoint: APIEndpoint) throws -> URL {
        var comp = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )
        comp?.queryItems = endpoint.queryItems
        guard let url = comp?.url else { throw URLError(.badURL) }
        return url
    }

    private func encode<E: Encodable>(_ value: E) async throws -> Data {
        try await Task.detached(priority: .userInitiated) { [encoder = jsonEncoder] in
            try encoder.encode(value)
        }.value
    }

    private func decode<D: Decodable>(_ type: D.Type, from data: Data) async throws -> D {
        try await Task.detached(priority: .userInitiated) { [decoder = jsonDecoder] in
            try decoder.decode(type, from: data)
        }.value
    }

    private func makeHTTPError(code: Int, data: Data) async -> NetworkError {
        if let backendError = try? await decode(ErrorResponse.self, from: data) {
            return .http(code: code, message: backendError.message)
        } else {
            let msg = String(data: data, encoding: .utf8)
            return .http(code: code, message: msg)
        }
    }
}

public struct EmptyBody: Codable, Equatable {}

public struct ErrorResponse: Decodable {
    public let message: String?
}
