//
//  CartViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class CartViewModelTests: XCTestCase {
    
    var sut: CartViewModel!
    var mockStorageService: MockStorageService!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        sut = CartViewModel(storageService: mockStorageService)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        mockStorageService = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialCartIsEmpty() {
        // When
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0, "Initial cart should be empty")
    }
    
    func testInitialTotalIsZero() {
        // When
        let total = try! sut.totalPrice.toBlocking().first()
        
        // Then
        XCTAssertEqual(total, 0.0, "Initial total should be zero")
    }
    
    func testInitialIsEmptyIsTrue() {
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == true, "Initial isEmpty should be true")
    }
    
    // MARK: - Add to Cart Tests
    
    func testAddToCart() {
        // Given
        let product = Product.mock()
        
        // When
        mockStorageService.addToCart(product)
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 1)
        XCTAssertEqual(cartItems?.first?.product.id, product.id)
        XCTAssertEqual(cartItems?.first?.quantity, 1)
    }
    
    // MARK: - Update Quantity Tests
    
    func testUpdateQuantityIncrease() {
        // Given
        let product = Product.mock(id: 1)
        mockStorageService.addToCart(product)
        
        // When
        sut.updateQuantity.onNext((productId: product.id, quantity: 3))
        
        // Wait a bit for async operation
        Thread.sleep(forTimeInterval: 0.1)
        
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.first?.quantity, 3)
    }
    
    func testUpdateQuantityDecrease() {
        // Given
        let product = Product.mock(id: 1)
        mockStorageService.addToCart(product)
        mockStorageService.updateCartItemQuantity(productId: product.id, quantity: 5)
        
        // When
        sut.updateQuantity.onNext((productId: product.id, quantity: 2))
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.first?.quantity, 2)
    }
    
    // MARK: - Remove Item Tests
    
    func testRemoveItem() {
        // Given
        let product = Product.mock(id: 1)
        mockStorageService.addToCart(product)
        
        // When
        sut.removeItem.onNext(product.id)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0)
        XCTAssertTrue(mockStorageService.removeFromCartCalled)
    }
    
    // MARK: - Total Price Tests
    
    func testTotalPriceCalculationWithSingleItem() {
        // Given
        let product = Product.mock(price: 100, discountPercentage: 10) // $90
        mockStorageService.addToCart(product)
        
        // When
        let total = try! sut.totalPrice.toBlocking().first()
        
        // Then
        XCTAssertEqual(total ?? 0, 90.0, accuracy: 0.01)
    }
    
    func testTotalPriceCalculationWithMultipleItems() {
        // Given
        let product1 = Product.mock(id: 1, price: 100, discountPercentage: 10) // $90
        let product2 = Product.mock(id: 2, price: 200, discountPercentage: 0)  // $200
        mockStorageService.addToCart(product1)
        mockStorageService.addToCart(product2)
        
        // When
        let total = try! sut.totalPrice.toBlocking().first()
        
        // Then
        XCTAssertEqual(total ?? 0, 290.0, accuracy: 0.01)
    }
    
    func testTotalPriceWithQuantity() {
        // Given
        let product = Product.mock(price: 50, discountPercentage: 0) // $50
        mockStorageService.addToCart(product)
        mockStorageService.updateCartItemQuantity(productId: product.id, quantity: 3)
        
        // When
        let total = try! sut.totalPrice.toBlocking().first()
        
        // Then
        XCTAssertEqual(total ?? 0, 150.0, accuracy: 0.01)
    }
    
    // MARK: - Clear Cart Tests
    
    func testClearCart() {
        // Given
        mockStorageService.addToCart(Product.mock(id: 1))
        mockStorageService.addToCart(Product.mock(id: 2))
        
        // When
        sut.clearCart.onNext(())
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let cartItems = try! sut.cartItems.toBlocking().first()
        
        // Then
        XCTAssertEqual(cartItems?.count, 0)
        XCTAssertTrue(mockStorageService.clearCartCalled)
    }
    
    // MARK: - isEmpty Tests
    
    func testIsEmptyWhenCartEmpty() {
        // Given - empty cart
        
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == true)
    }
    
    func testIsNotEmptyWhenCartHasItems() {
        // Given
        mockStorageService.addToCart(Product.mock())
        
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == false)
    }
}
