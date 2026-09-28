//
//  HomeBucketTVC.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit

final class HomeBucketTVC: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var viewModel: HomeBucketViewModel?
    static let identifier = "HomeBucketTVC"
    weak var delegate: MovieCellDelegate?
    var onSeeAllTapped: (() -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupCollectionView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        transform = .identity
        titleLabel.text = nil
        onSeeAllTapped = nil
        viewModel = nil
        collectionView.setContentOffset(.zero, animated: false)
    }

    // MARK: - Setup

    static func loadNib() -> UINib {
        return UINib(nibName: "HomeBucketTVC", bundle: nil)
    }
    private func setupUI() {
        selectionStyle = .none
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label

//        seeAllButton.setTitle("See All", for: .normal)
//        seeAllButton.setTitleColor(.systemBlue, for: .normal)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(UINib(nibName: "HomeMovieCVC", bundle: nil),
                                forCellWithReuseIdentifier: "HomeMovieCVC")

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }

    // MARK: - Configuration

    func configure(with viewModel: HomeBucketViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
//        seeAllButton.isHidden = !viewModel.showSeeAll
        collectionView.reloadData()
    }

    // MARK: - Actions

    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        onSeeAllTapped?()
    }
}

// MARK: - UICollectionView Methods

extension HomeBucketTVC: UICollectionViewDataSource,
                         UICollectionViewDelegate,
                         UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel?.movies.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let viewModel = viewModel,
              indexPath.item < viewModel.movies.count,
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HomeMovieCVC",for: indexPath) as? HomeMovieCVC
        else {
            return UICollectionViewCell()
        }
        
        let movie = viewModel.movies[indexPath.item]
        cell.configure(with: movie,showBottomTitle: viewModel.showPosterTitle)
        
        return cell
    }


    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 110,height: 160)
    }
    
    // MARK: - didSelect
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        FeedbackManager.trigger(.light)
        cell.pop()
        delegate?.didSelectMovie(movieId: viewModel?.movies[indexPath.item].id ?? 0)
        
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {

        collectionView.cellForItem(at: indexPath)?.transform =
            CGAffineTransform(scaleX: 0.90, y: 0.90)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.pop()
    }

}
