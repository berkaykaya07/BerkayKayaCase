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
        
        // Empty State
        emptyStateView.pinToSuperview()
        emptyStateView.isHidden = true
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearCartTapped)
        )
    }
    
    private func setupBindings() {
        // TODO: Will be implemented in next commit
    }
    
    // MARK: - Actions
    
    @objc private func clearCartTapped() {
        // TODO: Clear cart
    }
}
