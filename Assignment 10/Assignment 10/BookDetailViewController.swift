//
//  BookDetailViewController.swift
//  Assignment 10
//
//  Created by Akerke Zhanykul on 12.11.2026.
//


import UIKit

class BookDetailViewController: UIViewController {

    var book: FavoriteBook?

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let book = book else { return }

        bookImageView.image = UIImage(named: book.imageName)
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle
        descriptionLabel.text = book.description

        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            guard let starImageView = view as? UIImageView else { continue }

            let symbolName = index < book.rating ? "star.fill" : "star"
            starImageView.image = UIImage(systemName: symbolName)
        }
    }
}
