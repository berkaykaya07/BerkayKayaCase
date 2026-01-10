//
//  EmptyStateView.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit

final class EmptyStateView: UIView {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    var actionHandler: (() -> Void)?
    
    init(
        image: UIImage?,
        title: String,
        message: String,
        actionTitle: String? = nil
    ) {
        super.init(frame: .zero)
        self.imageView.image = image
        self.titleLabel.text = title
        self.messageLabel.text = message
        
        if let actionTitle = actionTitle {
            self.actionButton.setTitle(actionTitle, for: .normal)
            self.actionButton.isHidden = false
        } else {
            self.actionButton.isHidden = true
        }
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubviews(imageView, titleLabel, messageLabel, actionButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSize(CGSize(width: 120, height: 120))
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func actionButtonTapped() {
        actionHandler?()
    }
}
