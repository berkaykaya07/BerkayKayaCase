//
//  CheckoutViewModel.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation
import RxSwift
import RxCocoa

enum PaymentMethod: String, CaseIterable {
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case cashOnDelivery = "Cash on Delivery"
    
    var icon: String {
        switch self {
        case .creditCard: return "creditcard"
        case .debitCard: return "rectangle.portrait.and.arrow.forward"
        case .cashOnDelivery: return "banknote"
        }
    }
}

final class CheckoutViewModel {
    
    // MARK: - Inputs
    let fullName = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let phone = BehaviorRelay<String>(value: "")
    let address = BehaviorRelay<String>(value: "")
    let selectedPaymentMethod = BehaviorRelay<PaymentMethod>(value: .creditCard)
    let placeOrder = PublishSubject<Void>()
    
    // MARK: - Outputs
    let cartItems: Observable<[CartItem]>
    let subtotal: Observable<Double>
    let tax: Observable<Double>
    let total: Observable<Double>
    let isFormValid: Observable<Bool>
    let orderPlaced = PublishSubject<Void>()
    
    // MARK: - Properties
    private let storageService: StorageServiceProtocol
    private let disposeBag = DisposeBag()
    private let taxRate: Double = 0.18 // 18% tax
    
    // MARK: - Initialization
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        
        // Cart items
        self.cartItems = storageService.cart.asObservable()
        
        // Subtotal
        let subtotalObservable = storageService.cart
            .map { items in
                items.reduce(0) { $0 + $1.totalPrice }
            }
        self.subtotal = subtotalObservable
        
        // Tax
        self.tax = subtotalObservable.map { subtotal in
            subtotal * 0.18 // 18% tax rate
        }
        
        // Total
        self.total = Observable.combineLatest(subtotalObservable, self.tax)
            .map { $0 + $1 }
        
        // Form validation
        self.isFormValid = Observable.combineLatest(
            fullName.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            email.map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            },
            phone.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            address.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        ) { $0 && $1 && $2 && $3 }
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        placeOrder
            .withLatestFrom(isFormValid)
            .filter { $0 } // Only proceed if form is valid
            .subscribe(onNext: { [weak self] _ in
                self?.processOrder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    
    private func processOrder() {
        Logger.shared.logUserAction("Order placed - Name: \(fullName.value), Payment: \(selectedPaymentMethod.value.rawValue)")
        
        // Clear cart
        storageService.clearCart()
        
        // Notify success
        orderPlaced.onNext(())
    }
}
