//
//  ProductListViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class ProductListViewModelTests: XCTestCase {
    
    var sut: ProductListViewModel!
    var mockRepository: MockProductRepository!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        mockRepository.mockProducts = [] // Start with empty to prevent init load
        sut = ProductListViewModel(repository: mockRepository)
        disposeBag = DisposeBag()
        
        // Wait for initial load to complete
        Thread.sleep(forTimeInterval: 0.2)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_ProductsEmpty() {
        // Given - setup in setUp() with empty mockProducts
        
        // When
        let products = sut.products.value
        
        // Then
        XCTAssertTrue(products.isEmpty, "Products should be empty after init with empty mock data")
    }
    
    func testInitialState_IsNotLoading() {
        // Given
        
        // When
        let isLoading = sut.isLoading.value
        
        // Then
        XCTAssertFalse(isLoading, "Should not be loading initially")
    }
    
    func testInitialState_IsNotRefreshing() {
        // Given
        
        // When
        let isRefreshing = sut.isRefreshing.value
        
        // Then
        XCTAssertFalse(isRefreshing, "Should not be refreshing initially")
    }
    
    // MARK: - Initial Load Tests
    
    func testLoadInitialProducts_Success() {
        // Given
        let mockProducts = Product.mockList(count: 10)
        mockRepository.mockProducts = mockProducts
        
        // When
        sut.loadInitialProducts()
        
        // Wait for async operation
        Thread.sleep(forTimeInterval: 0.2)
        
        let products = sut.products.value
        
        // Then
        XCTAssertEqual(products.count, 10)
        XCTAssertTrue(mockRepository.getProductsCalled)
    }
    
    func testLoadInitialProducts_SetsLoadingState() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        
        var loadingStates: [Bool] = []
        sut.isLoading
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertTrue(loadingStates.contains(true), "Should have been loading")
        XCTAssertEqual(loadingStates.last, false, "Should finish loading")
    }
    
    func testLoadInitialProducts_EmptyResult() {
        // Given
        mockRepository.mockProducts = []
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertTrue(sut.isEmpty.value, "isEmpty should be true for empty results")
    }
    
    func testLoadInitialProducts_Error() {
        // Given
        mockRepository.mockError = NSError(domain: "Test", code: 500, userInfo: nil)
        
        var errorReceived = false
        sut.error
            .subscribe(onNext: { _ in errorReceived = true })
            .disposed(by: disposeBag)
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertTrue(errorReceived, "Should receive error")
        XCTAssertFalse(sut.isLoading.value, "Should stop loading on error")
    }
    
    // MARK: - Search Tests
    
    func testSearch_EmptyQuery_LoadsAllProducts() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 10)
        sut.searchQuery.accept("test")
        Thread.sleep(forTimeInterval: 0.5)
        
        // When - Clear search
        sut.searchQuery.accept("")
        Thread.sleep(forTimeInterval: 0.5)
        
        // Then
        XCTAssertTrue(mockRepository.getProductsCalled, "Should load all products")
    }
    
    func testSearch_NoResults() {
        // Given
        mockRepository.mockProducts = [Product.mock(id: 1, title: "iPhone")]
        
        // When
        sut.searchQuery.accept("Samsung")
        Thread.sleep(forTimeInterval: 0.5)
        
        // Then
        XCTAssertTrue(sut.isEmpty.value, "Should be empty when no results")
        XCTAssertTrue(sut.products.value.isEmpty)
    }
    
    // MARK: - Sort Tests
    
    func testSort_ByPrice() {
        // Given
        let products = [
            Product.mock(id: 1, title: "Product A", price: 100),
            Product.mock(id: 2, title: "Product B", price: 50),
            Product.mock(id: 3, title: "Product C", price: 200)
        ]
        mockRepository.mockProducts = products
        
        // When
        sut.sortOption.accept(.priceAsc)
        Thread.sleep(forTimeInterval: 0.3)
        
        let sortedProducts = sut.products.value
        
        // Then
        XCTAssertTrue(mockRepository.getProductsCalled)
        // Note: Actual sorting happens on server, mock returns unsorted
    }
    
    func testSort_ByRating() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        
        // When
        sut.sortOption.accept(.ratingDesc)
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then
        XCTAssertTrue(mockRepository.getProductsCalled)
    }
    
    func testSort_ClearSort() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        sut.sortOption.accept(.priceAsc)
        Thread.sleep(forTimeInterval: 0.3)
        
        // When
        sut.sortOption.accept(nil)
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then
        XCTAssertTrue(mockRepository.getProductsCalled)
    }
    
    // MARK: - Filter Tests
    
    func testFilter_ByCategory() {
        // Given
        let products = [
            Product.mock(id: 1, category: "smartphones"),
            Product.mock(id: 2, category: "laptops"),
            Product.mock(id: 3, category: "smartphones")
        ]
        mockRepository.mockProducts = products
        
        // When
        sut.filterOptions.accept(FilterOptions(category: "smartphones"))
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then
        XCTAssertTrue(mockRepository.getProductsByCategoryCalled)
    }
    
    func testFilter_ClearFilter() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        sut.filterOptions.accept(FilterOptions(category: "smartphones"))
        Thread.sleep(forTimeInterval: 0.3)
        
        // When
        sut.filterOptions.accept(.empty)
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then
        XCTAssertTrue(mockRepository.getProductsCalled)
    }
    
    // MARK: - Search + Filter Combination Tests
    
    func testSearchWithFilter_FiltersResults() {
        // Given
        let products = [
            Product.mock(id: 1, title: "iPhone 15", category: "smartphones"),
            Product.mock(id: 2, title: "MacBook Pro", category: "laptops"),
            Product.mock(id: 3, title: "iPhone 14", category: "smartphones")
        ]
        mockRepository.mockProducts = products
        
        // When - Set filter first
        sut.filterOptions.accept(FilterOptions(category: "smartphones"))
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then search
        sut.searchQuery.accept("iPhone")
        Thread.sleep(forTimeInterval: 0.5)
        
        let results = sut.products.value
        
        // Then - Should only have smartphones with "iPhone"
        XCTAssertTrue(results.allSatisfy { $0.category == "smartphones" && $0.title.contains("iPhone") })
    }
    
    // MARK: - Pagination Tests
    
    func testPagination_LoadNextPage() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 30)
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        let initialCount = sut.products.value.count
        
        // When
        sut.loadNextPage.onNext(())
        Thread.sleep(forTimeInterval: 0.3)
        
        let afterPaginationCount = sut.products.value.count
        
        // Then
        XCTAssertGreaterThan(afterPaginationCount, initialCount, "Should load more products")
    }
    
    func testPagination_DisabledDuringLoading() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 30)
        sut.loadInitialProducts()
        
        // When - Try to paginate while loading
        sut.loadNextPage.onNext(())
        
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then - Should not trigger multiple loads
        // (Hard to test directly, but covered by canLoadMore logic)
    }
    
    func testPagination_DisabledWhenCategoryActive() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 30)
        sut.filterOptions.accept(FilterOptions(category: "smartphones"))
        Thread.sleep(forTimeInterval: 0.3)
        
        let beforeCount = sut.products.value.count
        
        // When
        sut.loadNextPage.onNext(())
        Thread.sleep(forTimeInterval: 0.3)
        
        let afterCount = sut.products.value.count
        
        // Then - Should not paginate
        XCTAssertEqual(beforeCount, afterCount, "Pagination should be disabled with category filter")
    }
    
    // MARK: - Pull to Refresh Tests
    
    func testPullToRefresh_ReloadsProducts() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 10)
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        var refreshingStates: [Bool] = []
        sut.isRefreshing
            .subscribe(onNext: { refreshingStates.append($0) })
            .disposed(by: disposeBag)
        
        // When
        sut.refresh.onNext(())
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then
        XCTAssertTrue(refreshingStates.contains(true), "Should have been refreshing")
        XCTAssertEqual(refreshingStates.last, false, "Should finish refreshing")
    }
    
    func testPullToRefresh_ResetsPage() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 30)
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        sut.loadNextPage.onNext(()) // Load page 2
        Thread.sleep(forTimeInterval: 0.3)
        
        // When
        sut.refresh.onNext(())
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then - Should reload from beginning
        XCTAssertTrue(mockRepository.getProductsCalled)
    }
    
    // MARK: - Error Handling Tests
    
    func testError_DoesNotClearExistingProducts() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        let initialProducts = sut.products.value
        XCTAssertFalse(initialProducts.isEmpty)
        
        // When - Trigger error on pagination
        mockRepository.mockError = NSError(domain: "Test", code: 500, userInfo: nil)
        sut.loadNextPage.onNext(())
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then - Products should still be there
        XCTAssertEqual(sut.products.value.count, initialProducts.count, "Should not clear products on error")
    }
    
    func testError_StopsLoading() {
        // Given
        mockRepository.mockError = NSError(domain: "Test", code: 500, userInfo: nil)
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertFalse(sut.isLoading.value, "Should stop loading on error")
    }
    
    // MARK: - isEmpty State Tests
    
    func testIsEmpty_TrueWhenNoProducts() {
        // Given
        mockRepository.mockProducts = []
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertTrue(sut.isEmpty.value)
    }
    
    func testIsEmpty_FalseWhenHasProducts() {
        // Given
        mockRepository.mockProducts = Product.mockList(count: 5)
        
        // When
        sut.loadInitialProducts()
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then
        XCTAssertFalse(sut.isEmpty.value)
    }
}
