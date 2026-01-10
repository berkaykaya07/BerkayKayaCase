//
//  CartViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa

final class CartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CartViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let totalView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "Total: $0.00"
        return label
    }()
    
    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Checkout", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "cart"),
        title: "Your Cart is Empty",
        message: "Add products to get started",
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
        title = "Cart"
        view.backgroundColor = .systemBackground
        
        view.addSubviews(tableView, totalView, emptyStateView)
        totalView.addSubviews(totalLabel, checkoutButton)
        
        // TableView
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalView.topAnchor)
        ])
        
        // Total View
        totalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            totalView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Total Label
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 16),
            totalLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 20)
        ])
        
        // Checkout Button
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 12),
            checkoutButton.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
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
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearCartTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }
    
    private func setupBindings() {
        // Bind cart items to table view
        viewModel.cartItems
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: CartItemCell.identifier, cellType: CartItemCell.self)) { [weak self] index, cartItem, cell in
                cell.configure(with: cartItem)
                
                // Quantity changed callback
                cell.onQuantityChanged = { [weak self] newQuantity in
                    self?.viewModel.updateQuantity.onNext((productId: cartItem.product.id, quantity: newQuantity))
                }
                
                // Remove callback
                cell.onRemove = { [weak self] in
                    self?.showRemoveConfirmation(for: cartItem)
                }
            }
            .disposed(by: disposeBag)
        
        // Update total price
        viewModel.totalPrice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] total in
                self?.totalLabel.text = String(format: "Total: $%.2f", total)
            })
            .disposed(by: disposeBag)
        
        // Handle empty state
        viewModel.isEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                self?.emptyStateView.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
                self?.totalView.isHidden = isEmpty
                self?.navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
            })
            .disposed(by: disposeBag)
        
        // Checkout button tap
        checkoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToCheckout()
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc private func clearCartTapped() {
        let alert = UIAlertController(
            title: "Clear Cart",
            message: "Are you sure you want to remove all items from your cart?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.viewModel.clearCart.onNext(())
            Logger.shared.logUserAction("Cart cleared by user")
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        present(alert, animated: true)
    }
    
    private func showRemoveConfirmation(for cartItem: CartItem) {
        let alert = UIAlertController(
            title: "Remove Item",
            message: "Remove \(cartItem.product.title) from cart?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.viewModel.removeItem.onNext(cartItem.product.id)
            Logger.shared.logUserAction("Item removed: \(cartItem.product.title)")
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToCheckout() {
        Logger.shared.logNavigation(from: "Cart", to: "Checkout")
        let checkoutVC = CheckoutViewController()
        navigationController?.pushViewController(checkoutVC, animated: true)
    }
}
