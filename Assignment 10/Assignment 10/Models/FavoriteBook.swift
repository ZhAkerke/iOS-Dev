//
//  FavoriteBook.swift
//  Assignment 10
//
//  Created by Akerke Zhanykul on 12.11.2026.
//


import Foundation

struct FavoriteBook {

    let title: String
    let author: String
    let year: Int
    let rating: Int
    let imageName: String
    let description: String

    var subtitle: String {
        return "\(author) · \(year)"
    }
}
