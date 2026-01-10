//
//  CheckoutViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift

final class CheckoutViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CheckoutViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(cartItems: [CartItem], totalAmount: Double) {
        self.viewModel = CheckoutViewModel(cartItems: cartItems, totalAmount: totalAmount)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Checkout"
        view.backgroundColor = .systemBackground
        
        // TODO: Will be implemented in next commit
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
