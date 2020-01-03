//
//  ArticleCell.swift
//  ArticlesRibs
//
//  Created by HoangVanDuc on 12/22/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import Kingfisher

class ArticleCell: UITableViewCell {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.parentView.layer.borderColor = UIColor.gray.cgColor
        self.parentView.layer.borderWidth = 0.5
    }
    
    func binData(docs: DocsEntity) {
        nameLabel.text = docs.headline?.main
        nameLabel.text = convertDateToString(date: docs.pubDate ?? Date())
        descriptionLabel.text = docs.snippet
        
        //load image
        if let multimedia = docs.multimedia,
            multimedia.count > 0,
            let urlString = multimedia[0].url
            {
            articleImageView.setImage("https://www.nytimes.com/\(urlString)")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}

extension UIImageView {
    func setImage(_ urlString: String) {
        if let url = URL(string: urlString){
            let placeholder = UIImage(named: "ic_default_article")
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url,placeholder: placeholder)
        }
    }
}
