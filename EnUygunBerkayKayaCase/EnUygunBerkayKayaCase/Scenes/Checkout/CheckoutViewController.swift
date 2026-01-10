//
//  CheckoutViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa

final class CheckoutViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CheckoutViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // Order Summary Section
    private let orderSummaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Summary"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let taxLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    // User Information Section
    private let userInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delivery Information"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name *"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email *"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone *"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private let addressTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }()
    
    private let addressPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Delivery Address *"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        return label
    }()
    
    // Payment Method Section
    private let paymentMethodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Method"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let paymentMethodStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let placeOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Place Order", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        setupPaymentMethods()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Checkout"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            orderSummaryTitleLabel,
            itemCountLabel,
            subtotalLabel,
            taxLabel,
            totalLabel,
            userInfoTitleLabel,
            fullNameTextField,
            emailTextField,
            phoneTextField,
            addressTextView,
            addressPlaceholderLabel,
            paymentMethodTitleLabel,
            paymentMethodStackView
        )
        
        view.addSubview(placeOrderButton)
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor, constant: -16)
        ])
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Order Summary Title
        orderSummaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orderSummaryTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            orderSummaryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            orderSummaryTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Item Count
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemCountLabel.topAnchor.constraint(equalTo: orderSummaryTitleLabel.bottomAnchor, constant: 12),
            itemCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Subtotal
        subtotalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtotalLabel.topAnchor.constraint(equalTo: itemCountLabel.bottomAnchor, constant: 8),
            subtotalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtotalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Tax
        taxLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taxLabel.topAnchor.constraint(equalTo: subtotalLabel.bottomAnchor, constant: 4),
            taxLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taxLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Total
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: taxLabel.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // User Info Title
        userInfoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInfoTitleLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 32),
            userInfoTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userInfoTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Full Name
        fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fullNameTextField.topAnchor.constraint(equalTo: userInfoTitleLabel.bottomAnchor, constant: 16),
            fullNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fullNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fullNameTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Email
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Phone
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Address TextView
        addressTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressTextView.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12),
            addressTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addressTextView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Address Placeholder
        addressPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressPlaceholderLabel.topAnchor.constraint(equalTo: addressTextView.topAnchor, constant: 8),
            addressPlaceholderLabel.leadingAnchor.constraint(equalTo: addressTextView.leadingAnchor, constant: 8)
        ])
        
        // Payment Method Title
        paymentMethodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paymentMethodTitleLabel.topAnchor.constraint(equalTo: addressTextView.bottomAnchor, constant: 32),
            paymentMethodTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentMethodTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Payment Method Stack
        paymentMethodStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paymentMethodStackView.topAnchor.constraint(equalTo: paymentMethodTitleLabel.bottomAnchor, constant: 16),
            paymentMethodStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentMethodStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            paymentMethodStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Place Order Button
        placeOrderButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            placeOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupBindings() {
        // Bind text fields to ViewModel
        fullNameTextField.rx.text.orEmpty
            .bind(to: viewModel.fullName)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.phone)
            .disposed(by: disposeBag)
        
        addressTextView.rx.text.orEmpty
            .bind(to: viewModel.address)
            .disposed(by: disposeBag)
        
        // Address placeholder visibility
        addressTextView.rx.text.orEmpty
            .map { !$0.isEmpty } // Show when NOT empty
            .bind(to: addressPlaceholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Cart items count
        viewModel.cartItems
            .map { items -> String in
                let totalQuantity = items.reduce(0) { $0 + $1.quantity }
                return "\(totalQuantity) item(s) in cart"
            }
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Subtotal
        viewModel.subtotal
            .map { String(format: "Subtotal: $%.2f", $0) }
            .bind(to: subtotalLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Tax
        viewModel.tax
            .map { String(format: "Tax (18%%): $%.2f", $0) }
            .bind(to: taxLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Total
        viewModel.total
            .map { String(format: "Total: $%.2f", $0) }
            .bind(to: totalLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Form validation - Enable/disable button
        viewModel.isFormValid
            .bind(to: placeOrderButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isFormValid
            .map { $0 ? 1.0 : 0.5 }
            .bind(to: placeOrderButton.rx.alpha)
            .disposed(by: disposeBag)
        
        // Place order button tap
        placeOrderButton.rx.tap
            .bind(to: viewModel.placeOrder)
            .disposed(by: disposeBag)
        
        // Order success
        viewModel.orderPlaced
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showSuccessAndNavigate()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupPaymentMethods() {
        for method in PaymentMethod.allCases {
            let button = createPaymentMethodButton(for: method)
            paymentMethodStackView.addArrangedSubview(button)
            
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.selectPaymentMethod(method)
                    
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                })
                .disposed(by: disposeBag)
        }
        
        // Select default
        selectPaymentMethod(.creditCard)
    }
    
    private func createPaymentMethodButton(for method: PaymentMethod) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("  \(method.rawValue)", for: .normal)
        button.setImage(UIImage(systemName: method.icon), for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.tag = PaymentMethod.allCases.firstIndex(of: method) ?? 0
        return button
    }
    
    private func selectPaymentMethod(_ method: PaymentMethod) {
        viewModel.selectedPaymentMethod.accept(method)
        
        // Update UI
        for case let button as UIButton in paymentMethodStackView.arrangedSubviews {
            let isSelected = button.tag == PaymentMethod.allCases.firstIndex(of: method)
            button.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            button.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .secondarySystemBackground
        }
    }
    
    private func showSuccessAndNavigate() {
        let alert = UIAlertController(
            title: "Order Placed! 🎉",
            message: "Your order has been successfully placed. Thank you for shopping with us!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate back to products
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        Logger.shared.logUserAction("Order success alert shown")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
