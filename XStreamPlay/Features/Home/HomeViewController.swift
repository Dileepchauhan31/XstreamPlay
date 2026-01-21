//
//  HomeViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit
import Combine

final class HomeViewController: UIViewController, MovieCellDelegate, StoryboardIdentifiable {
   
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        bindViewModel()
        fetchInitialData()
    }

    private func setupTableView() {
        tableView.register(HomeBucketTVC.loadNib(),forCellReuseIdentifier: "HomeBucketTVC")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    //  TRIGGER API CALLS
    private func fetchInitialData() {
        viewModel.buckets.forEach { bucket in
            bucket.fetchNextPage()
        }
    }

    // OBSERVE DATA CHANGES
    private func bindViewModel() {
        viewModel.buckets.forEach { bucket in
            bucket.$movies
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return viewModel.buckets.count
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeBucketTVC",for: indexPath) as? HomeBucketTVC else {
            return UITableViewCell()
        }

        let bucketViewModel = viewModel.buckets[indexPath.row]
        cell.configure(with: bucketViewModel)
        cell.delegate = self
        cell.onSeeAllTapped = { [weak self] in
               self?.openSeeAll(for: bucketViewModel)
           }

        return cell
    }
    
    private func openSeeAll(for bucketVM: HomeBucketViewModel) {
        debugPrint("code is working here")
    
        let seeAllVM = SeeAllViewModel(title: bucketVM.title,
            endpointProvider: { page in bucketVM.type.endpoint(page: page)})

        let vc: SeeAllViewController = Storyboard.home.instance.instantiate()
        vc.viewModel = seeAllVM
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return viewModel.buckets[indexPath.row].cellHeight
        return 210
    }
    
//    func didSelectMovie(movieId:Int) {
//        print("movieId",movieId)
//        let vc: MovieDetailsViewController = Storyboard.home.instance.instantiate()
//        vc.movieId = movieId
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func didSelectMovie(movieId: Int) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",style: .plain,target: nil,action: nil)
        let vc: MovieDetailsViewController = Storyboard.home.instance.instantiate()
        vc.movieId = movieId
        navigationController?.navigationBar.tintColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }

}
