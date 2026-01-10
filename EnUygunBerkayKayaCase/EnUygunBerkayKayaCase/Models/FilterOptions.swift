//
//  FilterOptions.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

struct FilterOptions {
    var category: String?
    var minPrice: Double?
    var maxPrice: Double?
    var minRating: Double?
    var inStock: Bool = false
    
    var isActive: Bool {
        category != nil || minPrice != nil || maxPrice != nil || minRating != nil || inStock
    }
    
    static var empty: FilterOptions {
        FilterOptions()
    }
}

enum SortOption: String, CaseIterable {
    case titleAsc = "title_asc"
    case titleDesc = "title_desc"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case ratingDesc = "rating_desc"
    
    var displayName: String {
        switch self {
        case .titleAsc: return "Name (A-Z)"
        case .titleDesc: return "Name (Z-A)"
        case .priceAsc: return "Price (Low to High)"
        case .priceDesc: return "Price (High to Low)"
        case .ratingDesc: return "Rating (High to Low)"
        }
    }
    
    var sortBy: String {
        switch self {
        case .titleAsc, .titleDesc: return "title"
        case .priceAsc, .priceDesc: return "price"
        case .ratingDesc: return "rating"
        }
    }
    
    var order: String {
        switch self {
        case .titleAsc, .priceAsc: return "asc"
        case .titleDesc, .priceDesc, .ratingDesc: return "desc"
        }
    }
}
