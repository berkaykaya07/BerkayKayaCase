//
//  ProductListViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa

final class ProductListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProductListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search products..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .systemBackground
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private let loadingView = LoadingView(message: "Loading products...")
    
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "magnifyingglass"),
        title: "No Products Found",
        message: "Try adjusting your search or filters",
        actionTitle: "Clear Filters"
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Products"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubviews(searchBar, tableView, loadingView, emptyStateView)
        
        // SearchBar constraints
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // TableView constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Loading view
        loadingView.pinToSuperview()
        loadingView.isHidden = true
        
        // Empty state view
        emptyStateView.pinToSuperview()
        emptyStateView.isHidden = true
        
        // Navigation bar buttons
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        
        navigationItem.rightBarButtonItems = [filterButton, sortButton]
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
    
    // MARK: - Actions
    
    @objc private func filterTapped() {
        // TODO: Navigate to filter screen
    }
    
    @objc private func sortTapped() {
        // TODO: Show sort options
    }
}
