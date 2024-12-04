//
//  MetronomeVC.swift
//  SimplyMetronome
//
//  Created by Chris W on 12/4/24.
//

import UIKit
import Foundation
import AVFoundation


class MetronomeVC: UIViewController {
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    //Bpm ui
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var bpmTextField: UITextField!
    @IBOutlet weak var bpmStepper: UIStepper!
    
    //time signature ui
    @IBOutlet weak var tsView: UIView!
    @IBOutlet weak var tsUpperTextField: UITextField!
    @IBOutlet weak var tsLowerTextField: UITextField!
    
    var metronomeSettings  = MetronomeSettings();
    var torchSwitch : Bool = false;
    var active : Bool = false;
    let bpmMaxCount : Int = 200
    
    let playImage = UIImage(systemName: "play.fill");
    let pauseImage = UIImage(systemName: "pause.fill");
    let soundOnImage = UIImage(systemName: "speaker.wave.3.fill");
    let mutedImage = UIImage(systemName: "speaker.slash.fill");
    let flashOnImage = UIImage(systemName: "lightbulb.fill");
    let flashOffImage = UIImage(systemName: "lightbulb.slash.fill");
    
    let metronome = Metronome()
    
    @IBOutlet weak var settingsNavBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metronome.setup();
        metronome.onTick = metronomeCallback;
        
        initDefaults();
        initUi();
        updateUi();
        
        let notificationCenter = NotificationCenter.default
           notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        storeUserDefaults();
    }
    
    @objc func appMovedToBackground(){
        if !metronomeSettings.backgroundModeOn {
            stopMetronome();
        }
    }
    
    func initDefaults(){
        loadUserDefaults();
        toggleMetronomeSettings();
    }
    
   
    func initUi(){
        settingsNavBar.standardAppearance = UINavigationBar.appearance().standardAppearance;
        
        tsView.layer.cornerRadius = 15;
        
        tsUpperTextField.delegate = self;
        tsLowerTextField.delegate = self;
        tsUpperTextField.addDoneCancelToolbar(onDone: (target: self, action: #selector(tsUpperTextEdited)), onCancel: (target: self, action: #selector(tsUpperTextCanceled)));
        
        tsLowerTextField.addDoneCancelToolbar(onDone: (target: self, action: #selector(tsLowerTextEdited)), onCancel: (target: self, action: #selector(tsLowerTextCanceled)));
        
        bpmTextField.delegate = self;
        bpmTextField.addDoneCancelToolbar(onDone:(target: self, action: #selector(bpmTextEdited)), onCancel: (target: self, action: #selector(bpmTextCanceled)));
        bpmTextField.layer.cornerRadius = 15;
        
        
        playButton.layer.cornerRadius = 15;
        audioButton.layer.cornerRadius = 15;
        lightButton.layer.cornerRadius = 15;
        
        bpmStepper.layer.cornerRadius = 15;
        bpmStepper.maximumValue = Double(bpmMaxCount);
        
        slider.minimumValue = 0;
        slider.maximumValue = Float(bpmMaxCount);
        slider.setValue(metronome.bpm, animated: true);
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        stopMetronome(); //forcefully stop metronome
        performSegue(withIdentifier: "goToSettings", sender: self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            let destinationVC = segue.destination as! SettingsViewController;
            destinationVC.metronomeSettings = metronomeSettings;
            destinationVC.delegate = self
        }
    }
    
    func updateUi(){
        slider.setValue(metronome.bpm, animated: true)
        bpmTextField.text = String(Int(metronome.bpm));
        bpmStepper.value = Double(metronome.bpm);
    }

    
    func startMetronome() {
        playButton.setImage(pauseImage, for: .normal);
        metronome.enabled = true;
    }
    
    func stopMetronome(){
        active = false;
        playButton.setImage(playImage, for: .normal);
        metronome.enabled = false;
    }
    
    func toggleMetronomeSettings(){
        toggleSound();
        toggleLight();
        
        metronome.downbeat = metronomeSettings.downbeatSoundOn;
        metronome.beatflip = metronomeSettings.flipSoundsOn;
    }
    
    func metronomeCallback() -> Void {
        if metronomeSettings.flashOn {
            torchSwitch.toggle();
            Torch.toggle(on: torchSwitch)
        }
    }
    
   
    func soundDisabled(){
        metronomeSettings.soundOn = false;
        audioButton.setImage(mutedImage, for: .normal);
        metronome.setVolume(vol: 0.0)
    }
    
    func soundEnabled(){
        metronomeSettings.soundOn = true;
        audioButton.setImage(soundOnImage, for: .normal);
        metronome.setVolume(vol: 1.0);
    }
    
    func lightDisabled(){
        metronomeSettings.flashOn = false;
        torchSwitch = false;
        Torch.toggle(on: false);
        lightButton.setImage(flashOffImage, for: .normal);
    }
    
    func lightEnabled(){
        metronomeSettings.flashOn = true;
        torchSwitch = true;
        Torch.toggle(on: true);
        lightButton.setImage(flashOnImage, for: .normal);
    }
    
    func downBeatDisabled(){
        metronomeSettings.downbeatSoundOn = false;
        metronome.downbeat = false;
    }
    
    func downBeatEnabled(){
        metronomeSettings.downbeatSoundOn = true;
        metronome.downbeat = true;
    }
    
    func backgroundEnabled() {
        metronomeSettings.backgroundModeOn = true;
    }
    
    func backgroundDisabled(){
        metronomeSettings.backgroundModeOn = false;
    }
    
    func flipSoundEnabled(){
        metronomeSettings.flipSoundsOn = true;
        metronome.beatflip = true;
    }
    
    func flipSoundDisabled(){
        metronomeSettings.flipSoundsOn = false;
        metronome.beatflip = false;
    }
    
    func toggleSound() {
        if metronomeSettings.soundOn {
            audioButton.setImage(soundOnImage, for: .normal);
            metronome.setVolume(vol: 1.0);
        }else{
            audioButton.setImage(mutedImage, for: .normal);
            metronome.setVolume(vol: 0.0);
        }
    }
    
    func toggleLight(){
        if metronomeSettings.flashOn {
            torchSwitch = true;
            Torch.toggle(on: true);
            lightButton.setImage(flashOnImage, for: .normal);
        }else{
            torchSwitch = false;
            Torch.toggle(on: false);
            lightButton.setImage(flashOffImage, for: .normal);
        }
    }
    
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "ButtonColor");
        if sender == audioButton {
            metronomeSettings.soundOn.toggle();
            toggleSound();
            
        } else if sender == playButton {
            active.toggle();
            if active {
                startMetronome();
            }else{
                stopMetronome();
            }
        } else if sender == lightButton {
            metronomeSettings.flashOn.toggle();
            toggleLight();
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "ButtonPressedColor");
    }
    
    
    @IBAction func sliderUpdated(_ sender: UISlider) {
        metronome.bpm = sender.value.rounded(.down);
        updateUi();
    }
    
    @IBAction func stepperUpdated(_ sender: UIStepper) {
        metronome.bpm = Float(sender.value);
        updateUi();
    }
    
    
    //TextField callbacks
    @objc func bpmTextEdited() {
        if let val = Int(bpmTextField.text!) {
            metronome.bpm = Float(val);
            if val > bpmMaxCount {
                metronome.bpm = Float(bpmMaxCount);
            }
            updateUi();
        }
        bpmTextField.resignFirstResponder();
    }
    
    @objc func bpmTextCanceled() {
        updateUi();
        bpmTextField.resignFirstResponder();
    }
    
    @objc func tsUpperTextEdited(){
        if let val = Int(tsUpperTextField.text!) {
            metronome.tsUpper = val;
            tsUpperTextField.text = String(metronome.tsUpper);
        }
        tsUpperTextField.resignFirstResponder();
    }
    
    @objc func tsUpperTextCanceled(){
        tsUpperTextField.text = String(metronome.tsUpper);
        tsUpperTextField.resignFirstResponder();
    }
    
    @objc func tsLowerTextEdited(){
        if let val = Int(tsLowerTextField.text!) {
            metronome.tsLower = val;
            tsLowerTextField.text = String(metronome.tsLower);
        }
        tsLowerTextField.resignFirstResponder();
    }
    
    @objc func tsLowerTextCanceled(){
        tsLowerTextField.text = String(metronome.tsLower);
        tsLowerTextField.resignFirstResponder();
    }
    
}

//plist persistence
extension MetronomeVC {
    func storeUserDefaults() {
        let userDefaults = UserDefaults.standard;
        userDefaults.set(metronomeSettings.soundOn, forKey: UserDefaultsKeys.sound);
        userDefaults.set(metronomeSettings.flashOn, forKey: UserDefaultsKeys.flash);
        userDefaults.set(metronomeSettings.downbeatSoundOn, forKey: UserDefaultsKeys.downbeat);
        userDefaults.set(metronomeSettings.backgroundModeOn, forKey: UserDefaultsKeys.background);
        userDefaults.set(metronomeSettings.flipSoundsOn, forKey: UserDefaultsKeys.flipSounds);
        userDefaults.set(metronome.bpm, forKey: UserDefaultsKeys.bpm);
    }
    
    func loadUserDefaults(){
        let userDefaults = UserDefaults.standard;
        metronomeSettings.soundOn = userDefaults.bool(forKey: UserDefaultsKeys.sound);
        metronomeSettings.flashOn = userDefaults.bool(forKey: UserDefaultsKeys.flash);
        metronomeSettings.downbeatSoundOn = userDefaults.bool(forKey: UserDefaultsKeys.downbeat);
        metronomeSettings.backgroundModeOn = userDefaults.bool(forKey: UserDefaultsKeys.background);
        metronomeSettings.flipSoundsOn = userDefaults.bool(forKey: UserDefaultsKeys.flipSounds);
        metronome.bpm = userDefaults.float(forKey: UserDefaultsKeys.bpm);
    }
}

//Text field text constraints
extension MetronomeVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 2;
        if textField == bpmTextField {
            maxLength = 3;
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString

        return newString.length <= maxLength
    }
}

//Keyboard Cancel/Done functionality
extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

