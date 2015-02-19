//
//  GoogleWebViewController.swift
//  GoogleImagePicker
//
//  Created by Mikayel Aghasyan on 2/18/15.
//  Copyright (c) 2015 Mikayel Aghasyan. All rights reserved.
//

import UIKit

class GoogleWebViewController: UIViewController, UISearchBarDelegate, UIWebViewDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var webView: UIWebView!

	var progressTimer: NSTimer!
	var searchTerm: NSString = ""

	override func viewDidLoad() {
        super.viewDidLoad()
    }

	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		if (!searchTerm.isEqualToString(searchBar.text)) {
			searchTerm = searchBar.text
			loadGoogleSearch()
			searchBar.resignFirstResponder()
		}
	}

	func loadGoogleSearch() {
		var req = NSURLRequest(URL: NSURL(string: NSString(format: "https://www.google.com/search?safe=active&tbm=isch&q=%@", searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!))!)
		webView.loadRequest(req)
	}

	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		var href = request.URL.absoluteString
		if (href!.hasPrefix("gip:initialized")) {
			self.webView.hidden = false
			return false
		} else if (href!.hasPrefix("gip:")) {
			var comps = href?.componentsSeparatedByString(":")
			var imageInfo = [String: String]()
			if (comps!.count > 1) {
				imageInfo["imageURL"] = comps![1].stringByRemovingPercentEncoding
			}
			if (comps!.count > 2) {
				imageInfo["imageWidth"] = comps![2]
			}
			if (comps!.count > 3) {
				imageInfo["imageHeight"] = comps![3]
			}
			NSLog("Image info: %@", imageInfo)
			openImage(imageInfo)
			return false
		} else {
			return true
		}
	}

	func openImage(imageInfo: [String: String]) {
		performSegueWithIdentifier("ShowImagePreview", sender: imageInfo)
	}

	func webViewDidStartLoad(webView: UIWebView) {
		progressView.progress = 0.0
		progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 60.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
		webView.hidden = true
	}

	func webViewDidFinishLoad(webView: UIWebView) {
		progressTimer.invalidate()
		progressView.progress = 1.0

		applyJavaScript()

//		webView.hidden = false
	}

	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		webView.loadHTMLString("<h1>Something went wrong!</h1>", baseURL: nil)
	}

	func updateProgress() {
		progressView.progress += (1.0 - progressView.progress) * 0.01
	}

	func applyJavaScript() {
		var jsFilePath = NSBundle.mainBundle().pathForResource("google", ofType: "js", inDirectory: "")
		var js = NSString(contentsOfFile: jsFilePath!, encoding: NSUTF8StringEncoding, error: nil)
		var html = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML");
//		NSLog("%@", html!);
		webView.stringByEvaluatingJavaScriptFromString(js!)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		segue.destinationViewController.setValue(sender, forKey: "imageInfo")
	}
}
