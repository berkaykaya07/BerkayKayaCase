//
//  ProductService.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift

protocol ProductServiceProtocol {
    func fetchProducts(limit: Int, skip: Int) -> Observable<ProductResponse>
    func fetchProductDetail(id: Int) -> Observable<ProductDetailResponse>
    func searchProducts(query: String) -> Observable<ProductResponse>
    func fetchCategories() -> Observable<[Category]>
    func fetchCategoryList() -> Observable<[String]>
    func fetchProductsByCategory(category: String) -> Observable<ProductResponse>
}

final class ProductService: ProductServiceProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchProducts(limit: Int, skip: Int) -> Observable<ProductResponse> {
        return apiClient.request(.products(limit: limit, skip: skip))
    }
    
    func fetchProductDetail(id: Int) -> Observable<ProductDetailResponse> {
        return apiClient.request(.productDetail(id: id))
    }
    
    func searchProducts(query: String) -> Observable<ProductResponse> {
        return apiClient.request(.searchProducts(query: query))
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
