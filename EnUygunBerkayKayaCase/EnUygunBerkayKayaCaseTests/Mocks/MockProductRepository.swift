//
//  MockProductRepository.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
@testable import EnUygunBerkayKayaCase

final class MockProductRepository: ProductRepositoryProtocol {
    
    var mockProducts: [Product] = []
    var mockError: Error?
    var mockCategories: [String] = ["smartphones", "laptops", "fragrances"]
    
    var getProductsCalled = false
    var getProductDetailCalled = false
    var searchProductsCalled = false
    var getCategoriesCalled = false
    var getProductsByCategoryCalled = false
    
    func getProducts(limit: Int, skip: Int, sortBy: String?, order: String?) -> Observable<[Product]> {
        getProductsCalled = true
        if let error = mockError {
            return .error(error)
        }
        let start = skip
        let end = min(skip + limit, mockProducts.count)
        let result = Array(mockProducts[start..<end])
        return .just(result)
    }
    
    func getProductDetail(id: Int) -> Observable<Product> {
        getProductDetailCalled = true
        if let error = mockError {
            return .error(error)
        }
        if let product = mockProducts.first(where: { $0.id == id }) {
            return .just(product)
        }
        return .error(NSError(domain: "Test", code: 404, userInfo: nil))
    }
    
    func searchProducts(query: String, sortBy: String?, order: String?) -> Observable<[Product]> {
        searchProductsCalled = true
        if let error = mockError {
            return .error(error)
        }
        let filtered = mockProducts.filter { $0.title.lowercased().contains(query.lowercased()) }
        return .just(filtered)
    }
    
    func getCategories() -> Observable<[String]> {
        getCategoriesCalled = true
        if let error = mockError {
            return .error(error)
        }
        return .just(mockCategories)
    }
    
    func getProductsByCategory(category: String) -> Observable<[Product]> {
        getProductsByCategoryCalled = true
        if let error = mockError {
            return .error(error)
        }
        let filtered = mockProducts.filter { $0.category == category }
        return .just(filtered)
    }
}
