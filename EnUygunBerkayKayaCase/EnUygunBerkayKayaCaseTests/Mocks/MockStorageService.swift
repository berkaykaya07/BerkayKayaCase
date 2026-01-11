//
//  MockStorageService.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa
@testable import EnUygunBerkayKayaCase

final class MockStorageService: StorageServiceProtocol {
    
    var cart = BehaviorRelay<[CartItem]>(value: [])
    var favorites = BehaviorRelay<[Product]>(value: [])
    
    // Tracking flags for testing
    var addToCartCalled = false
    var removeFromCartCalled = false
    var clearCartCalled = false
    var addToFavoritesCalled = false
    var removeFromFavoritesCalled = false
    
    func addToCart(_ product: Product) {
        addToCartCalled = true
        var items = cart.value
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index] = CartItem(product: product, quantity: items[index].quantity + 1)
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        cart.accept(items)
    }
    
    func removeFromCart(productId: Int) {
        removeFromCartCalled = true
        var items = cart.value
        items.removeAll { $0.product.id == productId }
        cart.accept(items)
    }
    
    func updateCartItemQuantity(productId: Int, quantity: Int) {
        var items = cart.value
        if let index = items.firstIndex(where: { $0.product.id == productId }) {
            if quantity > 0 {
                items[index] = CartItem(product: items[index].product, quantity: quantity)
            } else {
                items.remove(at: index)
            }
        }
        cart.accept(items)
    }
    
    func clearCart() {
        clearCartCalled = true
        cart.accept([])
    }
    
    func addToFavorites(_ product: Product) {
        addToFavoritesCalled = true
        var items = favorites.value
        if !items.contains(where: { $0.id == product.id }) {
            items.append(product)
            favorites.accept(items)
        }
    }
    
    func removeFromFavorites(_ productId: Int) {
        removeFromFavoritesCalled = true
        var items = favorites.value
        items.removeAll { $0.id == productId }
        favorites.accept(items)
    }
    
    func isFavorite(_ productId: Int) -> Bool {
        return favorites.value.contains(where: { $0.id == productId })
    }
}
