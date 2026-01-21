//
//  CastDetailsTVC.swift
//  Playbox TV
//
//  Created by Dileep chauhan on 18/12/25.
//

import Foundation
import UIKit

class CastDetailsTVC: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    
    static let reuseIdentifier = "CastDetailsTVC"

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        setupView()
    }
    
    func loadNib() -> UINib {
        return UINib(nibName: CastDetailsTVC.reuseIdentifier, bundle: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StarringCVC.loadNib(), forCellWithReuseIdentifier: StarringCVC.reuseIdentifier)
    }
}

extension CastDetailsTVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StarringCVC.reuseIdentifier, for: indexPath) as? StarringCVC else {
            return UICollectionViewCell()
        }
        
        return cell

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
