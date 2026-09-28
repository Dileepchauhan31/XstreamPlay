//
//  MovieDetailsHeroCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

/// Top of the details screen: large artwork with the title and subtitle over it.
final class MovieDetailsHeroCell: UITableViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        heroImageView.cancelRemoteImageLoad()
        heroImageView.image = nil
    }

    // MARK: - Configuration

    func configure(with content: MovieDetailsContent) {
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        heroImageView.setRemoteImage(from: content.heroImageURL)
    }
}
