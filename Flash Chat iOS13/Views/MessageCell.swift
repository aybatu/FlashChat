//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Aybatu Kerkukluoglu on 5.06.2021.
//  Copyright © 2021 Aybatu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var youImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = messageView.frame.height / 5
    }
}
