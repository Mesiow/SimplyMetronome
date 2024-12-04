//
//  Torch.swift
//  SimplyMetronome
//
//  Created by Mesiow on 3/9/23.
//

import Foundation
import AVFoundation

struct Torch {
   static func toggle(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return;
        }
        
        if device.hasTorch {
            do {
                //before attempting to configure device, lock it
                try device.lockForConfiguration();
                
                if on {
                    device.torchMode = .on;
                }else {
                    device.torchMode = .off;
                }
                
                device.unlockForConfiguration();
            }catch {
                print("Torch could not be used")
            }
        }else{
            print("Torch is not available");
        }
    }
}
