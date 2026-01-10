//
//  CartItem.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

struct CartItem: Codable, Identifiable {
    var id: Int { product.id }
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        product.discountedPrice * Double(quantity)
    }
    
    init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = quantity
    }
}
