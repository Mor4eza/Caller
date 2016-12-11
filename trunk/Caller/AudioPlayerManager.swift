//
//  AudioPlayerManager.swift
//  Demo_ContactManager
//
//  Created by Morteza on 16/06/16.
//
//

import UIKit
import AVFoundation

class AudioPlayerManager: NSObject {

	static let audioPlayerSharedManager = AudioPlayerManager()
	
	var audioPlayer : AVAudioPlayer!
	
	func playContent(urlToPlay : NSURL) {
		
		audioPlayer?.stop() //stop previous url if any
		
		do {
			try audioPlayer = AVAudioPlayer(contentsOfURL: urlToPlay)
			audioPlayer?.play()
		} catch {
			}
	}
	
	
	func stopContent(urlToStop : NSURL) {
		do {
			try audioPlayer = AVAudioPlayer(contentsOfURL: urlToStop)
			audioPlayer?.stop()
		} catch {
		}
	}
}
