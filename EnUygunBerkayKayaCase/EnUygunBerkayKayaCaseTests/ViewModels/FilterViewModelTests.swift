//
//  FilterViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class FilterViewModelTests: XCTestCase {
    
    var sut: FilterViewModel!
    var mockRepository: MockProductRepository!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        mockRepository.mockCategories = ["smartphones", "laptops", "fragrances"]
        sut = FilterViewModel(currentFilters: .empty, repository: mockRepository)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_WithEmptyFilters() {
        // Given - setup in setUp()
        
        // When
        let selectedCategory = sut.selectedCategory.value
        
        // Then
        XCTAssertNil(selectedCategory, "Should have no category selected initially")
    }
    
    func testInit_WithExistingFilters() {
        // Given
        let currentFilters = FilterOptions(category: "smartphones")
        
        // When
        sut = FilterViewModel(currentFilters: currentFilters, repository: mockRepository)
        let selectedCategory = sut.selectedCategory.value
        
        // Then
        XCTAssertEqual(selectedCategory, "smartphones")
    }
    
    // MARK: - Fetch Categories Tests
    
    func testFetchCategories_Success() {
        // Given - loadCategories is called in init
        mockRepository.mockCategories = ["smartphones", "laptops", "fragrances"]
        
        // When - Categories loaded automatically in init
        Thread.sleep(forTimeInterval: 0.2)
        
        let categories = sut.categories.value
        
        // Then
        XCTAssertTrue(mockRepository.getCategoriesCalled)
        XCTAssertEqual(categories.count, 3, "Should have 3 categories")
        XCTAssertTrue(categories.contains("smartphones"))
        XCTAssertTrue(categories.contains("laptops"))
        XCTAssertTrue(categories.contains("fragrances"))
    }
    
    func testFetchCategories_LoadingState() {
        // Given - Observe the existing sut's loading state
        var loadingStates: [Bool] = []
        
        // Capture the initial loading state from setUp
        loadingStates.append(sut.isLoading.value)
        
        sut.isLoading
            .skip(1) // Skip current value
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)
        
        // When - Wait for async load to complete
        Thread.sleep(forTimeInterval: 0.3)
        
        // Then - Should have finished loading
        XCTAssertFalse(sut.isLoading.value, "Should finish loading")
        XCTAssertGreaterThan(sut.categories.value.count, 0, "Should have loaded categories")
    }
    
    // MARK: - Category Selection Tests
    
    func testSelectCategory() {
        // Given
        Thread.sleep(forTimeInterval: 0.2) // Wait for initial fetch
        
        // When
        sut.selectCategory.onNext("smartphones")
        
        // Then
        XCTAssertEqual(sut.selectedCategory.value, "smartphones")
    }
    
    func testSelectCategory_Clear() {
        // Given
        sut.selectCategory.onNext("smartphones")
        XCTAssertEqual(sut.selectedCategory.value, "smartphones")
        
        // When - Select nil to clear
        sut.selectCategory.onNext(nil)
        
        // Then - Should be nil (no filter)
        XCTAssertNil(sut.selectedCategory.value)
    }
    
    func testSelectCategory_ChangesSelection() {
        // Given
        sut.selectCategory.onNext("smartphones")
        
        // When
        sut.selectCategory.onNext("laptops")
        
        // Then
        XCTAssertEqual(sut.selectedCategory.value, "laptops")
    }
    
    func testSelectCategory_Nil() {
        // Given
        sut.selectCategory.onNext("smartphones")
        
        // When
        sut.selectCategory.onNext(nil)
        
        // Then
        XCTAssertNil(sut.selectedCategory.value)
    }
    
    // MARK: - Get Current Filters Tests
    
    func testGetCurrentFilters_NoSelection() {
        // Given - no selection
        
        // When
        let category = sut.selectedCategory.value
        let filters = FilterOptions(category: category)
        
        // Then
        XCTAssertNil(filters.category)
        XCTAssertFalse(filters.isActive)
    }
    
    func testGetCurrentFilters_WithCategory() {
        // Given
        sut.selectCategory.onNext("smartphones")
        
        // When
        let category = sut.selectedCategory.value
        let filters = FilterOptions(category: category)
        
        // Then
        XCTAssertEqual(filters.category, "smartphones")
        XCTAssertTrue(filters.isActive)
    }
    
    // MARK: - Filter Options Tests
    
    func testFilterOptions_IsActive() {
        // Given
        let emptyFilters = FilterOptions.empty
        let activeFilters = FilterOptions(category: "smartphones")
        
        // Then
        XCTAssertFalse(emptyFilters.isActive)
        XCTAssertTrue(activeFilters.isActive)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteFilterFlow() {
        // Given - Wait for categories to load
        Thread.sleep(forTimeInterval: 0.2)
        
        let categories = sut.categories.value
        XCTAssertGreaterThan(categories.count, 0)
        
        // When - Select a category
        sut.selectCategory.onNext("smartphones")
        
        // Then - Get filters
        let category = sut.selectedCategory.value
        let filters = FilterOptions(category: category)
        XCTAssertEqual(filters.category, "smartphones")
        XCTAssertTrue(filters.isActive)
        
        // When - Clear selection
        sut.selectCategory.onNext(nil)
        
        // Then
        let clearedCategory = sut.selectedCategory.value
        let clearedFilters = FilterOptions(category: clearedCategory)
        XCTAssertNil(clearedFilters.category)
        XCTAssertFalse(clearedFilters.isActive)
    }
}
