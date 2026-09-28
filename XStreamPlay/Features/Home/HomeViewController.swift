//
//  HomeViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit

import Combine

/// The Home screen: a vertical list of rails (Trending, Popular, …).
///
/// Displays `HomeViewModel.rails` and forwards taps to its router.
/// Create it with `AppDIContainer.makeHomeViewController(router:)`.
final class HomeViewController: UIViewController, StoryboardIdentifiable {

    typealias Router = MovieDetailsRouting & SeeAllRouting

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Dependencies

    private let viewModel: HomeViewModel
    private weak var router: Router?
    private let haptics: HapticFeedbackProviding

    // MARK: - State

    /// The view's own copy of the rails. The data source reads only this.
    private var rails: [MovieRailContent] = []
    private var cancellables = Set<AnyCancellable>()

    private enum Layout {
        static let railHeight: CGFloat = 210
    }

    // MARK: - Init

    init?(coder: NSCoder, viewModel: HomeViewModel, router: Router, haptics: HapticFeedbackProviding) {
        self.viewModel = viewModel
        self.router = router
        self.haptics = haptics
        super.init(coder: coder)
    }

    @available(*, unavailable, message: "Use AppDIContainer.makeHomeViewController(router:)")
    required init?(coder: NSCoder) {
        fatalError("HomeViewController needs its dependencies. Use AppDIContainer.makeHomeViewController(router:).")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupTableView()
        bindViewModel()
        loadRails()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.register(MovieRailCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = Layout.railHeight
    }

    private func bindViewModel() {
        viewModel.$rails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rails in
                // `@Published` emits before the property changes, so use the
                // value passed in here, never `viewModel.rails`.
                self?.apply(rails)
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

    // MARK: - Rendering

    /// Updates only the rails that changed, so rails that are being
    /// scrolled keep their position.
    private func apply(_ newRails: [MovieRailContent]) {
        let oldRails = rails
        rails = newRails

        guard oldRails.count == newRails.count else {
            tableView.reloadData()
            return
        }
        for (index, rail) in newRails.enumerated() where rail != oldRails[index] {
            let indexPath = IndexPath(row: index, section: 0)
            (tableView.cellForRow(at: indexPath) as? MovieRailCell)?.configure(with: rail)
        }
    }

    private func showError(_ message: String) {
        AppAlert.show(on: self, message: message) { [weak self] in
            self?.loadRails()
        }
    }

    // MARK: - Actions

    private func loadRails() {
        Task { [weak self] in
            await self?.viewModel.load()
        }
    }

    private func openDetails(for movie: Movie) {
        haptics.play(.light)
        router?.showMovieDetails(for: movie)
    }

    private func openSeeAll(for rail: MovieRail) {
        haptics.play(.selection)
        router?.showSeeAll(title: rail.title, source: rail.source)
    }

    private func loadMore(railIndex: Int, displayedIndex: Int) {
        Task { [weak self] in
            await self?.viewModel.loadMoreIfNeeded(railIndex: railIndex, displayedIndex: displayedIndex)
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieRailCell = tableView.dequeueReusableCell(for: indexPath)
        let content = rails[indexPath.row]
        let railIndex = indexPath.row

        cell.configure(with: content)
        cell.onMovieSelected = { [weak self] movie in
            self?.openDetails(for: movie)
        }
        cell.onSeeAllTapped = { [weak self] in
            self?.openSeeAll(for: content.rail)
        }
        cell.onItemDisplayed = { [weak self] itemIndex in
            self?.loadMore(railIndex: railIndex, displayedIndex: itemIndex)
        }
        return cell
    }
}
