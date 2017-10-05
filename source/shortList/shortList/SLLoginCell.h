//
//  SLLoginCell.h
//  shortList
//
//  Created by Dustin Bergman on 9/6/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SLLoginButtonCellAction)(void);

@interface SLLoginCell : UITableViewCell

- (void)configLoginButton:(BOOL)isloggedIn loginButtonAction:(SLLoginButtonCellAction)loginAction;
- (void)updateButtonWithLoginStatus:(BOOL)isloggedIn;

@end
