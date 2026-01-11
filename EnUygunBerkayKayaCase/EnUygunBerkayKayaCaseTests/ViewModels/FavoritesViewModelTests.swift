//
//  FavoritesViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class FavoritesViewModelTests: XCTestCase {
    
    var sut: FavoritesViewModel!
    var mockStorageService: MockStorageService!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        sut = FavoritesViewModel(storageService: mockStorageService)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        mockStorageService = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_FavoritesEmpty() {
        // Given - setup in setUp()
        
        // When
        let favorites = try! sut.favorites.toBlocking().first()
        
        // Then
        XCTAssertEqual(favorites?.count, 0, "Initial favorites should be empty")
    }
    
    func testInitialState_IsEmpty() {
        // Given
        
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == true, "isEmpty should be true initially")
    }
    
    // MARK: - Favorites Observable Tests
    
    func testFavoritesObservable_UpdatesWhenStorageChanges() {
        // Given
        var favoriteCounts: [Int] = []
        
        sut.favorites
            .map { $0.count }
            .subscribe(onNext: { favoriteCounts.append($0) })
            .disposed(by: disposeBag)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Add to favorites in storage
        mockStorageService.addToFavorites(Product.mock(id: 1))
        Thread.sleep(forTimeInterval: 0.1)
        
        mockStorageService.addToFavorites(Product.mock(id: 2))
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertEqual(favoriteCounts.first, 0, "Should start with 0")
        XCTAssertTrue(favoriteCounts.contains(1), "Should update to 1")
        XCTAssertTrue(favoriteCounts.contains(2), "Should update to 2")
    }
    
    // MARK: - Remove Favorite Tests
    
    func testRemoveFavorite() {
        // Given
        let product = Product.mock(id: 1, title: "Test Product")
        mockStorageService.addToFavorites(product)
        XCTAssertEqual(mockStorageService.favorites.value.count, 1)
        
        // When
        sut.removeFavorite.onNext(product.id)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(mockStorageService.removeFromFavoritesCalled)
        XCTAssertEqual(mockStorageService.favorites.value.count, 0)
    }
    
    func testRemoveFavorite_MultipleProducts() {
        // Given
        mockStorageService.addToFavorites(Product.mock(id: 1))
        mockStorageService.addToFavorites(Product.mock(id: 2))
        mockStorageService.addToFavorites(Product.mock(id: 3))
        
        // When - Remove middle one
        sut.removeFavorite.onNext(2)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        let favorites = try! sut.favorites.toBlocking().first()
        XCTAssertEqual(favorites?.count, 2)
        XCTAssertFalse(favorites?.contains(where: { $0.id == 2 }) ?? true)
    }
    
    func testRemoveFavorite_NonExistentProduct() {
        // Given
        mockStorageService.addToFavorites(Product.mock(id: 1))
        
        // When - Try to remove non-existent product
        sut.removeFavorite.onNext(999)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then - Should not crash, favorites should remain
        let favorites = try! sut.favorites.toBlocking().first()
        XCTAssertEqual(favorites?.count, 1)
    }
    
    // MARK: - Add to Cart Tests
    
    func testAddToCartFromFavorites() {
        // Given
        let product = Product.mock(id: 1)
        mockStorageService.addToFavorites(product)
        
        // When
        sut.addToCart.onNext(product)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertTrue(mockStorageService.addToCartCalled)
        XCTAssertEqual(mockStorageService.cart.value.count, 1)
        XCTAssertEqual(mockStorageService.cart.value.first?.product.id, product.id)
    }
    
    func testAddToCart_MultipleFavorites() {
        // Given
        let product1 = Product.mock(id: 1)
        let product2 = Product.mock(id: 2)
        mockStorageService.addToFavorites(product1)
        mockStorageService.addToFavorites(product2)
        
        // When - Add both to cart
        sut.addToCart.onNext(product1)
        Thread.sleep(forTimeInterval: 0.1)
        sut.addToCart.onNext(product2)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertEqual(mockStorageService.cart.value.count, 2)
    }
    
    // MARK: - isEmpty Tests
    
    func testIsEmpty_TrueWhenNoFavorites() {
        // Given - no favorites
        
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == true)
    }
    
    func testIsEmpty_FalseWhenHasFavorites() {
        // Given
        mockStorageService.addToFavorites(Product.mock(id: 1))
        
        // When
        let isEmpty = try! sut.isEmpty.toBlocking().first()
        
        // Then
        XCTAssertTrue(isEmpty == false)
    }
    
    func testIsEmpty_UpdatesWhenFavoritesChange() {
        // Given
        var isEmptyStates: [Bool] = []
        
        sut.isEmpty
            .subscribe(onNext: { isEmptyStates.append($0) })
            .disposed(by: disposeBag)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Add favorite
        mockStorageService.addToFavorites(Product.mock(id: 1))
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then remove it
        mockStorageService.removeFromFavorites(1)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertEqual(isEmptyStates.first, true, "Should start empty")
        XCTAssertTrue(isEmptyStates.contains(false), "Should become not empty")
        XCTAssertEqual(isEmptyStates.last, true, "Should end empty")
    }
    
    // MARK: - Integration Tests
    
    func testFavoritesScreen_CompleteFlow() {
        // Given - Start with some favorites
        let product1 = Product.mock(id: 1, title: "Product 1")
        let product2 = Product.mock(id: 2, title: "Product 2")
        mockStorageService.addToFavorites(product1)
        mockStorageService.addToFavorites(product2)
        
        var favorites = try! sut.favorites.toBlocking().first()
        XCTAssertEqual(favorites?.count, 2)
        
        // When - Add one to cart
        sut.addToCart.onNext(product1)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then - Check cart
        XCTAssertEqual(mockStorageService.cart.value.count, 1)
        
        // When - Remove from favorites
        sut.removeFavorite.onNext(product1.id)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then - Should only have product2
        favorites = try! sut.favorites.toBlocking().first()
        XCTAssertEqual(favorites?.count, 1)
        XCTAssertEqual(favorites?.first?.id, product2.id)
        
        // Cart should still have product1
        XCTAssertEqual(mockStorageService.cart.value.count, 1)
        XCTAssertEqual(mockStorageService.cart.value.first?.product.id, product1.id)
    }
}
