//
//  FavoriteBook.swift
//  Assignment 9
//
//  Created by Akerke Zhanykul on 05.11.2026.
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
