//
//  FilterViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class FilterViewModel {
    
    // MARK: - Inputs
    let selectCategory = PublishSubject<String?>()
    let applyFilters = PublishSubject<Void>()
    let resetFilters = PublishSubject<Void>()
    
    // MARK: - Outputs
    let categories = BehaviorRelay<[String]>(value: [])
    let selectedCategory = BehaviorRelay<String?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let dismiss = PublishSubject<FilterOptions>()
    
    // MARK: - Properties
    private let repository: ProductRepositoryProtocol
    private let disposeBag = DisposeBag()
    private let currentFilters: FilterOptions
    
    // MARK: - Initialization
    
    init(currentFilters: FilterOptions, repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
        self.currentFilters = currentFilters
        
        selectedCategory.accept(currentFilters.category)
        
        setupBindings()
        loadCategories()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Category selection
        selectCategory
            .subscribe(onNext: { [weak self] category in
                self?.selectedCategory.accept(category)
                Logger.shared.logUserAction("Category selected: \(category ?? "All")")
            })
            .disposed(by: disposeBag)
        
        // Apply filters
        applyFilters
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let filterOptions = FilterOptions(category: self.selectedCategory.value)
                Logger.shared.logUserAction("Filters applied: \(filterOptions.isActive ? "Active" : "None")")
                self.dismiss.onNext(filterOptions)
            })
            .disposed(by: disposeBag)
        
        // Reset filters
        resetFilters
            .subscribe(onNext: { [weak self] in
                self?.selectedCategory.accept(nil)
                Logger.shared.logUserAction("Filters reset")
            })
            .disposed(by: disposeBag)
    }
    
    private func loadCategories() {
        isLoading.accept(true)
        
        repository.getCategories()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] categoryList in
                    self?.categories.accept(categoryList)
                    self?.isLoading.accept(false)
                    Logger.shared.info("Loaded \(categoryList.count) categories")
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    Logger.shared.error("Failed to load categories", error: error)
                }
            )
            .disposed(by: disposeBag)
    }
}
