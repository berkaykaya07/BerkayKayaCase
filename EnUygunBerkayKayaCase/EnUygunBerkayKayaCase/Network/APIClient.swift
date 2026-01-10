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
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(APIError.networkError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(APIError.invalidResponse)
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(APIError.serverError(statusCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(APIError.noData)
                    return
                }
                
                do {
                    let decodedObject = try self.decoder.decode(T.self, from: data)
                    observer.onNext(decodedObject)
                    observer.onCompleted()
                } catch {
                    observer.onError(APIError.decodingError(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
