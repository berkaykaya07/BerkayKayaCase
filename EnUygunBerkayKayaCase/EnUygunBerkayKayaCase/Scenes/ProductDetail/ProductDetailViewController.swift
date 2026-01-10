//
//  ProductDetailViewController.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
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
    
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ProductImageCell.self, forCellWithReuseIdentifier: "ProductImageCell")
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let discountBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemRed
        button.layer.cornerRadius = 28
        button.backgroundColor = .systemBackground
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Initialization
    
    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        configureWithProduct()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            imageCollectionView,
            pageControl,
            titleLabel,
            brandLabel,
            categoryLabel,
            ratingStackView,
            priceLabel,
            originalPriceLabel,
            discountBadge,
            stockLabel,
            descriptionTitleLabel,
            descriptionLabel
        )
        
        view.addSubviews(favoriteButton, addToCartButton)
        
        // Rating stack
        let starImage = UIImageView(image: UIImage(systemName: "star.fill"))
        starImage.tintColor = .systemOrange
        ratingStackView.addArrangedSubview(starImage)
        ratingStackView.addArrangedSubview(ratingLabel)
        
        // Collection view delegate
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    private func setupConstraints() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -16)
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
        
        // Image Collection View
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
        
        // Page Control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: imageCollectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: -16)
        ])
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Brand
        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brandLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            brandLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Category
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: brandLabel.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: brandLabel.trailingAnchor, constant: 12)
        ])
        
        // Rating
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingStackView.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Price
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Original Price
        originalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            originalPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            originalPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 12)
        ])
        
        // Discount Badge
        discountBadge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            discountBadge.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            discountBadge.leadingAnchor.constraint(equalTo: originalPriceLabel.trailingAnchor, constant: 12),
            discountBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            discountBadge.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        // Stock
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stockLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            stockLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Description Title
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: stockLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        // Favorite Button (Floating)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 56),
            favoriteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add to Cart Button (Bottom)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addToCartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addToCartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addToCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupBindings() {
        // Favorite button tap
        favoriteButton.rx.tap
            .bind(to: viewModel.toggleFavorite)
            .disposed(by: disposeBag)
        
        // Add to cart button tap
        addToCartButton.rx.tap
            .bind(to: viewModel.addToCart)
            .disposed(by: disposeBag)
        
        // Is favorite state
        viewModel.isFavorite
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFavorite in
                let imageName = isFavorite ? "heart.fill" : "heart"
                self?.favoriteButton.setImage(UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)), for: .normal)
                
                // Haptic feedback
                if isFavorite {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            })
            .disposed(by: disposeBag)
        
        // Add to cart success feedback
        viewModel.addToCart
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Show toast
                self?.showToast(message: "Added to cart")
            })
            .disposed(by: disposeBag)
    }
    
    private func configureWithProduct() {
        let product = viewModel.product.value
        
        titleLabel.text = product.title
        brandLabel.text = product.brand
        categoryLabel.text = "• \(product.category.capitalized)"
        ratingLabel.text = String(format: "%.1f", product.rating)
        priceLabel.text = String(format: "$%.2f", product.discountedPrice) // Use discounted price
        descriptionLabel.text = product.description
        
        // Stock
        if product.stock > 0 {
            stockLabel.text = "In Stock: \(product.stock) available"
            stockLabel.textColor = .systemGreen
            addToCartButton.isEnabled = true
        } else {
            stockLabel.text = "Out of Stock"
            stockLabel.textColor = .systemRed
            addToCartButton.isEnabled = false
            addToCartButton.backgroundColor = .systemGray
        }
        
        // Discount
        if product.discountPercentage > 0 {
            // Show original price with strikethrough
            let attributedString = NSAttributedString(
                string: String(format: "$%.2f", product.price),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = attributedString
            originalPriceLabel.isHidden = false
            
            discountBadge.text = "-\(Int(product.discountPercentage))%"
            discountBadge.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
            discountBadge.isHidden = true
        }
        
        // Images
        pageControl.numberOfPages = product.images.count
        imageCollectionView.reloadData()
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
            toastLabel.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -16),
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

// MARK: - UICollectionViewDataSource

extension ProductDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.product.value.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath) as! ProductImageCell
        let imageURL = viewModel.product.value.images[indexPath.item]
        cell.configure(with: imageURL)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProductDetailViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - ProductImageCell

private class ProductImageCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
    }
    
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}
