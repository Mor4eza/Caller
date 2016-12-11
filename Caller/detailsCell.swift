//
//  details.swift
//  Caller
//
//  Created by Morteza Gharedaghi on 8/13/16.
//
//

import UIKit

class detailsCell: UITableViewCell {

    @IBOutlet weak var lblnumber: UILabel!

    @IBOutlet weak var btnCall: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        lblnumber.sizeToFit()
       
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnCallTap(sender: AnyObject) {
        
        let def = NSUserDefaults.standardUserDefaults()
        let prefix = def.stringForKey("defaultPrefix")
        print(prefix)
        
                let tempNumber = lblnumber.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let prefixTemp = prefix!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
                if let phoneNumber = NSURL (string: "tel://\( prefixTemp.joinWithSeparator("") + tempNumber.joinWithSeparator(""))"){
        
                    print(tempNumber.joinWithSeparator("").characters.count)
                    if (tempNumber.joinWithSeparator("").characters.count > 7) {
        
                        UIApplication.sharedApplication().openURL(phoneNumber)
                    }
        
                    print(phoneNumber)
                    
                }
        
    }
    

}
