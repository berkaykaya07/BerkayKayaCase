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
    let applyFilters = PublishSubject<Void>()
    let resetFilters = PublishSubject<Void>()
    
    // MARK: - Outputs
    let filterOptions = BehaviorRelay<FilterOptions>(value: .empty)
    let categories: Observable<[String]>
    
    // MARK: - Properties
    private let repository: ProductRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(currentFilters: FilterOptions, repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
        self.filterOptions.accept(currentFilters)
        
        self.categories = repository.getCategories()
            .catch { _ in .just([]) }
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
