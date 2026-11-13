//
//  BookTableViewCell.swift
//  Assignment 9
//
//  Created by Akerke Zhanykul on 05.11.2026.
//


import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!

    func configure(with book: FavoriteBook) {
        bookImageView.image = UIImage(named: book.imageName)
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle

        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            guard let starImageView = view as? UIImageView else { continue }

            let symbolName = index < book.rating ? "star.fill" : "star"
            starImageView.image = UIImage(systemName: symbolName)
        }
    }
}
