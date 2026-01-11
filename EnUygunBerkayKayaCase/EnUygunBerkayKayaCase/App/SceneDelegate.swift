//
//  SceneDelegate.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay on 10.01.2026.
//

import UIKit
import RxSwift
import RxCocoa

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let disposeBag = DisposeBag()
    private let storageService = StorageService.shared
    private let logger = Logger.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        logger.logLifecycle("Scene will connect to session")
        
        window = UIWindow(windowScene: windowScene)
        
        showSplashScreen()
        
        logger.logLifecycle("Scene setup completed")
    }
    
    // MARK: - Splash Screen
    
    private func showSplashScreen() {
        let splashVC = SplashViewController()
        
        splashVC.onComplete = { [weak self] in
            self?.showMainApp()
        }
        
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
    }
    
    private func showMainApp() {
        let tabBarController = createTabBarController()
        
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = tabBarController
        }, completion: { [weak self] _ in
            self?.setupBadgeUpdates(for: tabBarController)
            Logger.shared.logLifecycle("Main app displayed")
        })
    }
    
    // MARK: - TabBar Setup
    
    private func createTabBarController() -> UITabBarController {
        let tabBar = UITabBarController()
        
        // Product List Tab
        let productsVC = ProductListViewController()
        let productsNav = UINavigationController(rootViewController: productsVC)
        productsNav.tabBarItem = UITabBarItem(
            title: "Products",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        productsNav.navigationBar.prefersLargeTitles = true
        
        // Favorites Tab
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        favoritesNav.navigationBar.prefersLargeTitles = true
        
        // Cart Tab
        let cartVC = CartViewController()
        let cartNav = UINavigationController(rootViewController: cartVC)
        cartNav.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )
        cartNav.navigationBar.prefersLargeTitles = true
        
        tabBar.viewControllers = [productsNav, favoritesNav, cartNav]
        tabBar.selectedIndex = 0
        
        // Configure TabBar Appearance
        configureTabBarAppearance(tabBar.tabBar)
        
        return tabBar
    }
    
    private func configureTabBarAppearance(_ tabBar: UITabBar) {
        // Create appearance object
        let appearance = UITabBarAppearance()
        
        // Configure background
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        // Add subtle shadow
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        appearance.shadowImage = UIImage()
        
        // Configure item colors
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Apply appearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // Additional styling
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.isTranslucent = false
        
        // Add top border for visual separation
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowRadius = 0
    }
    
    // MARK: - Badge Updates
    
    private func setupBadgeUpdates(for tabBarController: UITabBarController) {
        storageService.favorites
            .map { $0.count }
            .map { count -> String? in
                count > 0 ? "\(count)" : nil
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak tabBarController] badgeValue in
                tabBarController?.viewControllers?[1].tabBarItem.badgeValue = badgeValue
            })
            .disposed(by: disposeBag)
        
        storageService.cart
            .map { items -> Int in
                items.reduce(0) { $0 + $1.quantity }
            }
            .map { count -> String? in
                count > 0 ? "\(count)" : nil
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak tabBarController] badgeValue in
                tabBarController?.viewControllers?[2].tabBarItem.badgeValue = badgeValue
            })
            .disposed(by: disposeBag)
    }
}

