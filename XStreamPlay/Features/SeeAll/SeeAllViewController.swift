//
//  SeeAllViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//

import UIKit

import Combine

/// A three-column grid of every title in a list, with infinite scrolling.
///
/// Create it with `AppDIContainer.makeSeeAllViewController(title:source:router:)`.
final class SeeAllViewController: UIViewController, StoryboardIdentifiable {

    typealias Router = MovieDetailsRouting

    // MARK: - Outlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Dependencies

    private let viewModel: SeeAllViewModel
    private weak var router: Router?
    private let haptics: HapticFeedbackProviding

    // MARK: - State

    /// The view's own copy of the titles. The data source reads only this.
    private var movies: [Movie] = []
    private var cancellables = Set<AnyCancellable>()

    private enum Layout {
        static let columns: CGFloat = 3
        static let spacing: CGFloat = 8
        /// Poster height divided by width, plus room for the title.
        static let heightRatio: CGFloat = 1.55
    }

    // MARK: - Init

    init?(coder: NSCoder, viewModel: SeeAllViewModel, router: Router, haptics: HapticFeedbackProviding) {
        self.viewModel = viewModel
        self.router = router
        self.haptics = haptics
        super.init(coder: coder)
    }

    @available(*, unavailable, message: "Use AppDIContainer.makeSeeAllViewController(title:source:router:)")
    required init?(coder: NSCoder) {
        fatalError("SeeAllViewController needs its dependencies. Use AppDIContainer.makeSeeAllViewController(title:source:router:).")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        setupCollectionView()
        bindViewModel()
        loadNextPage()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.backgroundColor = .clear
        collectionView.register(MoviePosterCell.self)
    }

    private func bindViewModel() {
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.movies = movies
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showError(message)
            }
            .store(in: &cancellables)
    }

    private func showError(_ message: String) {
        AppAlert.show(on: self, message: message) { [weak self] in
            self?.loadNextPage()
        }
    }

    // MARK: - Actions

    private func loadNextPage() {
        Task { [weak self] in
            await self?.viewModel.loadNextPage()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SeeAllViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoviePosterCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: movies[indexPath.item], showsTitle: true)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SeeAllViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let index = indexPath.item
        Task { [weak self] in
            await self?.viewModel.loadMoreIfNeeded(displayedIndex: index)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard movies.indices.contains(indexPath.item) else { return }
        collectionView.cellForItem(at: indexPath)?.pop()
        haptics.play(.light)
        router?.showMovieDetails(for: movies[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SeeAllViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = Layout.spacing * (Layout.columns + 1)
        let width = (collectionView.bounds.width - totalSpacing) / Layout.columns
        return CGSize(width: width, height: width * Layout.heightRatio)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.spacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.spacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: Layout.spacing, left: Layout.spacing, bottom: Layout.spacing, right: Layout.spacing)
    }
}
