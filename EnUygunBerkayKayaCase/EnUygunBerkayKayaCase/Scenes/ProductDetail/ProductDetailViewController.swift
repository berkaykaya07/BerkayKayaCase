//
//  ProductDetailViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift

final class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
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
        title = "Product Detail"
        view.backgroundColor = .systemBackground
        
        // TODO: Will be implemented in next commit
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
