//
//  CastMemberCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 16/01/26.
//

import UIKit

/// One cast member: photo, name and role. Used inside `CastListCell`.
final class CastMemberCell: UICollectionViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var roleLabel: UILabel!

    // MARK: - Configuration

    func configure(name: String, role: String, profileImageURL: URL?) {
        nameLabel.text = name
        roleLabel.text = role
        profileImageView.setRemoteImage(from: profileImageURL)
    }
}
