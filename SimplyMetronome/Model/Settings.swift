//
//  Settings.swift
//  SimplyMetronome
//
//  Created by Chris W on 12/4/24.
//

import UIKit

struct Setting {
    var img : UIImage;
    var name: String;
    var enabled : Bool = false;
    var color: UIColor;
    var id : Int;
}

struct MetronomeSettings{
    var flashOn : Bool = false;
    var soundOn : Bool = true;
    var downbeatSoundOn : Bool = true;
    var backgroundModeOn : Bool = false;
    var flipSoundsOn : Bool = false;
}
