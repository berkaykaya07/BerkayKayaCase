//
//  LoadingView.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit

final class LoadingView: UIView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(message: String = "Loading...") {
        super.init(frame: .zero)
        self.messageLabel.text = message
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubviews(activityIndicator, messageLabel)
        
        activityIndicator.centerInSuperview()
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
