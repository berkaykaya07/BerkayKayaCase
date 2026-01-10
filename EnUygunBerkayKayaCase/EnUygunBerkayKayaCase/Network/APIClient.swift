//
//  APIClient.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Observable<T>
}

final class APIClient: APIClientProtocol {
    
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger.shared
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        
        // Configure timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.timeout
        configuration.timeoutIntervalForResource = Constants.API.timeout
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(APIError.unknown)
                return Disposables.create()
            }
            
            guard let url = endpoint.url() else {
                self.logger.error("Invalid URL for endpoint: \(endpoint)")
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            
            // Log request
            self.logger.logRequest(url: url, method: "GET")
            
            let startTime = Date()
            
            let task = self.session.dataTask(with: url) { data, response, error in
                let duration = Date().timeIntervalSince(startTime)
                
                if let error = error {
                    self.logger.error("Network error", error: error)
                    self.logger.logResponse(url: url, statusCode: 0, data: nil, error: error)
                    observer.onError(APIError.networkError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.logger.error("Invalid response")
                    observer.onError(APIError.invalidResponse)
                    return
                }
                
                // Log response
                self.logger.logResponse(url: url, statusCode: httpResponse.statusCode, data: data)
                self.logger.info("⏱️ Request completed in \(String(format: "%.2f", duration))s")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.logger.error("Server error with status code: \(httpResponse.statusCode)")
                    observer.onError(APIError.serverError(statusCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    self.logger.error("No data received")
                    observer.onError(APIError.noData)
                    return
                }
                
                do {
                    let decodedObject = try self.decoder.decode(T.self, from: data)
                    self.logger.success("Successfully decoded \(T.self)")
                    observer.onNext(decodedObject)
                    observer.onCompleted()
                } catch {
                    self.logger.error("Decoding error for \(T.self)", error: error)
                    observer.onError(APIError.decodingError(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
                self.logger.warning("Request cancelled: \(url)")
            }
        }
    }
}
