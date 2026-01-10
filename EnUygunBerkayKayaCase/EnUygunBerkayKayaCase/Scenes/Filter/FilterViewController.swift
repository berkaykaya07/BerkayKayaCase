//
//  FilterViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift

final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FilterViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(currentFilters: FilterOptions) {
        self.viewModel = FilterViewModel(currentFilters: currentFilters)
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
        title = "Filters"
        view.backgroundColor = .systemBackground
        
        // TODO: Will be implemented in next commit
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
