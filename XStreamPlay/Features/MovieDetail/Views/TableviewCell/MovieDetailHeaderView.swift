//
//  MovieDetailHeaderView.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

//final class MovieDetailHeaderView: UITableViewHeaderFooterView {
//
//    @IBOutlet weak var posterImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var subTitleLabel: UILabel!
//
//    static let reuseIdentifier = "MovieDetailHeaderView"
//
//    static func loadNib() -> UINib {
//        return UINib(nibName: "MovieDetailHeaderView", bundle: nil)
//    }
//}



import UIKit

final class MovieDetailHeaderView: UITableViewHeaderFooterView {

//    @IBOutlet weak var posterImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var underlineView: UIView!

    static let reuseIdentifier = "MovieDetailHeaderView"

    static func loadNib() -> UINib {
        return UINib(nibName: "MovieDetailHeaderView", bundle: nil)
    }

    static func loadFromNib() -> MovieDetailHeaderView {
        let nib = UINib(nibName: "MovieDetailHeaderView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! MovieDetailHeaderView
    }
}
