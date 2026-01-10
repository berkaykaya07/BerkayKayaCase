//
//  ProductDetailViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class ProductDetailViewModel {
    
    // MARK: - Inputs
    let addToCart = PublishSubject<Void>()
    let toggleFavorite = PublishSubject<Void>()
    
    // MARK: - Outputs
    let product: BehaviorRelay<Product>
    let isFavorite: Observable<Bool>
    
    // MARK: - Properties
    private let storageService: StorageServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(product: Product, storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        self.product = BehaviorRelay(value: product)
        
        self.isFavorite = storageService.favorites
            .map { favorites in
                favorites.contains(where: { $0.id == product.id })
            }
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
