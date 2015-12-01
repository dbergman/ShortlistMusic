//
//  SLContactMeCell.h
//  shortList
//
//  Created by Dustin Bergman on 11/24/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SLButtonActionBlock)();

@interface SLGenericOneButtonCell : UITableViewCell

@property (nonatomic, copy) SLButtonActionBlock buttonAction;
@property (nonatomic, strong) UIButton *oneButton;

@end
