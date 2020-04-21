//
//  CustomMessageCell.swift
//  LOChat
//
//  Created by Hasan Bal on 31.03.2020.
//  Copyright © 2020 bal software. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {


    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    
    
    @IBOutlet weak var messageDistance: UILabel!
    
    @IBOutlet weak var messageDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        
        
    }


}
