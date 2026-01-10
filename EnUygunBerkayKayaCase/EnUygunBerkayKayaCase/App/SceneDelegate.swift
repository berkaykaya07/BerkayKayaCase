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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let tabBarController = createTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        setupBadgeUpdates(for: tabBarController)
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
        
        tabBar.tabBar.tintColor = .systemBlue
        
        return tabBar
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

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

