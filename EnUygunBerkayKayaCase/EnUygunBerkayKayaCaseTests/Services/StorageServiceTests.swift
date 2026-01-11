//
//  StorageServiceTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class StorageServiceTests: XCTestCase {
    
    var sut: StorageService!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()

        sut = StorageService.shared
        sut.clearCart()
        sut.cart.value.forEach { sut.removeFromCart(productId: $0.product.id) }
        sut.favorites.value.forEach { sut.removeFromFavorites($0.id) }
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {

        sut.clearCart()
        sut.favorites.value.forEach { sut.removeFromFavorites($0.id) }
        sut = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Cart Tests
    
    func testAddToCart_NewProduct() {
        // Given
        let product = Product.mock(id: 999)
        
        // When
        sut.addToCart(product)
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 1)
        XCTAssertEqual(cartItems?.first?.product.id, product.id)
        XCTAssertEqual(cartItems?.first?.quantity, 1)
    }
    
    func testAddToCart_ExistingProduct_IncreasesQuantity() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToCart(product)
        
        // When
        sut.addToCart(product)
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 1, "Should still be 1 unique product")
        XCTAssertEqual(cartItems?.first?.quantity, 2, "Quantity should increase")
    }
    
    func testRemoveFromCart() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToCart(product)
        
        // When
        sut.removeFromCart(productId: product.id)
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0)
    }
    
    func testUpdateCartItemQuantity() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToCart(product)
        
        // When
        sut.updateCartItemQuantity(productId: product.id, quantity: 5)
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.first?.quantity, 5)
    }
    
    func testUpdateCartItemQuantity_ZeroRemovesItem() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToCart(product)
        
        // When
        sut.updateCartItemQuantity(productId: product.id, quantity: 0)
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0, "Item should be removed when quantity is 0")
    }
    
    func testClearCart() {
        // Given
        sut.addToCart(Product.mock(id: 1))
        sut.addToCart(Product.mock(id: 2))
        
        // When
        sut.clearCart()
        let cartItems = try! sut.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0)
    }
    
    // MARK: - Favorites Tests
    
    func testAddToFavorites() {
        // Given
        let product = Product.mock(id: 999)
        
        // When
        sut.addToFavorites(product)
        let favorites = try! sut.favorites.toBlocking().first()
        
        // Then
        XCTAssertEqual(favorites?.count, 1)
        XCTAssertEqual(favorites?.first?.id, product.id)
    }
    
    func testAddToFavorites_Duplicate_DoesNotAdd() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToFavorites(product)
        
        // When
        sut.addToFavorites(product)
        let favorites = try! sut.favorites.toBlocking().first()
        
        // Then
        XCTAssertEqual(favorites?.count, 1, "Should not add duplicate")
    }
    
    func testRemoveFromFavorites() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToFavorites(product)
        
        // When
        sut.removeFromFavorites(product.id)
        let favorites = try! sut.favorites.toBlocking().first()
        
        // Then
        XCTAssertEqual(favorites?.count, 0)
    }
    
    func testIsFavorite_True() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToFavorites(product)
        
        // When
        let isFavorite = sut.isFavorite(product.id)
        
        // Then
        XCTAssertTrue(isFavorite)
    }
    
    func testIsFavorite_False() {
        // Given - no favorites
        
        // When
        let isFavorite = sut.isFavorite(999)
        
        // Then
        XCTAssertFalse(isFavorite)
    }
    
    // MARK: - Persistence Tests (Integration)
    
    func testCartPersistence() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToCart(product)
        
        // When - Simulate app restart by creating new instance
        let newService = StorageService()
        let cartItems = try! newService.cart.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 1, "Cart should persist")
        XCTAssertEqual(cartItems?.first?.product.id, product.id)
        
        // Cleanup
        newService.clearCart()
    }
    
    func testFavoritesPersistence() {
        // Given
        let product = Product.mock(id: 999)
        sut.addToFavorites(product)
        
        // When - Simulate app restart
        let newService = StorageService()
        let favorites = try! newService.favorites.toBlocking().first()
        
        // Then
        XCTAssertEqual(favorites?.count, 1, "Favorites should persist")
        XCTAssertEqual(favorites?.first?.id, product.id)
        
        // Cleanup
        newService.removeFromFavorites(product.id)
    }
}
