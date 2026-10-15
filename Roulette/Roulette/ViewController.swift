//
//  ViewController.swift
//  FavoritesRoulette
//
import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let summary: String
}

class ViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    let favorites: [Favorite] = [
        Favorite(imageName: "BlackSwan",
                 title: "Black Swan",
                 summary: "A ballerina's obsession with perfection in Swan Lake ballet blurs the line between reality and madness."),
        Favorite(imageName: "DraculaALoveTale",
                 title: "Dracula: A Love Tale",
                 summary: "A cursed prince searches across centuries for his lost love."),
        Favorite(imageName: "GameOfThrones",
                 title: "Game of Thrones",
                 summary: "Based on George R. R. Martin's A Song of Ice and Fire. Noble houses fight for the Iron Throne."),
        Favorite(imageName: "GoneWithTheWind",
                 title: "Gone with the Wind",
                 summary: "Based on Margaret Mitchell's novel. The story of Scarlett O'Hara during the American Civil War."),
        Favorite(imageName: "HouseOfTheDragon",
                 title: "House of the Dragon",
                 summary: "Prequel series based on Martin's Fire & Blood. It follows House Targaryen and the civil war known as the Dance of the Dragons."),
        Favorite(imageName: "HowlsMovingCastle",
                 title: "Howl's Moving Castle",
                 summary: "Studio Ghibli film based on Diana Wynne Jones's novel. A young woman is cursed with old age and finds refuge with the wizard Howl."),
        Favorite(imageName: "Inception",
                 title: "Inception",
                 summary: "A thief who steals secrets from dreams is hired to plant an idea in someone's mind."),
        Favorite(imageName: "MemoirsOfAGeisha",
                 title: "Memoirs of a Geisha",
                 summary: "A girl sold to a geisha house in Kyoto grows into one of its most famous geishas."),
        Favorite(imageName: "TheWindRises",
                 title: "The Wind Rises",
                 summary: "Hayao Miyazaki's film about Jiro Horikoshi, an engineer who dreams of flight and designs Japanese fighter planes."),
        Favorite(imageName: "WhenMarnieWasThere",
                 title: "When Marnie Was There",
                 summary: "Studio Ghibli film based on Joan G. Robinson's novel. A lonely girl befriends a mysterious Marnie in a quiet seaside town.")
    ]

    private var currentIndex: Int?


    override func viewDidLoad() {
        super.viewDidLoad()

        posterImageView.contentMode = .scaleAspectFit

        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0

        showRandomFavorite()
    }


    @IBAction func buttonDidTap(_ sender: UIButton) {
        showRandomFavorite()
    }

    // MARK: - Helpers

    private func showRandomFavorite() {
        var candidates = Array(favorites.indices)
        if let current = currentIndex {
            candidates.removeAll { $0 == current }
        }

        guard let next = candidates.randomElement() else { return }

        currentIndex = next
        show(favorites[next])
    }

    private func show(_ favorite: Favorite) {
        posterImageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.summary
    }
}
