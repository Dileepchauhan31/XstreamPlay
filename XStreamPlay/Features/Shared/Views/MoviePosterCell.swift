//
//  MoviePosterCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit

/// A single poster, with an optional title underneath.
///
/// Used inside `MovieRailCell` and in the See All grid. While the image is
/// loading (or when there is none), the title is shown on top of the poster
/// as a placeholder.
final class MoviePosterCell: UICollectionViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var placeholderTitleLabel: UILabel!
    @IBOutlet private weak var titleContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleHeightConstraint: NSLayoutConstraint!

    private enum Layout {
        static let cornerRadius: CGFloat = 4
        static let titleHeight: CGFloat = 36
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Without this, a slow download for the previous movie can land in
        // this recycled cell and show the wrong poster.
        posterImageView.cancelRemoteImageLoad()
        posterImageView.image = nil
        showPlaceholder(true)
    }

    // MARK: - Configuration

    func configure(with movie: Movie, showsTitle: Bool) {
        placeholderTitleLabel.text = movie.title
        titleLabel.text = movie.title

        titleContainerView.isHidden = !showsTitle
        titleHeightConstraint.constant = showsTitle ? Layout.titleHeight : 0

        showPlaceholder(true)
        posterImageView.setRemoteImage(from: movie.posterURL) { [weak self] didLoad in
            self?.showPlaceholder(!didLoad)
        }
    }

    // MARK: - Setup

    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.layer.cornerRadius = Layout.cornerRadius
        posterImageView.clipsToBounds = true

        placeholderTitleLabel.font = .boldSystemFont(ofSize: 14)
        placeholderTitleLabel.textColor = .white
        placeholderTitleLabel.textAlignment = .center
        placeholderTitleLabel.numberOfLines = 2

        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        showPlaceholder(true)
    }

    // MARK: - Private

    private func showPlaceholder(_ isVisible: Bool) {
        placeholderTitleLabel.isHidden = !isVisible
        posterImageView.layer.borderWidth = isVisible ? 1.5 : 0
        posterImageView.layer.borderColor = isVisible
            ? UIColor.white.withAlphaComponent(0.6).cgColor
            : UIColor.clear.cgColor
    }
}
