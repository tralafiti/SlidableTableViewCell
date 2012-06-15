//
//  MGSlidableTableViewCell.m
//  SlidableTableViewCell
//
//  Created by Martin Geiseler on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGSlidableTableViewCell.h"

// Way we have to move on the x-axis to start a slide-event in points.
static const NSInteger kSlideXThreshold = 12;
static const NSInteger kTriggerPadding = 20;

@interface MGSlidableTableViewCell () {
    CGPoint _firstTouchPoint;
    CGPoint _currentTouchPoint;
    BOOL _slideReconized;
}
- (void)parentTableViewScrollEnabled:(BOOL)scrollEnabled;
- (void)slideBack;
- (void)leftTriggerAction;
- (void)rightTriggerAction;
- (BOOL)slideableLeft;
- (BOOL)slideableRight;
@end

@implementation MGSlidableTableViewCell

@synthesize bounceEnabled;
@synthesize delegate = _delegate;
@synthesize leftSlideView = _leftSlideView;
@synthesize rightSlideView = _rightSlideView;
@synthesize leftTriggerView = _leftTriggerView;
@synthesize rightTriggerView = _rightTriggerView;

- (void)setLeftSlideView:(UIView *)leftSlideView
{
    _leftSlideView = leftSlideView;
    if (self.leftTriggerView) [self.contentView insertSubview:leftSlideView belowSubview:self.leftTriggerView];
    else [self.contentView addSubview:leftSlideView];
}

- (void)setRightSlideView:(UIView *)rightSlideView
{
    _rightSlideView = rightSlideView;
    if (self.rightTriggerView) [self.contentView insertSubview:rightSlideView belowSubview:self.rightTriggerView];
    else [self.contentView addSubview:rightSlideView];
}

- (void)setLeftTriggerView:(UIImageView *)leftTriggerView
{
    _leftTriggerView = leftTriggerView;
    if (self.leftSlideView) [self.contentView insertSubview:leftTriggerView aboveSubview:self.leftSlideView];
    else [self.contentView addSubview:leftTriggerView];
}

- (void)setRightTriggerView:(UIImageView *)rightTriggerView
{
    _rightTriggerView = rightTriggerView;
    if (self.rightSlideView) [self.contentView insertSubview:rightTriggerView aboveSubview:self.rightSlideView];
    else [self.contentView addSubview:rightTriggerView];
}

- (void)layoutSubviews
{
    self.rightSlideView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    self.leftSlideView.frame = CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    
    self.leftTriggerView.frame = CGRectMake(-ceil(kTriggerPadding+self.leftTriggerView.frame.size.width), 
                                       ceil(self.frame.size.height/2-self.leftTriggerView.frame.size.height/2), 
                                       self.leftTriggerView.image.size.width,
                                       self.leftTriggerView.image.size.height);
    self.rightTriggerView.frame = CGRectMake(ceil(kTriggerPadding+self.contentView.frame.size.width), 
                                            ceil(self.frame.size.height/2-self.rightTriggerView.frame.size.height/2), 
                                            self.rightTriggerView.image.size.width,
                                            self.rightTriggerView.image.size.height);
    
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        [self.leftSlideView removeFromSuperview];
        [self.leftTriggerView removeFromSuperview];
        [self.rightSlideView removeFromSuperview];
        [self.rightTriggerView removeFromSuperview];
        [super setEditing:editing animated:animated];
    }
    else {
        [super setEditing:editing animated:animated];
        double delayInSeconds = (animated) ? 0.25 : 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.leftSlideView = _leftSlideView;
            self.leftTriggerView = _leftTriggerView;
            self.rightSlideView = _rightSlideView;
            self.rightTriggerView = _rightTriggerView;
        });    
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _firstTouchPoint = [(UITouch *)[touches anyObject] locationInView:self];
    _currentTouchPoint = _firstTouchPoint;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _currentTouchPoint = [(UITouch *)[touches anyObject] locationInView:self];
    CGFloat xMovement = (_firstTouchPoint.x - _currentTouchPoint.x)*-1;
    
    // not in slide-gesture yet
    if (!_slideReconized) {        
        [super touchesBegan:touches withEvent:event];        
        CGFloat yMovement = _firstTouchPoint.y - _currentTouchPoint.y;                
        
        if (xMovement >= kSlideXThreshold  && fabsf(yMovement) < kSlideXThreshold && self.slideableLeft)  _slideReconized = YES;
        if (xMovement <= -kSlideXThreshold && fabsf(yMovement) < kSlideXThreshold && self.slideableRight) _slideReconized = YES;
        
        if (_slideReconized) {    
            [self parentTableViewScrollEnabled:NO];
            [super touchesCancelled:touches withEvent:event];
        }
    }
    
    // we are in a slide. move cell's contentview on x-axis in relation to touches
    if (_slideReconized) {
        if (xMovement <= 0 && !self.slideableRight) xMovement = 0;
        if (xMovement >= 0 && !self.slideableLeft) xMovement = 0;
        
        CGRect f = self.contentView.frame;
        f.origin = CGPointMake(xMovement, f.origin.y);
        self.contentView.frame = f;        
        
        if (xMovement >= (kTriggerPadding*2+self.leftTriggerView.frame.size.width)) {
            self.leftTriggerView.highlighted = YES;
        } else if (self.leftTriggerView.highlighted) {
            self.leftTriggerView.highlighted = NO;
        }
        
        if (xMovement <= -(kTriggerPadding*2+self.rightTriggerView.frame.size.width)) {
            self.rightTriggerView.highlighted = YES;
        } else if (self.rightTriggerView.highlighted) {
            self.rightTriggerView.highlighted = NO;
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self parentTableViewScrollEnabled:YES];  
    if (_slideReconized) {
        [self slideBack];
        if (self.leftTriggerView.highlighted) [self leftTriggerAction];
        if (self.rightTriggerView.highlighted) [self rightTriggerAction];
    }
    
    _currentTouchPoint = [(UITouch *)[touches anyObject] locationInView:self];
    // only forward this event if we arent in slide-mode. if we are we already sent a touchesCancelled
    if (!_slideReconized) [super touchesEnded:touches withEvent:event];
    _slideReconized = NO;    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    // only forward this event if we arent in slide-mode. if we are we already sent a touchesCancelled
    if (!_slideReconized) [super touchesCancelled:touches withEvent:event];
    _slideReconized = NO;
}

- (void)parentTableViewScrollEnabled:(BOOL)scrollEnabled
{
    UITableView *table = (UITableView *)self.superview;
    table.scrollEnabled = scrollEnabled;
}

- (void)slideBack {
    if (!self.bounceEnabled) {        
        CGRect frsAnimation = self.contentView.frame;
        frsAnimation.origin = CGPointMake(0, frsAnimation.origin.y); 
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.contentView.frame = frsAnimation;
            self.rightTriggerView.frame = CGRectMake(320, 19, 22, 22);
        } completion:^(BOOL finished){ 
            self.rightTriggerView.frame = CGRectMake(278, 19, 22, 22);
        }];
    } else {
        // Positiv: Moved to the right, negativ to the left
        CGFloat xMovement = (_firstTouchPoint.x - _currentTouchPoint.x)*-1;
        // Explain Modifier (faktor animation way - longer slide back way = more speed = heavyer bounce)
        CGFloat wayModifier = fabsf(xMovement) / 320;
        CGFloat directionModifier = (xMovement < 0) ? -1 : 1;
        CGRect frsAnimation = self.contentView.frame;
        CGRect sndAnimation = self.contentView.frame;
        CGRect trdAnimation = self.contentView.frame;
        frsAnimation.origin = CGPointMake(ceilf(-20*wayModifier*directionModifier), frsAnimation.origin.y);   
        sndAnimation.origin = CGPointMake(ceilf(8*wayModifier*directionModifier), frsAnimation.origin.y);
        trdAnimation.origin = CGPointMake(0, trdAnimation.origin.y); 
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            self.contentView.frame = frsAnimation;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                self.contentView.frame = sndAnimation;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                    self.contentView.frame = trdAnimation;
                } completion:nil];
            }];
        }];
    }
}

- (void)leftTriggerAction {
    if ([self.delegate respondsToSelector:@selector(slidableTableViewCellDidTriggerLeftAction:)] ) 
        [self.delegate performSelector:@selector(slidableTableViewCellDidTriggerLeftAction:) withObject:self];
}

- (void)rightTriggerAction {
    if ([self.delegate respondsToSelector:@selector(slidableTableViewCellDidTriggerRightAction:)] ) 
        [self.delegate performSelector:@selector(slidableTableViewCellDidTriggerRightAction:) withObject:self];
}

- (BOOL)slideableLeft { return (self.leftSlideView && self.leftTriggerView); }
- (BOOL)slideableRight { return (self.rightSlideView && self.rightTriggerView); }

@end
