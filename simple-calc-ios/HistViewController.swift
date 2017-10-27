//
//  HistViewController.swift
//  simple-calc-ios
//
//  Created by ​ on 10/26/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

class HistViewController: UIViewController {
    var hist : [String] = []

//    func makeHistory() {
//        hist.numberOfLines = 0
//        histLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        histLabel.sizeToFit()
//        histLabel.backgroundColor = UIColor.orange
//        histLabel.textColor = UIColor.white
//        histLabel.numberOfLines = 0
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.white
        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        scrollView.contentSize = CGSize(width: 375, height: 1500)
        view.addSubview(scrollView)
        var index = 0
        for ele in hist {
            let label = UILabel(frame: CGRect(x: 0, y: index * 20, width: 300, height: 40))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.byTruncatingHead
            label.text = ele
            label.font = label.font.withSize(20)
            scrollView.addSubview(label)
            index += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mainView = segue.destination as! ViewController
        mainView.hist = self.hist
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
