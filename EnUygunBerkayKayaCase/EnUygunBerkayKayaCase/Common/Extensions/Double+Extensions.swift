//
//  Double+Extensions.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

extension Double {
    var formattedPrice: String {
        return String(format: "$%.2f", self)
    }
}
