//
//  MGSlidableTableViewCell.h
//  SlidableTableViewCell
//
//  Created by Martin Geiseler on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSlidableTableViewCellDelegate.h"

@interface MGSlidableTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MGSlidableTableViewCellDelegate> delegate;

@property (nonatomic, getter=isBounceEnabled) BOOL bounceEnabled;

@property (nonatomic, strong) UIView* leftSlideView;
@property (nonatomic, strong) UIView* rightSlideView;
@property (nonatomic, strong) UIImageView* leftTriggerView;
@property (nonatomic, strong) UIImageView* rightTriggerView;

@end
