//
//  SeeAllViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//

import UIKit
import Combine

final class SeeAllViewController: UIViewController, StoryboardIdentifiable{

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    var viewModel: SeeAllViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        title = viewModel.title

        setupCollectionView()
        bindViewModel()
        viewModel.fetchNextPage()
    }
}


private extension SeeAllViewController {

    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeMovieCVC.loadNib(),forCellWithReuseIdentifier: HomeMovieCVC.identifier) }

    func bindViewModel() {
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}


extension SeeAllViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HomeMovieCVC",
            for: indexPath
        ) as? HomeMovieCVC else {
            return UICollectionViewCell()
        }

        let movie = viewModel.movies[indexPath.item]
        cell.configure(with: movie, showBottomTitle: true)

        return cell
    }
}


extension SeeAllViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        let lastIndex = viewModel.movies.count - 1

        if indexPath.item == lastIndex {
            viewModel.fetchNextPage()
        }
    }
}



extension SeeAllViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 3
        let spacing: CGFloat = 8

        let totalSpacing = spacing * (columns + 1) // 3 cells + left/right
        let width = (collectionView.bounds.width - totalSpacing) / columns
        let height = width * 1.55  // poster aspect ratio

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
