//
//  CustomProfileView.swift
//  
//
//  Created by Morteza on 01/06/16.
//
//

import UIKit

class CustomProfileView: UIView {
	
	required internal init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	var isAnimated: Bool = true
	
	var myNameInitials: String = "SA" {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	
	var myFontSize: CGFloat = 50
	var imageUrl: String?
	var imageData: NSData?
	var imageView: UIImageView? {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	func setValueForProfile(animation: Bool, nameInitials: String = "N.A", fontSize: CGFloat = 30.0, imageData: NSData?) {
		isAnimated = animation
		myNameInitials = nameInitials
		myFontSize = fontSize
		self.imageData = imageData
	}

	convenience init(_ roundView: Bool, nameInitials: String, fontSize: CGFloat, imageUrl: String) {
		self.init()
		setValueForProfile(roundView, nameInitials: nameInitials, fontSize: fontSize, imageData:imageData)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	override func drawRect(rect: CGRect) {
			drawOvalWithText(placeHolderText: "\(myNameInitials)", rect: rect, fontSize: myFontSize, shouldAnimated: isAnimated )
	}
	

    func drawOvalWithText(placeHolderText placeHolderText: String = "SA", rect: CGRect, fontSize: CGFloat = 50, shouldAnimated: Bool = true) {
		
		let context = UIGraphicsGetCurrentContext()

		//// Color Declarations
		let color = UIColor.randomNonNearWhiteColor()
		
		//// Oval Drawing
		let ovalRect = rect
		let ovalPath = UIBezierPath(ovalInRect: ovalRect)
		color.setFill()
		ovalPath.fill()
		let ovalStyle = NSMutableParagraphStyle()
		ovalStyle.alignment = .Center
		
		let ovalFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: fontSize)!, NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: ovalStyle]
		
		let ovalTextHeight: CGFloat = NSString(string: placeHolderText).boundingRectWithSize(CGSize(width: ovalRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: ovalFontAttributes, context: nil).size.height
		CGContextSaveGState(context)
		CGContextClipToRect(context, ovalRect)
		NSString(string: placeHolderText).drawInRect(CGRect(x: ovalRect.minX, y: ovalRect.minY + (ovalRect.height - ovalTextHeight) / 2, width: ovalRect.width, height: ovalTextHeight), withAttributes: ovalFontAttributes)
		CGContextRestoreGState(context)
		
		if let imageData = imageData {
			imageView = UIImageView(frame: rect)
			imageView?.layer.cornerRadius = rect.width/2
			imageView?.layer.masksToBounds = true
			imageView?.contentMode = .ScaleAspectFill
			self.addSubview(imageView!)
			imageView?.image = UIImage(data: imageData)
		} else {
			imageView?.removeFromSuperview()
		}

	}

}

extension UIColor {
    static func randomNonNearWhiteColor() -> UIColor {
        //upper bounds is set to 215 to prevent color that is "near" white which result in no differences between initial and bg color
        let red = CGFloat(arc4random_uniform(215)) / 255
        let green = CGFloat(arc4random_uniform(215)) / 255
        let blue = CGFloat(arc4random_uniform(215)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
