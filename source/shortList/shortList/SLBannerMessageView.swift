//
//  SLBannerMessageView.swift
//  shortList
//
//  Created by Dustin Bergman on 6/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

import UIKit

public enum SLBannerType {
    case SLBannerTypeSuccess, SLBannerTypeFailue
    
    func backgroundColor() -> UIColor {
        switch self {
        case SLBannerTypeSuccess:
            return UIColor.greenColor()
        case SLBannerTypeFailue:
            return UIColor.redColor()
        }
    }
}

public class SLBannerMessageView: UIView {
    
    public static func showSuccessMessage(message: String? = nil) -> SLBannerMessageView {
        return SLBannerMessageView.showMessage(message: message, type: .SLBannerTypeSuccess)
    }
    
    class func showErrorMessage(message: String? = nil) -> SLBannerMessageView {
        return SLBannerMessageView.showMessage(message: message, type: .SLBannerTypeFailue)
    }
    
    public static func showMessage(message: String? = nil, type:SLBannerType) -> SLBannerMessageView {
        let messageView = SLBannerMessageView(message:message, frame:CGRectZero, type:type)
        
        return messageView;
    }
    
    var msglabel: UILabel!
    var bannerType: SLBannerType?
    
    public init(title: String? = nil, message: String? = nil, frame: CGRect, type:SLBannerType) {
        super.init(frame: frame)
        self.backgroundColor = type.backgroundColor()

        msglabel = UILabel.new()
        msglabel.numberOfLines = 0;
        msglabel.textAlignment = NSTextAlignment.Center
        msglabel.text = message
        msglabel.sizeToFit()
        self.addSubview(msglabel)
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func
}
