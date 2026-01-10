//
//  UIView+Layout.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit

extension UIView {
    
    /// Add multiple subviews at once
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    /// Pin view to all edges of its superview
    func pinToSuperview(edges: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: edges.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -edges.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -edges.bottom)
        ])
    }
    
    /// Center view in its superview
    func centerInSuperview(size: CGSize? = nil) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
        
        if let size = size {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    /// Set fixed size for the view
    func setSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    /// Pin to safe area of a view
    func pinToSafeArea(of view: UIView, edges: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: edges.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edges.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -edges.bottom)
        ])
    }
    
    /// Add rounded corners
    func roundCorners(_ radius: CGFloat = Constants.UI.cornerRadius) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    /// Add shadow
    func addShadow(
        color: UIColor = .black,
        opacity: Float = Constants.UI.shadowOpacity,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = Constants.UI.shadowRadius
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
