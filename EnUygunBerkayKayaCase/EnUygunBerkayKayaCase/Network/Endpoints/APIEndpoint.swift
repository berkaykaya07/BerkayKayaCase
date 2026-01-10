//
//  APIEndpoint.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

enum APIEndpoint {
    case products(limit: Int, skip: Int, sortBy: String? = nil, order: String? = nil)
    case productDetail(id: Int)
    case searchProducts(query: String, sortBy: String? = nil, order: String? = nil)
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
        case .products(let limit, let skip, let sortBy, let order):
            var items = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "skip", value: "\(skip)")
            ]
            if let sortBy = sortBy {
                items.append(URLQueryItem(name: "sortBy", value: sortBy))
            }
            if let order = order {
                items.append(URLQueryItem(name: "order", value: order))
            }
            return items
            
        case .searchProducts(let query, let sortBy, let order):
            var items = [URLQueryItem(name: "q", value: query)]
            if let sortBy = sortBy {
                items.append(URLQueryItem(name: "sortBy", value: sortBy))
            }
            if let order = order {
                items.append(URLQueryItem(name: "order", value: order))
            }
            return items
            
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
