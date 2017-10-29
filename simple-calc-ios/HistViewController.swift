//
//  HistViewController.swift
//  simple-calc-ios
//
//  Created by ​ on 10/26/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

class UILabelPadding: UILabel {
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}

class HistViewController: UIViewController {
    var hist : [String] = []
        override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = UIScrollView(), contentView = UIView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UITableView().separatorColor
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        self.view.addConstraints([
            NSLayoutConstraint(item: scrollView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: self.view,
                               attribute: .width,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: scrollView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.view,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: 0.0)])
        
        scrollView.addConstraints([
            NSLayoutConstraint(item: contentView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: contentView,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .width,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: contentView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: contentView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: scrollView,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: 0.0)])
        
        var previousViewElement:UIView!
        
        for ele in hist {
            let view = UILabelPadding()
            view.text = ele
            view.textColor = self.view.tintColor
            view.font = view.font.withSize(30)
            view.numberOfLines = 0
            view.lineBreakMode = .byCharWrapping
            view.backgroundColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            contentView.addConstraints([
                NSLayoutConstraint(item: view,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: contentView,
                                   attribute: .centerX,
                                   multiplier: 1.0,
                                   constant: 0.0),
                NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: contentView,
                                   attribute: .width,
                                   multiplier: 1.0,
                                   constant: 0.0)])
            
            if previousViewElement == nil {
                contentView.addConstraint(
                    NSLayoutConstraint(item: view,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: contentView,
                                       attribute: .top,
                                       multiplier: 1.0,
                                       constant: 1.5))
            } else {
                contentView.addConstraint(
                    NSLayoutConstraint(item: view,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: previousViewElement,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: 1.5))
            }
            
            previousViewElement = view
        }
    
        if (hist.count > 0) {
            contentView.addConstraint(
                NSLayoutConstraint(item: previousViewElement,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: contentView,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: 0.0))
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
}
