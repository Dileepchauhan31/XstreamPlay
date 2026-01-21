//
//  MovieHeaderTVC.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit
import Kingfisher

class MovieHeaderTVC: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    static let reuseIdentifier = "MovieHeaderTVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    func configData(movie: Model_MovieDetails?) {
        guard let movie = movie else {
            titleLabel.text = ""
            subTitle.text = ""
            return
        }

        titleLabel.text = movie.title ?? ""
        subTitle.text = buildSubtitle(movie: movie)
        
        guard let posterPath = movie.poster_path else {return}

        let urlString = TMDBImageConfig.baseURL +
                        TMDBImageConfig.extraLarge +
                        posterPath

        guard let url = URL(string: urlString) else { return }
        movieImageView.kf.setImage(with: url)
        
    }
    private func buildSubtitle(movie: Model_MovieDetails) -> String {

        let genreNames = movie.genres?.compactMap { $0.name } ?? []
        let genresText = genreNames.joined(separator: " • ")

        let releaseYear: String
        if let date = movie.release_date, !date.isEmpty {
            releaseYear = String(date.prefix(4))
        } else {
            releaseYear = "N/A"
        }

        let adultText = movie.adult == true ? "18+" : "U/A"

        var components: [String] = []

        if !genresText.isEmpty {
            components.append(genresText)
        }
        components.append(releaseYear)
        components.append(adultText)
        return components.joined(separator: " • ")
    }

}
