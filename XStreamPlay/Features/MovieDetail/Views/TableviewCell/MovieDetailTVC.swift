//
//  MovieDetailTVC.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

class MovieDetailTVC: UITableViewCell {

    @IBOutlet weak var watchNowBtn:UIButton!
    @IBOutlet weak var detailsLabel:UILabel!
    @IBOutlet weak var subLabel:UILabel!
    
    static let reuseIdentifier = "MovieDetailTVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
