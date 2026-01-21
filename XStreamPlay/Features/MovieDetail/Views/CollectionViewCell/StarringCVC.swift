//
//  StarringCVC.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 16/01/26.
//

import UIKit

class StarringCVC: UICollectionViewCell {

    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var lblProfession: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    static let reuseIdentifier = "StarringCVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

}
