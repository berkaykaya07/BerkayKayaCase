//
//  TestHelpers.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import Foundation
@testable import EnUygunBerkayKayaCase

extension Product {
    static func mock(
        id: Int = 1,
        title: String = "Test Product",
        description: String = "Test description",
        price: Double = 99.99,
        discountPercentage: Double = 10.0,
        rating: Double = 4.5,
        stock: Int = 10,
        brand: String = "Test Brand",
        category: String = "test",
        thumbnail: String = "https://test.com/image.jpg",
        images: [String] = ["https://test.com/image.jpg"]
    ) -> Product {
        return Product(
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
    
    static func mockList(count: Int = 5) -> [Product] {
        return (1...count).map { index in
            Product.mock(
                id: index,
                title: "Product \(index)",
                price: Double(index * 100)
            )
        }
    }
}

extension CartItem {
    static func mock(
        product: Product = .mock(),
        quantity: Int = 1
    ) -> CartItem {
        return CartItem(product: product, quantity: quantity)
    }
}
