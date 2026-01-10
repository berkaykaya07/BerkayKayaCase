//
//  APIError.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int)
    case noData
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
