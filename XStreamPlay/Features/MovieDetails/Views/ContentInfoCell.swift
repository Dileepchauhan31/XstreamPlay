//
//  ContentInfoCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 16/01/26.
//

import UIKit

/// A title with a multi-line value under it (e.g. "Director" / "Christopher Nolan").
///
/// Not shown yet; kept for the details tabs that are still being built.
final class ContentInfoCell: UITableViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Configuration

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
