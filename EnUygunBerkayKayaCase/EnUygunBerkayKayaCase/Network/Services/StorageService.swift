//
//  StorageService.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

protocol StorageServiceProtocol {
    var cart: BehaviorRelay<[CartItem]> { get }
    var favorites: BehaviorRelay<[Product]> { get }
    
    func addToCart(_ product: Product)
    func removeFromCart(productId: Int)
    func updateCartItemQuantity(productId: Int, quantity: Int)
    func clearCart()
    
    func addToFavorites(_ product: Product)
    func removeFromFavorites(_ productId: Int)
    func isFavorite(_ productId: Int) -> Bool
}

final class StorageService: StorageServiceProtocol {
    
    static let shared = StorageService()
    
    let cart = BehaviorRelay<[CartItem]>(value: [])
    let favorites = BehaviorRelay<[Product]>(value: [])
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = Logger.shared
    
    init() {
        loadCart()
        loadFavorites()
    }
    
    // MARK: - Cart Management
    
    func addToCart(_ product: Product) {
        var currentCart = cart.value
        
        if let index = currentCart.firstIndex(where: { $0.product.id == product.id }) {
            currentCart[index].quantity += 1
            logger.logStorage("Updated cart quantity for '\(product.title)' - new quantity: \(currentCart[index].quantity)")
        } else {
            currentCart.append(CartItem(product: product, quantity: 1))
            logger.logStorage("Added '\(product.title)' to cart")
        }
        
        cart.accept(currentCart)
        saveCart()
    }
    
    func removeFromCart(productId: Int) {
        var currentCart = cart.value
        if let item = currentCart.first(where: { $0.product.id == productId }) {
            logger.logStorage("Removed '\(item.product.title)' from cart")
        }
        currentCart.removeAll { $0.product.id == productId }
        cart.accept(currentCart)
        saveCart()
    }
    
    func updateCartItemQuantity(productId: Int, quantity: Int) {
        var currentCart = cart.value
        
        if let index = currentCart.firstIndex(where: { $0.product.id == productId }) {
            if quantity > 0 {
                currentCart[index].quantity = quantity
                logger.logStorage("Updated cart quantity for '\(currentCart[index].product.title)' to \(quantity)")
            } else {
                logger.logStorage("Removed '\(currentCart[index].product.title)' from cart (quantity = 0)")
                currentCart.remove(at: index)
            }
        }
        
        cart.accept(currentCart)
        saveCart()
    }
    
    func clearCart() {
        logger.logStorage("Cleared entire cart (\(cart.value.count) items)")
        cart.accept([])
        saveCart()
    }
    
    private func saveCart() {
        if let encoded = try? encoder.encode(cart.value) {
            userDefaults.set(encoded, forKey: Constants.StorageKey.cart)
            logger.logStorage("Cart saved to UserDefaults")
        }
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: Constants.StorageKey.cart),
           let decoded = try? decoder.decode([CartItem].self, from: data) {
            cart.accept(decoded)
            logger.logStorage("Cart loaded from UserDefaults (\(decoded.count) items)")
        }
    }
    
    // MARK: - Favorites Management
    
    func addToFavorites(_ product: Product) {
        var currentFavorites = favorites.value
        
        if !currentFavorites.contains(where: { $0.id == product.id }) {
            currentFavorites.append(product)
            favorites.accept(currentFavorites)
            saveFavorites()
            logger.logStorage("Added '\(product.title)' to favorites")
        }
    }
    
    func removeFromFavorites(_ productId: Int) {
        var currentFavorites = favorites.value
        if let product = currentFavorites.first(where: { $0.id == productId }) {
            logger.logStorage("Removed '\(product.title)' from favorites")
        }
        currentFavorites.removeAll { $0.id == productId }
        favorites.accept(currentFavorites)
        saveFavorites()
    }
    
    func isFavorite(_ productId: Int) -> Bool {
        return favorites.value.contains(where: { $0.id == productId })
    }
    
    private func saveFavorites() {
        if let encoded = try? encoder.encode(favorites.value) {
            userDefaults.set(encoded, forKey: Constants.StorageKey.favorites)
            logger.logStorage("Favorites saved to UserDefaults")
        }
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: Constants.StorageKey.favorites),
           let decoded = try? decoder.decode([Product].self, from: data) {
            favorites.accept(decoded)
            logger.logStorage("Favorites loaded from UserDefaults (\(decoded.count) items)")
        }
    }
}
