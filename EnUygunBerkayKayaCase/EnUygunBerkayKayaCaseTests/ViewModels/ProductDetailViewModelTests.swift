//
//  ProductDetailViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class ProductDetailViewModelTests: XCTestCase {
    
    var sut: ProductDetailViewModel!
    var mockStorageService: MockStorageService!
    var testProduct: Product!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        testProduct = Product.mock(id: 1, title: "Test Product")
        sut = ProductDetailViewModel(product: testProduct, storageService: mockStorageService)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        mockStorageService = nil
        testProduct = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_SetsProduct() {
        // Given - setup in setUp()
        
        // When
        let product = sut.product.value
        
        // Then
        XCTAssertEqual(product.id, testProduct.id)
        XCTAssertEqual(product.title, testProduct.title)
    }
    
    func testInit_IsFavoriteObservable() {
        // Given - not in favorites
        
        // When
        let isFavorite = try! sut.isFavorite.toBlocking().first()
        
        // Then
        XCTAssertFalse(isFavorite ?? true, "Should not be favorite initially")
    }
    
    func testInit_IsFavoriteObservable_WhenAlreadyFavorite() {
        // Given
        mockStorageService.addToFavorites(testProduct)
        
        // When
        sut = ProductDetailViewModel(product: testProduct, storageService: mockStorageService)
        let isFavorite = try! sut.isFavorite.toBlocking().first()
        
        // Then
        XCTAssertTrue(isFavorite ?? false, "Should be favorite")
    }
    
    // MARK: - Add to Cart Tests
    
    func testAddToCart() {
        // Given
        XCTAssertEqual(mockStorageService.cart.value.count, 0)
        
        // When
        sut.addToCart.onNext(())
        
        // Wait for async operation
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(mockStorageService.addToCartCalled)
        XCTAssertEqual(mockStorageService.cart.value.count, 1)
        XCTAssertEqual(mockStorageService.cart.value.first?.product.id, testProduct.id)
    }
    
    func testAddToCart_MultipleTimes_IncreasesQuantity() {
        // Given
        sut.addToCart.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Add again
        sut.addToCart.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertEqual(mockStorageService.cart.value.count, 1, "Should still be 1 unique product")
        XCTAssertEqual(mockStorageService.cart.value.first?.quantity, 2, "Quantity should be 2")
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavorite_Add() {
        // Given
        XCTAssertFalse(mockStorageService.isFavorite(testProduct.id))
        
        // When
        sut.toggleFavorite.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(mockStorageService.addToFavoritesCalled)
        XCTAssertTrue(mockStorageService.isFavorite(testProduct.id))
    }
    
    func testToggleFavorite_Remove() {
        // Given - Add to favorites first
        mockStorageService.addToFavorites(testProduct)
        XCTAssertTrue(mockStorageService.isFavorite(testProduct.id))
        
        // When
        sut.toggleFavorite.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(mockStorageService.removeFromFavoritesCalled)
        XCTAssertFalse(mockStorageService.isFavorite(testProduct.id))
    }
    
    func testToggleFavorite_MultipleTimes() {
        // When
        sut.toggleFavorite.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        let firstState = mockStorageService.isFavorite(testProduct.id)
        
        sut.toggleFavorite.onNext(())
        Thread.sleep(forTimeInterval: 0.1)
        let secondState = mockStorageService.isFavorite(testProduct.id)
        
        // Then
        XCTAssertTrue(firstState, "Should be favorite after first toggle")
        XCTAssertFalse(secondState, "Should not be favorite after second toggle")
    }
    
    // MARK: - Favorite State Reactivity Tests
    
    func testIsFavorite_UpdatesWhenStorageChanges() {
        // Given
        var favoriteStates: [Bool] = []
        
        sut.isFavorite
            .subscribe(onNext: { isFavorite in
                favoriteStates.append(isFavorite)
            })
            .disposed(by: disposeBag)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Add to favorites directly in storage
        mockStorageService.addToFavorites(testProduct)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(favoriteStates.contains(true), "Should update to favorite")
    }
    
    func testIsFavorite_UpdatesWhenRemoved() {
        // Given
        mockStorageService.addToFavorites(testProduct)
        sut = ProductDetailViewModel(product: testProduct, storageService: mockStorageService)
        
        var favoriteStates: [Bool] = []
        sut.isFavorite
            .subscribe(onNext: { favoriteStates.append($0) })
            .disposed(by: disposeBag)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Remove from favorites
        mockStorageService.removeFromFavorites(testProduct.id)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(favoriteStates.contains(false), "Should update to not favorite")
    }
}
