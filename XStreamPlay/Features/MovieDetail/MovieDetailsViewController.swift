//
//  MovieDetailsViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit
import Combine

class MovieDetailsViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var DetailtableView: UITableView!
    private let viewModel = MovieDetailsViewModel()
    private var cancellables = Set<AnyCancellable>()
    var movieId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTableView()
        bindViewModel()
        viewModel.fetchMovieDetails(movieId: movieId ?? 0)
        setupNavigationBarAppearance()
    }

    // MARK: - Table Setup
    private func setupTableView() {
        DetailtableView.dataSource = self
        DetailtableView.delegate = self
        
        DetailtableView.contentInsetAdjustmentBehavior = .never
        DetailtableView.backgroundColor = .clear

        DetailtableView.register(MovieHeaderTVC.loadNib(),forCellReuseIdentifier: MovieHeaderTVC.reuseIdentifier)
        DetailtableView.register(MovieDetailTVC.loadNib(),forCellReuseIdentifier: MovieDetailTVC.reuseIdentifier)
        DetailtableView.register(MovieDetailHeaderView.loadNib(),forHeaderFooterViewReuseIdentifier: MovieDetailHeaderView.reuseIdentifier)

        DetailtableView.rowHeight = UITableView.automaticDimension
        DetailtableView.estimatedRowHeight = 500
        
        if #available(iOS 15, *) {
            DetailtableView.sectionHeaderTopPadding = 0
        }
    }

    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
            viewModel.$movieDetails
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.DetailtableView.reloadData()
                }
                .store(in: &cancellables)
        }
    
    // MARK: setup NavigationBarAppearance

        func setupNavigationBarAppearance() {
            title = ""
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            guard let navigationBar = navigationController?.navigationBar else { return }

            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.backgroundColor = .clear
            scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]

            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithDefaultBackground()
            standardAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
            standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]

            navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            navigationBar.standardAppearance = standardAppearance
            navigationBar.compactAppearance = standardAppearance
        }

}

// MARK: - UITableViewDataSource & Delegate
extension MovieDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let movie = viewModel.movieDetails else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            guard let movieHeaderTVC = tableView.dequeueReusableCell(withIdentifier: MovieHeaderTVC.reuseIdentifier,for: indexPath) as? MovieHeaderTVC else {
               return  UITableViewCell()
            }
            movieHeaderTVC.configData(movie:movie)
            return movieHeaderTVC

        case 1:
            return tableView.dequeueReusableCell(withIdentifier: MovieDetailTVC.reuseIdentifier,for: indexPath)

        default:
            return UITableViewCell()
        }
    }

   
    func tableView(_ tableView: UITableView,viewForHeaderInSection section: Int) -> UIView? {

        guard section == 2 else { return nil }

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MovieDetailHeaderView.reuseIdentifier) as! MovieDetailHeaderView
        return header
    }


    func tableView(_ tableView: UITableView,heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 60 : 0
    }

    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
            case 0:
            return 400
        case 1:
            return 230
        default:
            return UITableView.automaticDimension
        }
       
    }
}

//MARK: - ScrollView Delegate
extension MovieDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold: CGFloat = 0

        if scrollView.contentOffset.y > threshold {
            navigationItem.title = viewModel.movieDetails?.title ?? ""
        } else {
            navigationItem.title = ""
        }
    }
}
