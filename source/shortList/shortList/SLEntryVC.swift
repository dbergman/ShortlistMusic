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
typealias SLUpdatedShortlistNameSuccess = (shortListName:String) -> Void

class SLEntryVC: SLBaseVC, UITextFieldDelegate {
    
    var theUser: PFUser?
    var cancelCompletion: SLCreateUserNameCancel?
    var successCompletion: SLCreateUserNameSuccess?
    var successNameCompletion: SLUpdatedShortlistNameSuccess?
    var existingShortList: SLShortlist?

    lazy var entryTextField:UITextField = {
        let entryTextField = UITextField()
        entryTextField.delegate = self
        entryTextField.translatesAutoresizingMaskIntoConstraints = false
        entryTextField.layer.borderWidth = 1.0
        entryTextField.layer.borderColor = UIColor.sl_Red().CGColor
        entryTextField.backgroundColor = UIColor.whiteColor()
        entryTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        entryTextField.layer.cornerRadius = 4.0
        
        return entryTextField
    }()
    
    init(user:PFUser, onSuccess:SLCreateUserNameSuccess, onCancel:SLCreateUserNameCancel) {
        theUser = user
        cancelCompletion = onCancel
        successCompletion = onSuccess
        
        super.init()
    }
    
    init(existingShortList:SLShortlist, onSuccess:SLUpdatedShortlistNameSuccess, onCancel:SLCreateUserNameCancel) {
        self.existingShortList = existingShortList
        cancelCompletion = onCancel
        successNameCompletion = onSuccess
        
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }
    
    init(_ coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)!
        }
        else {
            super.init(nibName: nil, bundle:nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blackColor()
        
        let titleLabel:UILabel = SLLoginVC.getTempLogo(CGRectZero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        
        view.addSubview(entryTextField)
        
        let submitButton:UIButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.sl_Green()
        submitButton.layer.cornerRadius = 4.0
        view.addSubview(submitButton)
        
        if let shortlist = existingShortList {
            entryTextField.text = shortlist.shortListName
            entryTextField.placeholder = NSLocalizedString("Enter new Shortlist name", comment: "")
            submitButton.setTitle(NSLocalizedString("Save", comment: ""), forState:.Normal)
            submitButton.addTarget(self, action: "updateShortlistName", forControlEvents: .TouchUpInside)
        }
        else {
            entryTextField.placeholder = NSLocalizedString("Enter a Username", comment: "")
            submitButton.setTitle(NSLocalizedString("Submit", comment: ""), forState:.Normal)
            submitButton.addTarget(self, action: "addUserToShortList", forControlEvents: .TouchUpInside)
        }
        
        let cancelButton:UIButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        cancelButton.backgroundColor = UIColor.sl_Red()
        cancelButton.layer.cornerRadius = 4.0
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState:.Normal)
        cancelButton.addTarget(self, action: "cancelLogin", forControlEvents: .TouchUpInside)
        view.addSubview(cancelButton)
    
        let views = ["titleLabel":titleLabel, "entryTextField":entryTextField, "submitButton":submitButton, "cancelButton":cancelButton]
        
        if ((existingShortList) != nil) {
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[entryTextField]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[cancelButton]-[submitButton(cancelButton)]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-(15)-[entryTextField(30)]-20-[submitButton]-20-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[cancelButton]-20-|", options:[], metrics:nil, views:views))
        }
        else {
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[entryTextField]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[submitButton]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[cancelButton]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[titleLabel]-(30)-[entryTextField(30)]-20-[submitButton]-10-[cancelButton]", options:[], metrics:nil, views:views))
        }
    }
    
    func cancelLogin() {
        entryTextField.resignFirstResponder()
        cancelCompletion?()
    }
    
    func addUserToShortList () {
        if entryTextField.text?.characters.count > 5 {
            SLParseController.doesUserNameExist(entryTextField.text!, checkAction:{[unowned self](Bool exists) in
                if (exists) {
                    self.sl_showToastForAction(NSLocalizedString("Invalid Username", comment: ""), message: NSLocalizedString("Username must be at least 6 characters long.", comment: ""), toastType: SLToastMessageType.Failure, completion: {})
                }
                else  {
                    self.theUser?.username = self.entryTextField.text
                    self.theUser?.saveInBackgroundWithBlock({(Bool success) in
                    self.successCompletion?()
                    })
                }
            })
        }
    }
    
     func updateShortlistName () {
        if let shortlist = existingShortList {
            shortlist.shortListName = entryTextField.text
            SLParseController.saveShortlist(shortlist, completion: { [unowned self] in
                self.successNameCompletion?(shortListName: shortlist.shortListName)
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
        
        return newLength <= 30
    }

}
