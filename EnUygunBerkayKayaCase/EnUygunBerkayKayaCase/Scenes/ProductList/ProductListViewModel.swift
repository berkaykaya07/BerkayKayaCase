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
    let isRefreshing = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    let isEmpty = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Properties
    private let repository: ProductRepositoryProtocol
    private let disposeBag = DisposeBag()
    private var currentPage = 0
    private var canLoadMore = true
    private let pageSize = Constants.Pagination.pageSize
    
    // MARK: - Initialization
    
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
        setupBindings()
        loadInitialProducts()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Search with debounce
        searchQuery
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.handleSearch(query: query)
            })
            .disposed(by: disposeBag)
        
        // Pull to refresh
        refresh
            .subscribe(onNext: { [weak self] in
                self?.handleRefresh()
            })
            .disposed(by: disposeBag)
        
        // Pagination
        loadNextPage
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.canLoadMore && !self.isLoading.value
            }
            .subscribe(onNext: { [weak self] in
                self?.loadNextPageProducts()
            })
            .disposed(by: disposeBag)
        
        // Filter changes
        filterOptions
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.handleRefresh()
            })
            .disposed(by: disposeBag)
        
        // Sort changes
        sortOption
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.handleRefresh()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    
    func loadInitialProducts() {
        guard !isLoading.value else { return }
        
        isLoading.accept(true)
        currentPage = 0
        canLoadMore = true
        
        let skip = currentPage * pageSize
        
        repository.getProducts(limit: pageSize, skip: skip)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] products in
                    guard let self = self else { return }
                    self.products.accept(products)
                    self.isEmpty.accept(products.isEmpty)
                    self.canLoadMore = products.count == self.pageSize
                    self.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.error.onNext(error)
                    self.isLoading.accept(false)
                    self.isEmpty.accept(self.products.value.isEmpty)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func loadNextPageProducts() {
        guard canLoadMore, !isLoading.value else { return }
        
        isLoading.accept(true)
        currentPage += 1
        
        let skip = currentPage * pageSize
        
        repository.getProducts(limit: pageSize, skip: skip)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] newProducts in
                    guard let self = self else { return }
                    var allProducts = self.products.value
                    allProducts.append(contentsOf: newProducts)
                    self.products.accept(allProducts)
                    self.canLoadMore = newProducts.count == self.pageSize
                    self.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.error.onNext(error)
                    self.isLoading.accept(false)
                    self.currentPage -= 1
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleRefresh() {
        isRefreshing.accept(true)
        currentPage = 0
        canLoadMore = true
        
        let skip = currentPage * pageSize
        
        repository.getProducts(limit: pageSize, skip: skip)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] products in
                    guard let self = self else { return }
                    self.products.accept(products)
                    self.isEmpty.accept(products.isEmpty)
                    self.canLoadMore = products.count == self.pageSize
                    self.isRefreshing.accept(false)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.error.onNext(error)
                    self.isRefreshing.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleSearch(query: String) {
        guard !query.isEmpty else {
            loadInitialProducts()
            return
        }
        
        isLoading.accept(true)
        currentPage = 0
        canLoadMore = false
        
        repository.searchProducts(query: query)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] products in
                    guard let self = self else { return }
                    self.products.accept(products)
                    self.isEmpty.accept(products.isEmpty)
                    self.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.error.onNext(error)
                    self.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
}
