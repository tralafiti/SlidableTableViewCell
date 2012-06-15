//
//  MGSlideableTableViewCellDelegate.h
//  SlidableTableViewCell
//
//  Created by Martin Geiseler on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MGSlidableTableViewCell;

@protocol MGSlidableTableViewCellDelegate <NSObject>

@optional
- (void)slidableTableViewCellDidTriggerLeftAction:(MGSlidableTableViewCell *)cell;
- (void)slidableTableViewCellDidTriggerRightAction:(MGSlidableTableViewCell *)cell;

@end
