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
    private let storageService = StorageService.shared
    
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
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let loadingView = LoadingView(message: "Loading products...")
    
    private let tableLoadingView: LoadingView = {
        let view = LoadingView(message: "Searching...")
        view.isHidden = true
        return view
    }()
    
    private let footerLoadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        return view
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No Products Found",
            message: "Try adjusting your search or filters",
            actionTitle: "Clear Filters"
        )
        view.actionHandler = { [weak self] in
            self?.clearFilters()
        }
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboardDismiss()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Products"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubviews(searchBar, tableView, loadingView, emptyStateView, tableLoadingView)
        
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
        
        // Table Loading view
        tableLoadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableLoadingView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableLoadingView.isHidden = true
        
        // Empty state view
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        emptyStateView.isHidden = true
        
        // Refresh control
        tableView.refreshControl = refreshControl
        
        // Dismiss keyboard on scroll
        tableView.keyboardDismissMode = .onDrag
        
        // Navigation bar buttons
        setupNavigationBar()
        
        // SearchBar delegate
        searchBar.delegate = self
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
    
    private func setupKeyboardDismiss() {
        // Dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupBindings() {
        // Search binding
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        
        // Refresh control
        refreshControl.rx.controlEvent(.valueChanged)
            .do(onNext: { [weak self] in
                // Clear search bar on refresh
                self?.searchBar.text = ""
                self?.viewModel.searchQuery.accept("")
            })
            .bind(to: viewModel.refresh)
            .disposed(by: disposeBag)
        
        // Products binding
        viewModel.products
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: ProductCell.identifier, cellType: ProductCell.self)) { [weak self] index, product, cell in
                guard let self = self else { return }
                
                let isFavorite = self.storageService.isFavorite(product.id)
                cell.configure(with: product, isFavorite: isFavorite)
                
                // Favorite button tap
                cell.favoriteButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.toggleFavorite(product)
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    })
                    .disposed(by: cell.disposeBag)
                
                // Add to cart button tap
                cell.addToCartButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.addToCart(product)
                        
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // Show toast
                        self?.showToast(message: "Added to cart")
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // Cell selection
        tableView.rx.modelSelected(Product.self)
            .subscribe(onNext: { [weak self] product in
                self?.navigateToDetail(product: product)
            })
            .disposed(by: disposeBag)
        
        // Pagination - Load more when reaching bottom
        tableView.rx.contentOffset
            .map { [weak self] offset in
                guard let self = self else { return false }
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.size.height
                let scrollPosition = offset.y + scrollViewHeight
                return scrollPosition > contentHeight - 200
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }
            .bind(to: viewModel.loadNextPage)
            .disposed(by: disposeBag)
        
        // Loading state
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                let hasProducts = !self.viewModel.products.value.isEmpty
                
                // Initial loading
                if isLoading && !hasProducts && self.searchBar.text?.isEmpty == true {
                    self.loadingView.isHidden = false
                    self.loadingView.startAnimating()
                    self.tableView.isHidden = true
                    self.tableLoadingView.isHidden = true
                    self.emptyStateView.isHidden = true
                    self.tableView.tableFooterView = nil
                }
                // Search loading
                else if isLoading && !hasProducts {
                    self.loadingView.isHidden = true
                    self.tableLoadingView.isHidden = false
                    self.tableLoadingView.startAnimating()
                    self.tableView.isHidden = true
                    self.emptyStateView.isHidden = true
                    self.tableView.tableFooterView = nil
                }
                // Pagination loading (footer)
                else if isLoading && hasProducts {
                    self.loadingView.isHidden = true
                    self.tableLoadingView.isHidden = true
                    self.tableView.isHidden = false
                    self.emptyStateView.isHidden = true
                    self.tableView.tableFooterView = self.footerLoadingView
                }
                // Not loading
                else {
                    self.loadingView.isHidden = true
                    self.loadingView.stopAnimating()
                    self.tableLoadingView.isHidden = true
                    self.tableLoadingView.stopAnimating()
                    self.tableView.tableFooterView = nil
                  
                }
            })
            .disposed(by: disposeBag)
        
        // Refreshing state
        viewModel.isRefreshing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        // Empty state - Only show when NOT loading
        Observable.combineLatest(
            viewModel.isEmpty,
            viewModel.isLoading
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] isEmpty, isLoading in
            guard let self = self else { return }
            
            // Show empty state only if empty AND not loading
            if isEmpty && !isLoading {
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
            }
        })
        .disposed(by: disposeBag)
        
        // Error handling
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        // Sort option changes - Update UI and clear search
        viewModel.sortOption
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] option in
                guard let self = self else { return }
                
                // Update sort button icon
                self.updateSortButton(isActive: option != nil)
                
                // Clear search when sort changes
                if !self.searchBar.text.isNullOrEmpty {
                    self.searchBar.text = ""
                    self.viewModel.searchQuery.accept("")
                    Logger.shared.logUserAction("Search cleared due to sort change")
                }
            })
            .disposed(by: disposeBag)
        
        // Filter option changes - Update UI and clear search
        viewModel.filterOptions
            .skip(1) // Skip initial value
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] options in
                guard let self = self else { return }
                
                // Update filter button icon
                self.updateFilterButton(isActive: options.isActive)
                
                // Clear search when filter changes (like sort behavior)
                if !self.searchBar.text.isNullOrEmpty {
                    self.searchBar.text = ""
                    self.viewModel.searchQuery.accept("")
                    Logger.shared.logUserAction("Search cleared due to filter change")
                }
                
                Logger.shared.logUserAction("Filter button updated - Active: \(options.isActive)")
            })
            .disposed(by: disposeBag)
        
        storageService.favorites
            .skip(1) 
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateVisibleCellsFavoriteState()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func filterTapped() {
        let filterVC = FilterViewController(currentFilters: viewModel.filterOptions.value)
        filterVC.onFiltersApplied = { [weak self] filterOptions in
            self?.viewModel.filterOptions.accept(filterOptions)
            Logger.shared.logUserAction("Filters applied from ProductList")
        }
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Sort By", message: "Choose sorting option", preferredStyle: .actionSheet)
        
        for option in SortOption.allCases {
            let isSelected = viewModel.sortOption.value == option
            let action = UIAlertAction(title: option.displayName, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.sortOption.accept(option)
                
                // Log user action
                Logger.shared.logUserAction("Sort selected: \(option.displayName)")
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            
            // Add checkmark if currently selected
            if isSelected {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        // Add "Clear Sort" option if sort is active
        if viewModel.sortOption.value != nil {
            let clearAction = UIAlertAction(title: "Clear Sort", style: .destructive) { [weak self] _ in
                self?.viewModel.sortOption.accept(nil)
                Logger.shared.logUserAction("Sort cleared")
            }
            alert.addAction(clearAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(alert, animated: true)
    }
    
    private func toggleFavorite(_ product: Product) {
        if storageService.isFavorite(product.id) {
            storageService.removeFromFavorites(product.id)
        } else {
            storageService.addToFavorites(product)
        }
    }
    
    private func addToCart(_ product: Product) {
        storageService.addToCart(product)
    }
    
    private func navigateToDetail(product: Product) {
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func clearFilters() {
        viewModel.filterOptions.accept(.empty)
        searchBar.text = ""
        viewModel.searchQuery.accept("")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.widthAnchor.constraint(equalToConstant: 200),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    private func updateSortButton(isActive: Bool) {
        guard let sortButton = navigationItem.rightBarButtonItems?.last else { return }
        
        if isActive {
            // Change to filled icon when sort is active
            sortButton.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
            sortButton.tintColor = .systemBlue
        } else {
            // Default icon when no sort
            sortButton.image = UIImage(systemName: "arrow.up.arrow.down")
            sortButton.tintColor = .systemBlue
        }
    }
    
    private func updateFilterButton(isActive: Bool) {
        guard let filterButton = navigationItem.rightBarButtonItems?.first else { return }
        
        if isActive {
            // Change to filled icon when filter is active
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
            filterButton.tintColor = .systemBlue
        } else {
            // Default icon when no filter
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
            filterButton.tintColor = .systemBlue
        }
    }
    
    private func updateVisibleCellsFavoriteState() {
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            guard let cell = tableView.cellForRow(at: indexPath) as? ProductCell else { continue }
            guard indexPath.row < viewModel.products.value.count else { continue }
            
            let product = viewModel.products.value[indexPath.row]
            let isFavorite = storageService.isFavorite(product.id)
            cell.favoriteButton.isSelected = isFavorite
        }
    }
}

// MARK: - UISearchBarDelegate
extension ProductListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
