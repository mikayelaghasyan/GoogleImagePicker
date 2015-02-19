//
//  ImagePreviewViewController.swift
//  GoogleImagePicker
//
//  Created by Mikayel Aghasyan on 2/20/15.
//  Copyright (c) 2015 Mikayel Aghasyan. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var widthConstraint: NSLayoutConstraint!
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!

	var imageInfo: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.activityIndicator.startAnimating()

		for (key, value) in imageInfo {
			if key == "imageURL" {
				loadImage(value)
			}
			if key == "imageWidth" {
				widthConstraint.constant = CGFloat((value as NSString).floatValue)
			}
			if key == "imageHeight" {
				heightConstraint.constant = CGFloat((value as NSString).floatValue)
			}
		}
    }

	func loadImage(imageURL: String) {
		var request = NSURLRequest(URL: NSURL(string: imageURL)!)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
			var image = UIImage(data: data)
			self.activityIndicator.stopAnimating()
			self.widthConstraint.constant = image!.size.width
			self.heightConstraint.constant = image!.size.height
			self.imageView.image = image
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
