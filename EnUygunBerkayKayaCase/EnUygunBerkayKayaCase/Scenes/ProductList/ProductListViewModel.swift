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
        let sortBy = sortOption.value?.sortBy
        let order = sortOption.value?.order
        let category = filterOptions.value.category
        
        let request: Observable<[Product]>
        if let category = category {
            request = repository.getProductsByCategory(category: category)
                .map { products in
                    if let sortBy = sortBy {
                        return self.sortProducts(products, by: sortBy, order: order ?? "asc")
                    }
                    return products
                }
        } else {
            request = repository.getProducts(limit: pageSize, skip: skip, sortBy: sortBy, order: order)
        }
        
        request
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] products in
                    guard let self = self else { return }
                    self.products.accept(products)
                    self.isEmpty.accept(products.isEmpty)
                    
                    self.canLoadMore = category == nil && products.count == self.pageSize
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
        
        guard filterOptions.value.category == nil else { return }
        
        isLoading.accept(true)
        currentPage += 1
        
        let skip = currentPage * pageSize
        let sortBy = sortOption.value?.sortBy
        let order = sortOption.value?.order
        
        repository.getProducts(limit: pageSize, skip: skip, sortBy: sortBy, order: order)
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
        let sortBy = sortOption.value?.sortBy
        let order = sortOption.value?.order
        let category = filterOptions.value.category
        
        let request: Observable<[Product]>
        if let category = category {
            request = repository.getProductsByCategory(category: category)
                .map { products in
                    if let sortBy = sortBy {
                        return self.sortProducts(products, by: sortBy, order: order ?? "asc")
                    }
                    return products
                }
        } else {
            request = repository.getProducts(limit: pageSize, skip: skip, sortBy: sortBy, order: order)
        }
        
        request
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] products in
                    guard let self = self else { return }
                    self.products.accept(products)
                    self.isEmpty.accept(products.isEmpty)
                    self.canLoadMore = category == nil && products.count == self.pageSize
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
        
        let sortBy = sortOption.value?.sortBy
        let order = sortOption.value?.order
        let category = filterOptions.value.category
        
        repository.searchProducts(query: query, sortBy: sortBy, order: order)
            .map { products in

                if let category = category {
                    Logger.shared.logUserAction("Search with category filter: \(category)")
                    return products.filter { $0.category == category }
                }
                return products
            }
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
    
    // MARK: - Helper Methods
    
    private func sortProducts(_ products: [Product], by sortBy: String, order: String) -> [Product] {
        return products.sorted { product1, product2 in
            switch sortBy {
            case "title":
                return order == "asc" ? product1.title < product2.title : product1.title > product2.title
            case "price":
                return order == "asc" ? product1.price < product2.price : product1.price > product2.price
            case "rating":
                return order == "asc" ? product1.rating < product2.rating : product1.rating > product2.rating
            default:
                return true
            }
        }
    }
}
