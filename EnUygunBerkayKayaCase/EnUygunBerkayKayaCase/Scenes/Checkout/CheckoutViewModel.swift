//
//  CheckoutViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

final class CheckoutViewModel {
    
    // MARK: - Inputs
    let fullName = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let address = BehaviorRelay<String>(value: "")
    let cardNumber = BehaviorRelay<String>(value: "")
    let submitOrder = PublishSubject<Void>()
    
    // MARK: - Outputs
    let isValid: Observable<Bool>
    let orderSuccess = PublishSubject<Void>()
    let orderError = PublishSubject<String>()
    
    // MARK: - Properties
    let cartItems: [CartItem]
    let totalAmount: Double
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(cartItems: [CartItem], totalAmount: Double) {
        self.cartItems = cartItems
        self.totalAmount = totalAmount
        
        self.isValid = Observable.combineLatest(
            fullName.asObservable(),
            email.asObservable(),
            address.asObservable(),
            cardNumber.asObservable()
        ) { fullName, email, address, cardNumber in
            !fullName.isEmpty && !email.isEmpty && !address.isEmpty && cardNumber.count >= 16
        }
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
