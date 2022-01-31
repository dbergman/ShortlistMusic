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
typealias SLUpdatedShortlistNameSuccess = (_ shortListName: String) -> Void
typealias SLShouldShowYearSelector = (_ showYearSelector: Bool) -> Void

@objc class SLEntryVC: SLBaseVC, UITextFieldDelegate {
    
    var theUser: PFUser?
    var cancelCompletion: SLCreateUserNameCancel?
    var successCompletion: SLCreateUserNameSuccess?
    var successNameCompletion: SLUpdatedShortlistNameSuccess?
    @objc var showPickerView: SLShouldShowYearSelector?
    @objc var existingShortList: SLShortlist?
    @objc var changeYearButton = UIButton()

    lazy var entryTextField:UITextField = {
        let entryTextField = UITextField()
        entryTextField.delegate = self
        entryTextField.translatesAutoresizingMaskIntoConstraints = false
        entryTextField.layer.borderWidth = 1.0
        entryTextField.layer.borderColor = UIColor.sl_Red().cgColor
        entryTextField.backgroundColor = UIColor.white
        entryTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        entryTextField.layer.cornerRadius = 4.0
        entryTextField.returnKeyType = .done
        
        return entryTextField
    }()
    
    @objc init(user:PFUser, onSuccess:@escaping SLCreateUserNameSuccess, onCancel:@escaping SLCreateUserNameCancel) {
        theUser = user
        cancelCompletion = onCancel
        successCompletion = onSuccess
        
        super.init()
    }
    
    @objc init(existingShortList:SLShortlist, onSuccess:@escaping SLUpdatedShortlistNameSuccess, onCancel:@escaping SLCreateUserNameCancel) {
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
        
        view.backgroundColor = UIColor.black
        
        let titleLabel:UILabel = SLLoginVC.getTempLogo(CGRect.zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        
        view.addSubview(entryTextField)
        
        let submitButton:UIButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.sl_Green()
        submitButton.layer.cornerRadius = 4.0
        view.addSubview(submitButton)
        
        if let shortlist = existingShortList {
            changeYearButton.translatesAutoresizingMaskIntoConstraints = false;
            changeYearButton.layer.borderWidth = 1.0
            changeYearButton.layer.cornerRadius = 4.0
            changeYearButton.layer.borderColor = UIColor.sl_Red().cgColor
            changeYearButton.tintColor = UIColor.white
            changeYearButton.contentHorizontalAlignment = .left
            changeYearButton.addTarget(self, action: #selector(showShortlistYearSelector), for: .touchUpInside)
            
            if let year = existingShortList?.shortListYear  {
                changeYearButton.setTitle("Year: \(year)", for: .normal)
            }
            else {
                changeYearButton.setTitle("Year:", for: .normal)
            }

            view.addSubview(changeYearButton)
            
            let arrowImageView = UIImageView(image: UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate))
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            arrowImageView.tintColor = UIColor.white

            changeYearButton.addSubview(arrowImageView)

            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[arrowImageView]-|", options:[], metrics:nil, views:["arrowImageView":arrowImageView]))
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[arrowImageView]-|", options:[], metrics:nil, views:["arrowImageView":arrowImageView]))
            
            entryTextField.text = shortlist.shortListName
            entryTextField.placeholder = NSLocalizedString("Enter new Shortlist name", comment: "")
            submitButton.setTitle(NSLocalizedString("Save", comment: ""), for:.normal)
            submitButton.addTarget(self, action: #selector(SLEntryVC.updateShortlistName), for: .touchUpInside)
        }
        else {
            entryTextField.placeholder = NSLocalizedString("Enter a Username", comment: "")
            submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for:.normal)
            submitButton.addTarget(self, action: #selector(SLEntryVC.addUserToShortList), for: .touchUpInside)
        }
        
        let cancelButton:UIButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        cancelButton.backgroundColor = UIColor.sl_Red()
        cancelButton.layer.cornerRadius = 4.0
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for:.normal)
        cancelButton.addTarget(self, action: #selector(SLEntryVC.cancelLogin), for: .touchUpInside)
        view.addSubview(cancelButton)
    
        var views = ["titleLabel":titleLabel, "entryTextField":entryTextField, "submitButton":submitButton, "cancelButton":cancelButton] as [String : UIView]
        
        if existingShortList != nil {
            views["yearButton"] = changeYearButton
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[entryTextField]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[yearButton]-|", options:[], metrics:nil, views:views))
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cancelButton]-[submitButton(cancelButton)]-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel][entryTextField(30)]-[yearButton]-[submitButton]-10-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelButton]-10-|", options:[], metrics:nil, views:views))
        }
        else {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[entryTextField]-15-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[submitButton]-15-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cancelButton]-15-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[titleLabel]-30-[entryTextField(30)]-20-[submitButton]-10-[cancelButton]", options:[], metrics:nil, views:views))
        }
    }
    
    @objc func cancelLogin() {
        entryTextField.resignFirstResponder()
        cancelCompletion?()
        showPickerView?(false)
    }
    
    @objc func addUserToShortList() {
        if let entryText = entryTextField.text, entryText.count > 5 {
            SLParseController.doesUserNameExist(username: entryTextField.text!, checkAction:{[unowned self](exists) in
                if (exists) {
                    self.sl_showToast(forAction: NSLocalizedString("Invalid Username", comment: ""), message: NSLocalizedString("Username must be at least 6 characters long.", comment: ""), toastType: SLToastMessageType.failure, completion: {})
                }
                else  {
                    self.theUser?.username = self.entryTextField.text
                    
                    self.theUser?.saveInBackground(block: { _, _ in
                        self.successCompletion?()
                    })
                }
            })
        }
    }
    
     @objc func updateShortlistName () {
        if let shortlist = existingShortList {
            shortlist.shortListName = entryTextField.text
            entryTextField.resignFirstResponder()
            SLParseController.saveShortlist(newShortList: shortlist, completion: { [unowned self] in
                self.successNameCompletion?(shortlist.shortListName)
                self.showPickerView?(false)
            })
        }
    }
    
    @objc func showShortlistYearSelector() {
       showPickerView?(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        if text.isEmpty {
            let firstChar = Int(string)
            if firstChar != nil {
               return false
            }
        }
        else if string == " " && (existingShortList) == nil {
            return false
        }
        
        let newLength = text.count + string.count - range.length
        
        return newLength <= 30
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
