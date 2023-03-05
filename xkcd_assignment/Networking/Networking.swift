//
//  Networking.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import Foundation

enum Endpoint {
    case latestComic
    case withNum(comicNum: Int)
    
    var url: URL? {
        switch self {
        case .latestComic:
            return generateURL()
        case .withNum(let comicNum):
            return generateURL(withNum: "/\(comicNum)")
        }
    }
    
    private func generateURL(withNum comicNum: String = "") -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "xkcd.com"
        components.path = comicNum + "/info.0.json"
        return components.url
    }
}

enum APIError: Error {
    case network(description: String)
    case parsing
    case badURL
}


class ComicAPI {
    
    static let shared = ComicAPI()
    
    private let urlSession = URLSession.shared

    private init() {}

    func getLatestComic() async throws -> Comic {
        guard let url = Endpoint.latestComic.url else { throw APIError.badURL }
        return try await fetchComic(from: url)
    }

    func getComic(withNum comicNum: Int) async throws -> Comic {
        guard let url = Endpoint.withNum(comicNum: comicNum).url else { throw APIError.badURL }
        return try await fetchComic(from: url)
    }

}

private extension ComicAPI {
    
    func fetchComic(from url: URL) async throws -> Comic {
        do {
            let (data, _) = try await urlSession.data(from: url)
            return try decodeComic(from: data)
        } catch {
            throw APIError.network(description: "Failed to receive data: \(error)")
        }
    }

    func decodeComic(from data: Data) throws -> Comic {
        do {
            return try JSONDecoder().decode(Comic.self, from: data)
        } catch {
            throw APIError.parsing
        }
    }
}
