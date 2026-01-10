//
//  ProductRepository.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift

protocol ProductRepositoryProtocol {
    func getProducts(limit: Int, skip: Int, sortBy: String?, order: String?) -> Observable<[Product]>
    func getProductDetail(id: Int) -> Observable<Product>
    func searchProducts(query: String, sortBy: String?, order: String?) -> Observable<[Product]>
    func getCategories() -> Observable<[String]>
    func getProductsByCategory(category: String) -> Observable<[Product]>
}

final class ProductRepository: ProductRepositoryProtocol {
    
    private let productService: ProductServiceProtocol
    
    init(productService: ProductServiceProtocol = ProductService()) {
        self.productService = productService
    }
    
    func getProducts(limit: Int, skip: Int, sortBy: String? = nil, order: String? = nil) -> Observable<[Product]> {
        return productService.fetchProducts(limit: limit, skip: skip, sortBy: sortBy, order: order)
            .map { $0.products }
    }
    
    func getProductDetail(id: Int) -> Observable<Product> {
        return productService.fetchProductDetail(id: id)
            .map { $0.toProduct() }
    }
    
    func searchProducts(query: String, sortBy: String? = nil, order: String? = nil) -> Observable<[Product]> {
        return productService.searchProducts(query: query, sortBy: sortBy, order: order)
            .map { $0.products }
    }
    
    func getCategories() -> Observable<[String]> {
        return productService.fetchCategoryList()
    }
    
    func getProductsByCategory(category: String) -> Observable<[Product]> {
        return productService.fetchProductsByCategory(category: category)
            .map { $0.products }
    }
}
