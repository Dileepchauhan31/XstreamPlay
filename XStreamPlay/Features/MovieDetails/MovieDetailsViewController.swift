//
//  MovieDetailsViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

import Combine

/// The details screen: hero image, summary and a More Like This rail.
///
/// Create it with `AppDIContainer.makeMovieDetailsViewController(for:router:)`.
final class MovieDetailsViewController: UIViewController, StoryboardIdentifiable {

    typealias Router = MovieDetailsRouting

    /// The table's sections, top to bottom.
    private enum Section: Int, CaseIterable {
        case hero
        case summary
        case moreLikeThis

        var rowHeight: CGFloat {
            switch self {
            case .hero: return 400
            case .summary: return 264
            case .moreLikeThis: return 210
            }
        }

        var headerHeight: CGFloat {
            self == .moreLikeThis ? 60 : 0
        }
    }

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Dependencies

    private let viewModel: MovieDetailsViewModel
    private weak var router: Router?
    private let haptics: HapticFeedbackProviding

    // MARK: - State

    /// The view's own copy of what to show. The data source reads only these.
    private var content: MovieDetailsContent?
    private var moreLikeThis: MovieRailContent
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init?(coder: NSCoder, viewModel: MovieDetailsViewModel, router: Router, haptics: HapticFeedbackProviding) {
        self.viewModel = viewModel
        self.router = router
        self.haptics = haptics
        self.moreLikeThis = viewModel.moreLikeThis
        super.init(coder: coder)
    }

    @available(*, unavailable, message: "Use AppDIContainer.makeMovieDetailsViewController(for:router:)")
    required init?(coder: NSCoder) {
        fatalError("MovieDetailsViewController needs its dependencies. Use AppDIContainer.makeMovieDetailsViewController(for:router:).")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupTableView()
        bindViewModel()
        loadDetails()
    }

    // MARK: - Setup

    /// Changes only this screen's `navigationItem`, never the shared
    /// navigation bar, so other screens keep their own look.
    private func setupNavigationItem() {
        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never

        let transparent = UINavigationBarAppearance()
        transparent.configureWithTransparentBackground()
        transparent.titleTextAttributes = [.foregroundColor: UIColor.label]

        let blurred = UINavigationBarAppearance()
        blurred.configureWithDefaultBackground()
        blurred.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        blurred.titleTextAttributes = [.foregroundColor: UIColor.label]

        navigationItem.scrollEdgeAppearance = transparent
        navigationItem.standardAppearance = blurred
        navigationItem.compactAppearance = blurred
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.register(MovieDetailsHeroCell.self)
        tableView.register(MovieDetailsSummaryCell.self)
        tableView.register(MovieRailCell.self)
        tableView.registerHeaderFooter(MovieDetailsTabsHeaderView.self)

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func bindViewModel() {
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                // Use the value passed in; `viewModel.content` is still the old one here.
                self?.content = content
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$moreLikeThis
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rail in
                self?.updateMoreLikeThis(rail)
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

    private func updateMoreLikeThis(_ rail: MovieRailContent) {
        moreLikeThis = rail
        let indexPath = IndexPath(row: 0, section: Section.moreLikeThis.rawValue)
        (tableView.cellForRow(at: indexPath) as? MovieRailCell)?.configure(with: rail)
    }

    private func showError(_ message: String) {
        AppAlert.show(on: self, message: message) { [weak self] in
            self?.loadDetails()
        }
    }

    // MARK: - Actions

    private func loadDetails() {
        Task { [weak self] in
            await self?.viewModel.load()
        }
    }

    private func openDetails(for movie: Movie) {
        haptics.play(.light)
        router?.showMovieDetails(for: movie)
    }

    private func loadMoreSimilar(displayedIndex: Int) {
        Task { [weak self] in
            await self?.viewModel.loadMoreSimilarIfNeeded(displayedIndex: displayedIndex)
        }
    }
}

// MARK: - UITableViewDataSource

extension MovieDetailsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        // Nothing to show until the details arrive.
        content == nil ? 0 : Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let content, let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .hero:
            let cell: MovieDetailsHeroCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: content)
            return cell

        case .summary:
            let cell: MovieDetailsSummaryCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(overview: content.overview, audioLanguages: content.audioLanguages)
            return cell

        case .moreLikeThis:
            let cell: MovieRailCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: moreLikeThis)
            cell.onMovieSelected = { [weak self] movie in
                self?.openDetails(for: movie)
            }
            cell.onItemDisplayed = { [weak self] itemIndex in
                self?.loadMoreSimilar(displayedIndex: itemIndex)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MovieDetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Section(rawValue: indexPath.section)?.rowHeight ?? UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard Section(rawValue: section) == .moreLikeThis else { return nil }
        let header: MovieDetailsTabsHeaderView = tableView.dequeueReusableHeaderFooter()
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Section(rawValue: section)?.headerHeight ?? 0
    }

    /// Shows the title in the navigation bar once the hero has scrolled away.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.title = scrollView.contentOffset.y > 0 ? content?.title : ""
    }
}
