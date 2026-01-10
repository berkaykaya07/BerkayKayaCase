//
//  FavoritesViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = FavoritesViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "heart"),
        title: "No Favorites Yet",
        message: "Save products you love to see them here",
        actionTitle: "Browse Products"
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        view.addSubviews(tableView, emptyStateView)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Empty State
        emptyStateView.pinToSuperview()
        emptyStateView.isHidden = true
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
}
