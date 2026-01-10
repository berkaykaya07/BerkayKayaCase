//
//  Product.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

// MARK: - Product Response
struct ProductResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Product
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]
    
    var discountedPrice: Double {
        price - (price * discountPercentage / 100)
    }
    
    var hasDiscount: Bool {
        discountPercentage > 0
    }
}

// MARK: - Product Detail Response
struct ProductDetailResponse: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]
    let reviews: [Review]?
    
    func toProduct() -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            price: price,
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            brand: brand,
            category: category,
            thumbnail: thumbnail,
            images: images
        )
    }
}

// MARK: - Review
struct Review: Codable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}
