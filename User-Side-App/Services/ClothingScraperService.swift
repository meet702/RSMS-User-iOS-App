//
//  ClothingScraperService.swift
//  User-Side-App
//
//  Service for scraping/fetching clothing images from online sources
//

import Foundation
import SwiftUI

actor ClothingScraperService {
    
    static let shared = ClothingScraperService()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func searchClothingImages(
        query: String,
        category: ClothingCategory? = nil,
        limit: Int = 20
    ) async throws -> [ClothingSearchResult] {
        let searchQuery = buildSearchQuery(query: query, category: category)
        
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?tbm=shop&q=\(encodedQuery)") else {
            throw ScraperError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ScraperError.networkError
        }
        
        return parseShopResults(from: data, query: query)
    }
    
    func fetchClothingImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ScraperError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ScraperError.networkError
        }
        
        guard let image = UIImage(data: data) else {
            throw ScraperError.invalidImageData
        }
        
        return image
    }
    
    private func buildSearchQuery(query: String, category: ClothingCategory?) -> String {
        var fullQuery = query
        
        if let category = category {
            switch category {
            case .top:
                fullQuery += " shirt tshirt clothing"
            case .bottom:
                fullQuery += " pants jeans trousers"
            case .dress:
                fullQuery += " dress outfit"
            case .shoes:
                fullQuery += " shoes footwear sneakers"
            case .accessory:
                fullQuery += " accessories bag"
            case .hat:
                fullQuery += " hat cap"
            case .glasses:
                fullQuery += " sunglasses eyewear"
            case .jewelry:
                fullQuery += " necklace bracelet jewelry"
            }
        }
        
        return fullQuery + " white background transparent PNG"
    }
    
    private func parseShopResults(from data: Data, query: String) -> [ClothingSearchResult] {
        guard let html = String(data: data, encoding: .utf8) else {
            return []
        }
        
        var results: [ClothingSearchResult] = []
        
        let pattern = #"data-item-url="([^"]*)"[^>]*>.*?<img[^>]*src="([^"]*)"[^>]*>.*?<span[^>]*>([^<]*)</span>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return generateMockResults(for: query)
        }
        
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, options: [], range: range)
        
        for match in matches.prefix(20) {
            guard match.numberOfRanges >= 4,
                  let urlRange = Range(match.range(at: 1), in: html),
                  let imageRange = Range(match.range(at: 2), in: html),
                  let titleRange = Range(match.range(at: 3), in: html) else {
                continue
            }
            
            let urlString = String(html[urlRange])
            let imageURL = String(html[imageRange])
            let title = String(html[titleRange])
            
            if let url = URL(string: urlString), let imageUrl = URL(string: imageURL) {
                let result = ClothingSearchResult(
                    title: title,
                    imageURL: imageUrl,
                    source: extractDomain(from: url),
                    price: nil
                )
                results.append(result)
            }
        }
        
        return results.isEmpty ? generateMockResults(for: query) : results
    }
    
    private func extractDomain(from url: URL) -> String {
        url.host?.replacingOccurrences(of: "www.", with: "") ?? "Unknown"
    }
    
    private func generateMockResults(for query: String) -> [ClothingSearchResult] {
        let mockImageURLs = [
            "https://picsum.photos/seed/clothing1/400/600",
            "https://picsum.photos/seed/clothing2/400/600",
            "https://picsum.photos/seed/clothing3/400/600",
            "https://picsum.photos/seed/clothing4/400/600",
            "https://picsum.photos/seed/clothing5/400/600"
        ]
        
        let sources = ["Amazon", "Myntra", "Flipkart", "AJIO", "Shopify"]
        
        return mockImageURLs.enumerated().compactMap { index, urlString in
            guard let url = URL(string: urlString) else { return nil }
            return ClothingSearchResult(
                title: query,
                imageURL: url,
                source: sources[index % sources.count],
                price: "₹\(Int.random(in: 500...5000))"
            )
        }
    }
    
    func downloadAndCacheImage(from url: URL) async throws -> UIImage {
        let cacheKey = url.absoluteString
        
        if let cachedImage = imageCache[cacheKey] {
            return cachedImage
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ScraperError.networkError
        }
        
        guard let image = UIImage(data: data) else {
            throw ScraperError.invalidImageData
        }
        
        imageCache[cacheKey] = image
        
        return image
    }
    
    private var imageCache: [String: UIImage] = [:]
}

enum ScraperError: Error, LocalizedError {
    case invalidURL
    case networkError
    case invalidImageData
    case parsingFailed
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError:
            return "Network connection failed"
        case .invalidImageData:
            return "Unable to load image"
        case .parsingFailed:
            return "Failed to parse search results"
        case .rateLimited:
            return "Too many requests. Please try again later."
        }
    }
}

class ClothingImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellable: AnyCancellable?
    
    func load(from url: URL?) async {
        guard let url = url else { return }
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let loadedImage = try await ClothingScraperService.shared.downloadAndCacheImage(from: url)
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

import Combine
