//
//  SLEnterUserNameVC.swift
//  shortList
//
//  Created by Dustin Bergman on 10/28/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit

class SLEnterUserNameVC: SLBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let titleLabel:UILabel = SLLoginVC.getTempLogo(CGRectZero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(titleLabel)
        
        let userNameTextField:UITextField = UITextField()
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.placeholder = NSLocalizedString("Enter a Username", comment: "")
        userNameTextField.layer.borderWidth = 1.0
        userNameTextField.layer.borderColor = UIColor.sl_Red().CGColor
        userNameTextField.backgroundColor = UIColor.whiteColor()
        userNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        userNameTextField.layer.cornerRadius = 4.0
        self.view.addSubview(userNameTextField)
        
        let submitButton:UIButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.greenColor()
        submitButton.layer.cornerRadius = 4.0
        submitButton.setTitle(NSLocalizedString("Submit", comment: ""), forState:.Normal)
        self.view.addSubview(submitButton)
    
        let views = ["titleLabel":titleLabel, "userNameTextField":userNameTextField, "submitButton":submitButton]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[userNameTextField]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[submitButton]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(130)-[titleLabel]-(30)-[userNameTextField(30)]-20-[submitButton]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))

    }

}
