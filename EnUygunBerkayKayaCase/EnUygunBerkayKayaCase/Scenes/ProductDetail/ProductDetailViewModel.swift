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
        // Add to cart
        addToCart
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let product = self.product.value
                self.storageService.addToCart(product)
                Logger.shared.logUserAction("Product added to cart: \(product.title)")
            })
            .disposed(by: disposeBag)
        
        // Toggle favorite
        toggleFavorite
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let product = self.product.value
                
                if self.storageService.isFavorite(product.id) {
                    self.storageService.removeFromFavorites(product.id)
                    Logger.shared.logUserAction("Product removed from favorites: \(product.title)")
                } else {
                    self.storageService.addToFavorites(product)
                    Logger.shared.logUserAction("Product added to favorites: \(product.title)")
                }
            })
            .disposed(by: disposeBag)
    }
}
