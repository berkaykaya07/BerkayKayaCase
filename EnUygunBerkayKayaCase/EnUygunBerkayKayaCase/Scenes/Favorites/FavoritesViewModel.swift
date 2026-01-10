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
        // TODO: Will be implemented in next commit
    }
}
