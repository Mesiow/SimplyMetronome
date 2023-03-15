//
//  SettingCell.swift
//  SimplyMetronome
//
//  Created by Mesiow on 3/13/23.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    var callback : ((Bool)->())?
    
    @IBAction func switchTriggered(_ sender: UISwitch) {
        callback?(sender.isOn);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.layer.cornerRadius = 8;
        settingSwitch.isOn = false;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
