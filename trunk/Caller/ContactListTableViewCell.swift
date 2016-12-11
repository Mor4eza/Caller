//
//  ContactListTableViewCell.swift
//
//
//  Created by Morteza on 10/06/16.
//
//

import UIKit
import AVFoundation

protocol  ContactListTableViewCellProtocol {
	func onRecordStart(activeRecorder : AVAudioRecorder?)
	func onRecordStop(activeRecorder : AVAudioRecorder?)
	func onPlayStart(activeRecorder : AVAudioRecorder?)
	func onPlayStop(activeRecorder : AVAudioRecorder?)
}

class ContactListTableViewCell: UITableViewCell {
	
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var btnPlay: UIButton!
	@IBOutlet var IBViewProfilePic: CustomProfileView!
    
	@IBOutlet var IBlblPhoneNumber: UILabel!
	@IBOutlet var IBlblName: UILabel!
	
	var contactListTableViewCellDelegate : ContactListTableViewCellProtocol?
	var audioPlayer : AVAudioPlayer?
	var audioRecorder : AVAudioRecorder?
	
	override func awakeFromNib() {
        
        btnRecord.hidden = true
        btnPlay.hidden = true
        IBViewProfilePic.imageView?.image = nil
        IBViewProfilePic.imageData = nil
		IBlblPhoneNumber.text = ""
	}
	
	//MARK:- IBActions -
	
	@IBAction func IBbtnRecordTap(sender: UIButton) {
		sender.selected = !sender.selected
		sender.selected ? startRecording() : stopRecording()
	}
	
	@IBAction func IBbtnPlayTap(sender: UIButton) {
		sender.selected = !sender.selected
		sender.selected ? startPlaying() : stopPlaying()
		
	}
	
	//MARK:- Custom methods -
	
	func stopPlaying() {
		contactListTableViewCellDelegate?.onPlayStop(audioRecorder)
	}
	
	func startPlaying() {
		contactListTableViewCellDelegate?.onPlayStart(audioRecorder)
	}

	func startRecording() {
		contactListTableViewCellDelegate?.onRecordStart(audioRecorder)
	}
	
	func stopRecording() {
		contactListTableViewCellDelegate?.onRecordStop(audioRecorder)
	}
	
	
}
