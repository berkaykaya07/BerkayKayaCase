//
//  SplashViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    var onComplete: (() -> Void)?
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "enuygun_logo")
        imageView.alpha = 0
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "EnUygun"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        indicator.alpha = 0
        return indicator
    }()
    
    private var hasLogoImage: Bool {
        return logoImageView.image != nil && logoImageView.image != UIImage(systemName: "house.fill")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        if hasLogoImage {
            view.addSubviews(logoImageView, loadingIndicator)
            setupLogoConstraints()
        } else {
            view.addSubviews(logoLabel, loadingIndicator)
            setupLabelConstraints()
        }
    }
    
    private func setupLogoConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32)
        ])
    }
    
    private func setupLabelConstraints() {
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 32)
        ])
    }
    
    // MARK: - Animation
    private func startAnimation() {
        let viewToAnimate: UIView = hasLogoImage ? logoImageView : logoLabel
        
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: {
            viewToAnimate.alpha = 1.0
        }, completion: { _ in
            self.loadingIndicator.startAnimating()
            UIView.animate(withDuration: 0.3) {
                self.loadingIndicator.alpha = 1.0
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.transitionToMainApp()
        }
    }
    
    private func transitionToMainApp() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
        }, completion: { [weak self] _ in
            self?.onComplete?()
        })
    }
}
