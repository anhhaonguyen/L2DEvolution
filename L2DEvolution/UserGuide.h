//
//  UserGuide.h
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/14/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WYPopoverController.h"

#define kUserGuideSelectCity    @"Select one city"
#define kUserGuideShowTips      @"Show tips"
#define kUserGuideReconnect     @"If it's not connected. Tap here to reconnect"
#define kUserGuideCircle        @"Run circle sculpture"
#define kUserGuideOval          @"Run oval sculpture"
#define kUserGuideSquare        @"Run square sculture"


#define kUserGuideTurnLeft      @"Press to turn left"
#define kUserGuideTurnRight     @"Press to turn right"
#define kUserGuide1             @"1"
#define kUserGuide2             @"2"
#define kUserGuide3             @"3"
#define kUserGuide4             @"4"
#define kUserGuide5             @"5"
#define kUserGuide6             @"6"
#define kUserGuide7             @"7"
#define kUserGuide8             @"8"

@interface UserGuideObject : NSObject

@property (retain) NSString* textContent;
@property (retain) UIBarButtonItem* barButtonItem;// if item is nil, check fromRect
@property CGRect fromRect;
@property (retain) UIViewController* presentingViewController;
@property (retain) UIView* fromView;

@end

@interface UserGuide : NSObject <UIPopoverControllerDelegate, WYPopoverControllerDelegate> {
    WYPopoverController* phonePopover;
    UIPopoverController* popover;
    NSMutableArray* guideQueue;
}

@property (retain) NSString* textContent;
@property (retain) UIBarButtonItem* barButtonItem;// if item is nil, check fromRect
@property CGRect fromRect;
@property (retain) UIViewController* presentingViewController;
@property (retain) UIView* fromView;

+ (instancetype)sharedInstance;

- (void)addGuide:(UserGuideObject*)guide;
- (void) addSimpleUserGuideWithText:(NSString*)text atView:(UIView*)view fromRect:(CGRect)fromRect fromViewController:(UIViewController*)viewController;
- (BOOL) checkUserGuideIsValidToAdd:(NSString*) guide;
- (void)resetUserGuide;
- (BOOL)isPlaying;

@end
