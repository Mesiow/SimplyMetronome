//
//  Metronome.swift
//  SimplyMetronome
//
//  Created by Mesiow on 3/6/23.
//

import Foundation
import UIKit
import AVFoundation

class Metronome {
    var beatflip : Bool = false;
    var downbeat : Bool = true;
    var count: Int = 0;
    var timer: Timer!
    var tsLower : Int = 4;
    var tsUpper : Int = 4;
    var bpm: Float = 90.0 { didSet {
        bpm = min(200.0,max(1,bpm))
    }}
    var enabled: Bool = false { didSet {
        if enabled {
            start()
        } else {
            stop()
        }
    }}
    var onTick: (() -> Void)?
    
    var mainPlayer : AVAudioPlayer!
    var downbeatPlayer : AVAudioPlayer!
    
    func setup(){
        do {
            guard let mainURL = Bundle.main.url(forResource: "sound1", withExtension: "wav") else { fatalError("sound1 URL could not be found")}
            guard let secondURL = Bundle.main.url(forResource: "sound2", withExtension: "wav") else { fatalError("sound2 URL could not be found")}
            
        
            mainPlayer = try AVAudioPlayer(contentsOf: mainURL);
            downbeatPlayer = try AVAudioPlayer(contentsOf: secondURL);
            
            mainPlayer.prepareToPlay();
            downbeatPlayer.prepareToPlay();

        } catch {
            print("Oops, unable to initialize metronome audio buffer: \(error)")
        }
    }

    func setVolume(vol: Float){
        mainPlayer.volume = vol;
        downbeatPlayer.volume = vol;
    }

    private func start() {
        print("Starting metronome, BPM: \(bpm)")
        let metronomeTimeInterval : TimeInterval = (240.0 / Double(tsLower)) / Double(bpm);
        
        timer = Timer.scheduledTimer(timeInterval: metronomeTimeInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
        
        timer?.fire();
    }

    private func stop() {
        timer?.invalidate();
        count = 0;
        print("Stopping metronome")
    }
    
    func restart(){
        enabled = false;
        enabled = true;
    }

    @objc private func tick() {
        count += 1;
        if downbeat && count == 1{
            //accent play
            if beatflip {
                mainPlayer.play();
            }else{
                downbeatPlayer.play();
            }
        }else{
            if beatflip {
                downbeatPlayer.play();
            }else{
                mainPlayer.play();
            }
            if count == tsUpper {
                count = 0;
            }
        }
        onTick?()
    }
}
