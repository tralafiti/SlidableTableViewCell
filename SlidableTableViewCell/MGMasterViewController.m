//
//  MGMasterViewController.m
//  SlidableTableViewCell
//
//  Created by Martin Geiseler on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGMasterViewController.h"
#import "MGSlidableTableViewCell.h"

@interface MGMasterViewController () {
    NSArray *_objects;
}
@end

@implementation MGMasterViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Demo";
        _objects = [NSArray arrayWithObjects:@"left wuff right", @"wuff left wuff", @"right wuff wuff", nil];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"bounce" style:UIBarButtonItemStylePlain target:self action:@selector(toogleBounce)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toogleEdit)];
    }
    return self;
}

- (void)toogleBounce
{
    MGSlidableTableViewCell* cell;
    for(cell in self.tableView.visibleCells) {
        cell.bounceEnabled = !cell.bounceEnabled;
    }
    
    self.navigationItem.leftBarButtonItem.title = (((MGSlidableTableViewCell*)[self.tableView.visibleCells lastObject]).bounceEnabled) ? @"no bounce" : @"bounce";
}

- (void)toogleEdit
{
    [self setEditing:!self.editing animated:YES];   
    self.navigationItem.rightBarButtonItem.title = (self.editing) ? @"Done" : @"Edit";
}
							
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MGSlidableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MGSlidableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor whiteColor];        
        cell.delegate = self;
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            UIImage* leftShadow = [UIImage imageNamed:@"shadow-left.png"];
            cell.leftSlideView = [[UIImageView alloc] initWithImage:[leftShadow resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)]];
            cell.leftTriggerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-empty.png"] highlightedImage:[UIImage imageNamed:@"check-full.png"]];
        }
        
        if (indexPath.row == 0 || indexPath.row == 2) {
            UIImage* rightShadow = [UIImage imageNamed:@"shadow-right.png"];
            cell.rightSlideView = [[UIImageView alloc] initWithImage:[rightShadow resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)]];        
            cell.rightTriggerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-empty.png"] highlightedImage:[UIImage imageNamed:@"check-full.png"]];
        }        
    }

    NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object description];
    cell.imageView.image = [UIImage imageNamed:@"random-dog.jpg"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

# pragma - MGSlidableTableViewCellDelegate Methods

- (void)slidableTableViewCellDidTriggerLeftAction:(MGSlidableTableViewCell *)cell
{
    [[[UIAlertView alloc] initWithTitle:@"Trigger" message:@"left action triggered" delegate:nil cancelButtonTitle:@"thanks" otherButtonTitles:nil] show];
}

- (void)slidableTableViewCellDidTriggerRightAction:(MGSlidableTableViewCell *)cell
{
    [[[UIAlertView alloc] initWithTitle:@"Trigger" message:@"right action triggered" delegate:nil cancelButtonTitle:@"thanks" otherButtonTitles:nil] show];
}


@end
