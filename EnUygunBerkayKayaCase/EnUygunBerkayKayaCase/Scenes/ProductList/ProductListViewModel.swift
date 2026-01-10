//
//  ProductListViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class ProductListViewModel {
    
    // MARK: - Inputs
    let searchQuery = BehaviorRelay<String>(value: "")
    let loadNextPage = PublishSubject<Void>()
    let refresh = PublishSubject<Void>()
    let filterOptions = BehaviorRelay<FilterOptions>(value: .empty)
    let sortOption = BehaviorRelay<SortOption?>(value: nil)
    
    // MARK: - Outputs
    let products = BehaviorRelay<[Product]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    // MARK: - Properties
    private let repository: ProductRepositoryProtocol
    private let disposeBag = DisposeBag()
    private var currentPage = 0
    private var canLoadMore = true
    
    // MARK: - Initialization
    
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
        // - Search with debounce
        // - Pagination
        // - Pull to refresh
        // - Filtering
        // - Sorting
    }
    
    // MARK: - Methods
    
    func loadInitialProducts() {
        // TODO: Will be implemented in next commit
    }
}
