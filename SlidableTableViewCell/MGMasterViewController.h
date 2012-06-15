//
//  MGMasterViewController.h
//  SlidableTableViewCell
//
//  Created by Martin Geiseler on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGDetailViewController;

@interface MGMasterViewController : UITableViewController

@property (strong, nonatomic) MGDetailViewController *detailViewController;

@end
