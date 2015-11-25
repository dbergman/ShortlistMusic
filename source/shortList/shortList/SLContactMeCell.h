//
//  SLContactMeCell.h
//  shortList
//
//  Created by Dustin Bergman on 11/24/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SLContactMeBlock)();

@interface SLContactMeCell : UITableViewCell
@property (nonatomic, copy) SLContactMeBlock contactMeBlockAction;
@end
