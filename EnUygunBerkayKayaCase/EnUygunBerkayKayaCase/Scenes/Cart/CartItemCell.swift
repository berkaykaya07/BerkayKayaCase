//
//  CartItemCell.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import Kingfisher
import RxSwift

final class CartItemCell: UITableViewCell {
    
    static let identifier = "CartItemCell"
    var disposeBag = DisposeBag()
    
    // MARK: - Callbacks
    var onQuantityChanged: ((Int) -> Void)?
    var onRemove: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let quantityContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Properties
    private var currentQuantity: Int = 1
    private var stockLimit: Int = 999
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(
            productImageView,
            titleLabel,
            priceLabel,
            quantityContainerView,
            removeButton,
            subtotalLabel
        )
        
        quantityContainerView.addSubviews(
            decreaseButton,
            quantityLabel,
            increaseButton
        )
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Product Image
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8)
        ])
        
        // Remove Button
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 32),
            removeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Price
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12)
        ])
        
        // Quantity Container
        quantityContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quantityContainerView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            quantityContainerView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            quantityContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            quantityContainerView.widthAnchor.constraint(equalToConstant: 110),
            quantityContainerView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Decrease Button
        decreaseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            decreaseButton.leadingAnchor.constraint(equalTo: quantityContainerView.leadingAnchor),
            decreaseButton.topAnchor.constraint(equalTo: quantityContainerView.topAnchor),
            decreaseButton.bottomAnchor.constraint(equalTo: quantityContainerView.bottomAnchor),
            decreaseButton.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        // Quantity Label
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quantityLabel.centerXAnchor.constraint(equalTo: quantityContainerView.centerXAnchor),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityContainerView.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 38)
        ])
        
        // Increase Button
        increaseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            increaseButton.trailingAnchor.constraint(equalTo: quantityContainerView.trailingAnchor),
            increaseButton.topAnchor.constraint(equalTo: quantityContainerView.topAnchor),
            increaseButton.bottomAnchor.constraint(equalTo: quantityContainerView.bottomAnchor),
            increaseButton.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        // Subtotal Label
        subtotalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtotalLabel.centerYAnchor.constraint(equalTo: quantityContainerView.centerYAnchor),
            subtotalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            subtotalLabel.leadingAnchor.constraint(greaterThanOrEqualTo: quantityContainerView.trailingAnchor, constant: 12)
        ])
    }
    
    private func setupActions() {
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(with cartItem: CartItem) {
        currentQuantity = cartItem.quantity
        stockLimit = cartItem.product.stock
        
        titleLabel.text = cartItem.product.title
        priceLabel.text = "$\(cartItem.product.price.formatted())"
        quantityLabel.text = "\(cartItem.quantity)"
        
        let subtotal = cartItem.product.price * Double(cartItem.quantity)
        subtotalLabel.text = "$\(subtotal.formatted())"
        
        // Update button states
        decreaseButton.isEnabled = currentQuantity > 1
        decreaseButton.alpha = currentQuantity > 1 ? 1.0 : 0.3
        
        increaseButton.isEnabled = currentQuantity < stockLimit
        increaseButton.alpha = currentQuantity < stockLimit ? 1.0 : 0.3
        
        // Load image
        if let imageURL = URL(string: cartItem.product.thumbnail) {
            productImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
    
    // MARK: - Actions
    
    @objc private func increaseTapped() {
        guard currentQuantity < stockLimit else { return }
        
        currentQuantity += 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update button states
        decreaseButton.isEnabled = true
        decreaseButton.alpha = 1.0
        increaseButton.isEnabled = currentQuantity < stockLimit
        increaseButton.alpha = currentQuantity < stockLimit ? 1.0 : 0.3
    }
    
    @objc private func decreaseTapped() {
        guard currentQuantity > 1 else { return }
        
        currentQuantity -= 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update button states
        decreaseButton.isEnabled = currentQuantity > 1
        decreaseButton.alpha = currentQuantity > 1 ? 1.0 : 0.3
        increaseButton.isEnabled = true
        increaseButton.alpha = 1.0
    }
    
    @objc private func removeTapped() {
        onRemove?()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
