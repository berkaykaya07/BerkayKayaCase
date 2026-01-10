//
//  CartViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class CartViewModel {
    
    // MARK: - Inputs
    let updateQuantity = PublishSubject<(productId: Int, quantity: Int)>()
    let removeItem = PublishSubject<Int>()
    let clearCart = PublishSubject<Void>()
    
    // MARK: - Outputs
    let cartItems: Observable<[CartItem]>
    let totalPrice: Observable<Double>
    let isEmpty: Observable<Bool>
    
    // MARK: - Properties
    private let storageService: StorageServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        
        // Outputs
        self.cartItems = storageService.cart.asObservable()
        
        self.totalPrice = storageService.cart
            .map { items in
                items.reduce(0) { $0 + $1.totalPrice }
            }
        
        self.isEmpty = storageService.cart
            .map { $0.isEmpty }
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Update quantity
        updateQuantity
            .subscribe(onNext: { [weak self] productId, quantity in
                guard let self = self else { return }
                self.storageService.updateCartItemQuantity(productId: productId, quantity: quantity)
                Logger.shared.logUserAction("Cart item quantity updated: \(productId) -> \(quantity)")
            })
            .disposed(by: disposeBag)
        
        // Remove item
        removeItem
            .subscribe(onNext: { [weak self] productId in
                guard let self = self else { return }
                self.storageService.removeFromCart(productId: productId)
                Logger.shared.logUserAction("Item removed from cart: \(productId)")
            })
            .disposed(by: disposeBag)
        
        // Clear cart
        clearCart
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.storageService.clearCart()
                Logger.shared.logUserAction("Cart cleared")
            })
            .disposed(by: disposeBag)
    }
}
