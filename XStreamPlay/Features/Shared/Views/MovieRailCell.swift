//
//  MovieRailCell.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit

/// One horizontal row of posters with a title and an optional "See All" button.
///
/// Used by Home (one per rail) and by the details screen (More Like This).
/// The cell only displays. Taps are reported through the `on…` closures and
/// the owning view controller decides what happens.
final class MovieRailCell: UITableViewCell, NibReusable {

    // MARK: - Outlets

    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    @IBOutlet private weak var seeAllChevronImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Callbacks

    var onMovieSelected: ((Movie) -> Void)?
    var onSeeAllTapped: (() -> Void)?
    /// Called with the item index when a poster is about to appear, so the
    /// owner can load the next page in time.
    var onItemDisplayed: ((Int) -> Void)?

    // MARK: - State

    private var movies: [Movie] = []
    private var showsPosterTitle = false

    private enum Layout {
        static let itemSize = CGSize(width: 110, height: 160)
        static let itemSpacing: CGFloat = 8
        static let sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupCollectionView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onMovieSelected = nil
        onSeeAllTapped = nil
        onItemDisplayed = nil
        movies = []
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }

    // MARK: - Configuration

    func configure(with content: MovieRailContent) {
        titleLabel.text = content.rail.title
        headerView.isHidden = !content.rail.showsHeader
        seeAllButton.isHidden = !content.rail.showsSeeAll
        seeAllChevronImageView.isHidden = !content.rail.showsSeeAll
        showsPosterTitle = content.rail.showsPosterTitle

        guard content.movies != movies else { return }
        movies = content.movies
        collectionView.reloadData()
    }

    // MARK: - Actions

    @IBAction private func seeAllButtonTapped(_ sender: UIButton) {
        onSeeAllTapped?()
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MoviePosterCell.self)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = Layout.itemSpacing
            layout.minimumInteritemSpacing = Layout.itemSpacing
            layout.sectionInset = Layout.sectionInset
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MovieRailCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoviePosterCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: movies[indexPath.item], showsTitle: showsPosterTitle)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MovieRailCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        Layout.itemSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        onItemDisplayed?(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard movies.indices.contains(indexPath.item) else { return }
        collectionView.cellForItem(at: indexPath)?.pop()
        onMovieSelected?(movies[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.pop()
    }
}
