//
//  FilterViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa

final class FilterViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Properties
    private let viewModel: FilterViewModel
    private let disposeBag = DisposeBag()
    var onFiltersApplied: ((FilterOptions) -> Void)?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    private let loadingView = LoadingView(message: "Loading categories...")
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filters", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
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
        view.backgroundColor = .systemGroupedBackground
        
        // Add subviews
        view.addSubviews(tableView, applyButton, loadingView)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -16)
        ])
        
        // Apply Button
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Loading view
        loadingView.pinToSuperview()
        loadingView.isHidden = true
        
        // Navigation buttons
        setupNavigationBar()
        
        // Table delegate
        tableView.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
    }
    
    private func setupBindings() {
        // Categories data source
        viewModel.categories
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "CategoryCell")) { [weak self] index, category, cell in
                guard let self = self else { return }
                
                cell.textLabel?.text = category.capitalized
                cell.selectionStyle = .none
                
                // Show checkmark if selected
                let isSelected = self.viewModel.selectedCategory.value == category
                cell.accessoryType = isSelected ? .checkmark : .none
                cell.tintColor = .systemBlue
            }
            .disposed(by: disposeBag)
        
        // Cell selection
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] category in
                guard let self = self else { return }
                
                // Toggle selection
                if self.viewModel.selectedCategory.value == category {
                    self.viewModel.selectCategory.onNext(nil) // Deselect
                } else {
                    self.viewModel.selectCategory.onNext(category) // Select
                }
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                // Reload to update checkmarks
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Apply button
        applyButton.rx.tap
            .bind(to: viewModel.applyFilters)
            .disposed(by: disposeBag)
        
        // Dismiss on apply
        viewModel.dismiss
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] filterOptions in
                self?.onFiltersApplied?(filterOptions)
                self?.dismiss(animated: true)
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            })
            .disposed(by: disposeBag)
        
        // Loading state
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.isHidden = false
                    self?.loadingView.startAnimating()
                    self?.tableView.isHidden = true
                } else {
                    self?.loadingView.isHidden = true
                    self?.loadingView.stopAnimating()
                    self?.tableView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func resetTapped() {
        // Reset filters immediately
        viewModel.resetFilters.onNext(())
        
        // Apply empty filters and dismiss
        onFiltersApplied?(.empty)
        dismiss(animated: true)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        Logger.shared.logUserAction("Filters reset and applied immediately")
    }
    
    // MARK: - UITableViewDelegate
    private func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select Category"
    }
    
    private func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let count = viewModel.categories.value.count
        return count > 0 ? "\(count) categories available" : nil
    }
}
