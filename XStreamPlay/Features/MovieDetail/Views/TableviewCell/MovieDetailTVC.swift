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
    
    
    var setterDetailObj: Model_MovieDetails? {
        didSet {
            detailsLabel.text = setterDetailObj?.overview
            subLabel.text = "Audio Available in: \(audioAvailable(data: setterDetailObj?.spoken_languages))"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setterDetailObj = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    func audioAvailable(data: [Model_Spoken_languages]?) -> String {
        let langData = data?.compactMap({ $0.english_name})
        guard let strlangData = langData?.joined(separator: ", ") else { return ""}
        return strlangData
    }
    
}
