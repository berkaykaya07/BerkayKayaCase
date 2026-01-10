//
//  Constants.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

enum Constants {
    
    // MARK: - API
    enum API {
        static let baseURL = "https://dummyjson.com"
        static let timeout: TimeInterval = 30
    }
    
    // MARK: - Pagination
    enum Pagination {
        static let defaultLimit = 20
        static let pageSize = 20
    }
    
    // MARK: - Debounce
    enum Debounce {
        static let searchDelay: Double = 0.3 // 300ms
    }
    
    // MARK: - Storage Keys
    enum StorageKey {
        static let cart = "user_cart"
        static let favorites = "user_favorites"
    }
    
    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5
    }
    
    // MARK: - UI
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.1
    }
}
