//
//  Category.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let url: String
    
    var id: String { slug }
}

// For category list endpoint
typealias CategoryList = [String]
