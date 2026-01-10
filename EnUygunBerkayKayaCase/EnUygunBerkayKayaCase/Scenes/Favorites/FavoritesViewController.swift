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
    private let storageService = StorageService.shared
    
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
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Empty State - Centered in safe area
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        emptyStateView.isHidden = true
        emptyStateView.actionHandler = { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }
    }
    
    private func setupBindings() {
        // Bind favorites to table view
        viewModel.favorites
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: ProductCell.identifier, cellType: ProductCell.self)) { [weak self] index, product, cell in
                guard let self = self else { return }
                
                let isFavorite = self.storageService.isFavorite(product.id)
                cell.configure(with: product, isFavorite: isFavorite)
                
                // Favorite button tap
                cell.favoriteButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.viewModel.removeFavorite.onNext(product.id)
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        // Show toast
                        self?.showToast(message: "Removed from favorites")
                    })
                    .disposed(by: cell.disposeBag)
                
                // Add to cart button tap
                cell.addToCartButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.viewModel.addToCart.onNext(product)
                        
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // Show toast
                        self?.showToast(message: "Added to cart")
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // Cell selection - Navigate to detail
        tableView.rx.modelSelected(Product.self)
            .subscribe(onNext: { [weak self] product in
                self?.navigateToDetail(product: product)
            })
            .disposed(by: disposeBag)
        
        // Handle empty state
        viewModel.isEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                self?.emptyStateView.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    private func navigateToDetail(product: Product) {
        Logger.shared.logNavigation(from: "Favorites", to: "ProductDetail")
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
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
}
