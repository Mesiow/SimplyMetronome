//
//  SettingsViewController.swift
//  SimplyMetronome
//
//  Created by Mesiow on 3/10/23.
//

import UIKit
import Foundation



class SettingsViewController : UIViewController {
    let cellIdentifier = "ReusableSettingCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MetronomeVC!
    var metronomeSettings : MetronomeSettings!; //selected settings to send back to previous view or load from user defaults
    
    var settings : [Setting] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        loadSettings();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        //register .xib file
        tableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: cellIdentifier);
    }
    
    func loadSettings(){
        settings.append(Setting(img: UIImage(systemName: "flashlight.on.fill")!, name: "Flash Light", color: UIColor.systemYellow, id: 100));
        settings.append(Setting(img: UIImage(systemName: "speaker.wave.2.fill")!, name: "Downbeat Sound", color: UIColor.systemRed, id: 200));
        settings.append(Setting(img: UIImage(systemName: "speaker.1.fill")!, name: "Sound", color: UIColor.systemBlue, id: 300));
        settings.append(Setting(img: UIImage(systemName: "flip.horizontal.fill")!, name: "Flip Sounds", color: UIColor.systemGreen, id: 500));
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    func loadSwitchState(index: Int, cell: SettingCell){
        //switch button to original state left off
        switch settings[index].id {
        case 100: //light
            cell.settingSwitch.isOn = metronomeSettings.flashOn;
           break;
        case 200: //downbeat
            cell.settingSwitch.isOn = metronomeSettings.downbeatSoundOn;
           break;
        case 300: //mute
            cell.settingSwitch.isOn = metronomeSettings.soundOn;
           break;
        case 500:
            cell.settingSwitch.isOn = metronomeSettings.flipSoundsOn;
            break;
           
       default:
           print("Switch Setting does not exist");
        }
    }
    
    func updateSetting(index: Int){
        if settings[index].enabled {
            switch(settings[index].id){
             case 100: //light
                delegate.lightEnabled();
                break;
             case 200: //downbeat
                delegate.downBeatEnabled();
                break;
             case 300: //mute
                delegate.soundEnabled();
                break;
            case 500:
                delegate.flipSoundEnabled();
                break;
                
            default:
                print("Setting does not exist");
            }
        }else{
            //disabled
            switch(settings[index].id){
             case 100: //light
                delegate.lightDisabled();
                break;
             case 200: //downbeat
                delegate.downBeatDisabled();
                break;
             case 300: //mute
                delegate.soundDisabled();
                break;
            case 500:
                delegate.flipSoundDisabled();
                break;
                
            default:
                print("Setting does not exist");
            }
        }
        delegate.storeUserDefaults();
    }
}

// MARK: - Table View Extension
extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count + 1; //+1 to account for description of 1st option
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingCell;
        
        //Render description for flashlight
        if indexPath.row == 1 {
            //create description cell for setting above
            //remove separator line
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            cell.label.numberOfLines = 1;
            cell.label.textColor = UIColor.systemGray;
            cell.label.font = cell.label.font.withSize(12)
            cell.label.frame = cell.label.frame.offsetBy(dx: -50, dy: 0)
            cell.label.adjustsFontSizeToFitWidth = true;

            cell.label.text = "If enabled, your flashlight will light up at every downbeat";
            cell.imgView.isHidden = true;
            cell.settingSwitch.isHidden = true;
        
            return cell;
        }
        else if indexPath.row == 0 || indexPath.row > 1 {
            var idx = 0;
            if indexPath.row > 1 {
                idx = indexPath.row - 1;
            }
            
            loadSwitchState(index: idx, cell: cell);
            
            cell.imgView.image = settings[idx].img;
            cell.imgView.backgroundColor = settings[idx].color;
            cell.label.text = settings[idx].name;
            cell.callback = { newValue in
                self.settings[idx].enabled = newValue
                self.updateSetting(index: idx);
            }
            return cell;
        }
        return cell;
    }
}
