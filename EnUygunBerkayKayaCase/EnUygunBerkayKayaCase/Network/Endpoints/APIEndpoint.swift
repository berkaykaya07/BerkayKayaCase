//
//  APIEndpoint.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

enum APIEndpoint {
    case products(limit: Int, skip: Int)
    case productDetail(id: Int)
    case searchProducts(query: String)
    case sortProducts(sortBy: String, order: String)
    case categories
    case categoryList
    case productsByCategory(category: String)
    
    var path: String {
        switch self {
        case .products:
            return "/products"
        case .productDetail(let id):
            return "/products/\(id)"
        case .searchProducts:
            return "/products/search"
        case .sortProducts:
            return "/products"
        case .categories:
            return "/products/categories"
        case .categoryList:
            return "/products/category-list"
        case .productsByCategory(let category):
            return "/products/category/\(category)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .products(let limit, let skip):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "skip", value: "\(skip)")
            ]
        case .searchProducts(let query):
            return [URLQueryItem(name: "q", value: query)]
        case .sortProducts(let sortBy, let order):
            return [
                URLQueryItem(name: "sortBy", value: sortBy),
                URLQueryItem(name: "order", value: order)
            ]
        default:
            return nil
        }
    }
    
    func url() -> URL? {
        var components = URLComponents(string: Constants.API.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
