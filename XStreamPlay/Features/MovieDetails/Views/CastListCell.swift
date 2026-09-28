//
//  CastListCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 18/12/25.
//

import UIKit

/// A titled horizontal list of cast members, for the "Cast & more" tab.
///
/// Not shown yet: the tab is still being built. Kept here, renamed to the
/// naming convention, so it's ready when the tab is wired up.
final class CastListCell: UITableViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    private enum Layout {
        static let itemSize = CGSize(width: 100, height: 160)
        static let sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        /// Placeholder until cast data is loaded from the API.
        static let placeholderItemCount = 5
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CastMemberCell.self)
    }
}

// MARK: - UICollectionViewDataSource

extension CastListCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Layout.placeholderItemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CastMemberCell = collectionView.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CastListCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        Layout.itemSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        Layout.sectionInset
    }
}
