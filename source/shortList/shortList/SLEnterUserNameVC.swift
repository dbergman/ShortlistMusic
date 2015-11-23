//
//  SLEnterUserNameVC.swift
//  shortList
//
//  Created by Dustin Bergman on 10/28/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit

typealias SLCreateUserNameCancel = () -> Void
typealias SLCreateUserNameSuccess = () -> Void

class SLEnterUserNameVC: SLBaseVC, UITextFieldDelegate {
    
    var theUser:PFUser?
    var cancelCompletion:SLCreateUserNameCancel?
    var successCompletion:SLCreateUserNameSuccess?

    lazy var userNameTextField:UITextField = {
        let userNameTextField = UITextField()
        userNameTextField.delegate = self
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.placeholder = NSLocalizedString("Enter a Username", comment: "")
        userNameTextField.layer.borderWidth = 1.0
        userNameTextField.layer.borderColor = UIColor.sl_Red().CGColor
        userNameTextField.backgroundColor = UIColor.whiteColor()
        userNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        userNameTextField.layer.cornerRadius = 4.0
        
        return userNameTextField
    }()
    
    init(user:PFUser, onSuccess:SLCreateUserNameSuccess, onCancel:SLCreateUserNameCancel) {
        self.theUser = user
        self.cancelCompletion = onCancel
        self.successCompletion = onSuccess
        
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }
    
    init(_ coder: NSCoder? = nil) {
        self.theUser = PFUser()
        
        if let coder = coder {
            super.init(coder: coder)!
        }
        else {
            super.init(nibName: nil, bundle:nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let titleLabel:UILabel = SLLoginVC.getTempLogo(CGRectZero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(titleLabel)
        
        self.view.addSubview(userNameTextField)
        
        let submitButton:UIButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.sl_Green()
        submitButton.layer.cornerRadius = 4.0
        submitButton.setTitle(NSLocalizedString("Submit", comment: ""), forState:.Normal)
        submitButton.addTarget(self, action: "addUserToShortList", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
        
        let cancelButton:UIButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        cancelButton.backgroundColor = UIColor.sl_Red()
        cancelButton.layer.cornerRadius = 4.0
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState:.Normal)
        cancelButton.addTarget(self, action: "cancelLogin", forControlEvents: .TouchUpInside)
        self.view.addSubview(cancelButton)
    
        let views = ["titleLabel":titleLabel, "userNameTextField":self.userNameTextField, "submitButton":submitButton, "cancelButton":cancelButton]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[userNameTextField]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[submitButton]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[cancelButton]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(130)-[titleLabel]-(30)-[userNameTextField(30)]-20-[submitButton]-10-[cancelButton]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))

    }
    
    func cancelLogin() {
        self.cancelCompletion!()
    }
    
    func addUserToShortList () {
        if self.userNameTextField.text?.characters.count > 5 {
            SLParseController.doesUserNameExist(self.userNameTextField.text!, checkAction:{[weak self](Bool exists) in
                if (exists) {
                    self!.sl_showToastForAction(NSLocalizedString("Invalid Username", comment: ""), message: NSLocalizedString("Username must be at least 6 characters long.", comment: ""), toastType: SLToastMessageType.Failure, completion: {})
                }
                else  {
                    self?.theUser?.username = self!.userNameTextField.text
                    self?.theUser?.saveInBackgroundWithBlock({(Bool success) in
                        self?.successCompletion!()
                    })
                }
            })
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        if text.characters.count == 0  {
            let firstChar = Int(string)
            if firstChar != nil {
               return false
            }
        }
        else if string == " " {
            return false
        }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= 20
    }

}
