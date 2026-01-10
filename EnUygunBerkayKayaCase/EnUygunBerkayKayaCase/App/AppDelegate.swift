//
//  AppDelegate.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay on 10.01.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let logger = Logger.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.logLifecycle("Application did finish launching")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        logger.logLifecycle("Configuring scene session")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        logger.logLifecycle("Did discard scene sessions")
    }
}

