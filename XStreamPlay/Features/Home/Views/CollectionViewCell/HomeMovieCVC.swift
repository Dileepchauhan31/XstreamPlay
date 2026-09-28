//
//  HomeMovieCVC.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit
import Kingfisher

enum TMDBImageConfig {
    static let baseURL = "https://image.tmdb.org/t/p/"
    static let posterSize = "w500"
    static let posterThumbnail = "w185"
    static let posterSmall = "w154"
    static let extraLarge = "w1920_and_h1080_bestv2/"
}

final class HomeMovieCVC: UICollectionViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var centerTitleLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var bottomTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonViewtitleLbl: UIView!
    
    // MARK: - Variables
    
   static var identifier: String = "HomeMovieCVC"
        

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        posterImageView.layer.cornerRadius = 4
        posterImageView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        posterImageView.image = nil
        showPlaceholderUI(show: true)

        bottomTitleLabel.isHidden = true
        bottomTitleHeightConstraint.constant = 0
    }

    // MARK: - UI Setup

    
    static func loadNib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    private func setupUI() {

        // Poster Image
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
//        posterImageView.layer.borderWidth = 0
//        posterImageView.layer.borderColor = UIColor.clear.cgColor

        buttonViewtitleLbl.isHidden = true

        // Center Title Overlay
        titleContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        titleContainerView.layer.cornerRadius = 4
        titleContainerView.clipsToBounds = true

        centerTitleLabel.font = .boldSystemFont(ofSize: 14)
        centerTitleLabel.textColor = .white
        centerTitleLabel.textAlignment = .center
        centerTitleLabel.numberOfLines = 2

        // Bottom Title
        bottomTitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        bottomTitleLabel.textColor = .label
        bottomTitleLabel.numberOfLines = 2

        showPlaceholderUI(show: true)
    }

    // MARK: - Placeholder UI

    private func showPlaceholderUI(show: Bool) {
        titleContainerView.isHidden = !show
        centerTitleLabel.isHidden = !show

        posterImageView.layer.borderWidth = show ? 1.5 : 0
        posterImageView.layer.borderColor = show
            ? UIColor.white.withAlphaComponent(0.6).cgColor
            : UIColor.clear.cgColor
    }

    // MARK: - Configuration

    func configure(with movie: Model_Result, showBottomTitle: Bool) {

        centerTitleLabel.text = movie.title
        bottomTitleLabel.text = movie.title

        bottomTitleLabel.isHidden = !showBottomTitle
        bottomTitleHeightConstraint.constant = showBottomTitle ? 36 : 0

        showPlaceholderUI(show: true)

        guard let posterPath = movie.poster_path else {
            return
        }

        let urlString = TMDBImageConfig.baseURL +
                        TMDBImageConfig.posterSize +
                        posterPath

        guard let url = URL(string: urlString) else {
            return
        }

        posterImageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [.transition(.fade(0.25))]) { [weak self] result in
                switch result {
                case .success:
                    self?.showPlaceholderUI(show: false)
                case .failure:
                    self?.showPlaceholderUI(show: true)
                }
            }
    }
}
