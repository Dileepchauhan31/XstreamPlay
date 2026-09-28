//
//  MovieDetailsSummaryCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

/// The Watch Now button, the action row (Watchlist, Download, Share,
/// Trailers), the overview and the audio languages.
final class MovieDetailsSummaryCell: UITableViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var watchNowButton: UIButton!
    @IBOutlet private weak var overviewLabel: UILabel!
    @IBOutlet private weak var audioLanguagesLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    // MARK: - Configuration

    func configure(overview: String, audioLanguages: String?) {
        overviewLabel.text = overview
        audioLanguagesLabel.text = audioLanguages
        audioLanguagesLabel.isHidden = audioLanguages == nil
    }
}
