//
//  FavoritesViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class FavoritesViewModel {
    
    // MARK: - Inputs
    let removeFavorite = PublishSubject<Int>()
    let addToCart = PublishSubject<Product>()
    
    // MARK: - Outputs
    let favorites: Observable<[Product]>
    let isEmpty: Observable<Bool>
    
    // MARK: - Properties
    private let storageService: StorageServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        
        // Outputs
        self.favorites = storageService.favorites.asObservable()
        
        self.isEmpty = storageService.favorites
            .map { $0.isEmpty }
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Remove from favorites
        removeFavorite
            .subscribe(onNext: { [weak self] productId in
                guard let self = self else { return }
                self.storageService.removeFromFavorites(productId)
                Logger.shared.logUserAction("Product removed from favorites: \(productId)")
            })
            .disposed(by: disposeBag)
        
        // Add to cart
        addToCart
            .subscribe(onNext: { [weak self] product in
                guard let self = self else { return }
                self.storageService.addToCart(product)
                Logger.shared.logUserAction("Product added to cart from favorites: \(product.title)")
            })
            .disposed(by: disposeBag)
    }
}
