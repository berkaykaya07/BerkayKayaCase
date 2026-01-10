//
//  ProductService.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift

protocol ProductServiceProtocol {
    func fetchProducts(limit: Int, skip: Int, sortBy: String?, order: String?) -> Observable<ProductResponse>
    func fetchProductDetail(id: Int) -> Observable<ProductDetailResponse>
    func searchProducts(query: String, sortBy: String?, order: String?) -> Observable<ProductResponse>
    func fetchCategories() -> Observable<[Category]>
    func fetchCategoryList() -> Observable<[String]>
    func fetchProductsByCategory(category: String) -> Observable<ProductResponse>
}

final class ProductService: ProductServiceProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchProducts(limit: Int, skip: Int, sortBy: String? = nil, order: String? = nil) -> Observable<ProductResponse> {
        return apiClient.request(.products(limit: limit, skip: skip, sortBy: sortBy, order: order))
    }
    
    func fetchProductDetail(id: Int) -> Observable<ProductDetailResponse> {
        return apiClient.request(.productDetail(id: id))
    }
    
    func searchProducts(query: String, sortBy: String? = nil, order: String? = nil) -> Observable<ProductResponse> {
        return apiClient.request(.searchProducts(query: query, sortBy: sortBy, order: order))
    }
    
    func fetchCategories() -> Observable<[Category]> {
        return apiClient.request(.categories)
    }
    
    func fetchCategoryList() -> Observable<[String]> {
        return apiClient.request(.categoryList)
    }
    
    func fetchProductsByCategory(category: String) -> Observable<ProductResponse> {
        return apiClient.request(.productsByCategory(category: category))
    }
}
