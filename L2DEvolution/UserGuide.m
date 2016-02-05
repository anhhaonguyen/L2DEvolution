//
//  UserGuide.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/14/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "Config.h"
#import "UserGuideViewController.h"
#import "UserGuide.h"

@implementation UserGuideObject

- (void)dealloc
{
    self.presentingViewController = nil;
    self.textContent = nil;
    self.barButtonItem = nil;
    self.fromView = nil;
}

@end

@implementation UserGuide
static UserGuide* _sharedInstance = nil;

+ (instancetype)sharedInstance
{
    if (_sharedInstance==nil) {
        _sharedInstance = [UserGuide new];
    }
    return _sharedInstance;
}

- (void)addGuide:(UserGuideObject*)guide
{
    if (guideQueue == nil) {
        guideQueue = [NSMutableArray new];
    }
    [guideQueue addObject:guide];
    
    if (isPhone) {
        if (phonePopover==nil || ![phonePopover isPopoverVisible]) {
            [self showGuide:guide];
        }
    } else {
        if (phonePopover == nil || ![phonePopover isPopoverVisible]) {// If nothing is showing, show it now
            [self showGuide:guide];
        }
    }
}

- (void)addSimpleUserGuideWithText:(NSString *)text atView:(UIView *)view fromRect:(CGRect)fromRect fromViewController:(UIViewController *)viewController
{
    if (![self shouldAddContent:text]) {
        return;
    }
    if (view == nil) {
        return;
    }
    if (viewController == nil) {
        return;
    }
    // Need ensure this view controller is available on Screens
    if (!viewController.isViewLoaded || !viewController.view.window) {
        return;
    }
    
    UserGuideObject* guide = [UserGuideObject new];
    guide.textContent = text;
    guide.presentingViewController = viewController;
    guide.fromRect = fromRect;
    guide.fromView = view;
    [self addGuide:guide];
}

- (BOOL) shouldAddContent:(NSString*) textContent {
    return [self shouldAddUserGuideType:textContent];
}

- (BOOL) shouldAddUserGuideType:(NSString*) type {
    NSString* key = type;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue] == YES) {
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
    return NO;
    //    return YES;
}

- (void)showGuide:(UserGuideObject*)guide
{
    if (isPhone) {
        [self showGuideForPhone:guide];
        return;
    }
    
    if (popover!=nil) {
        if (popover.isPopoverVisible) {
            [popover dismissPopoverAnimated:YES];
        }
    }
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UserGuideViewController* userGuideVC = [sb instantiateViewControllerWithIdentifier:@"UserGuideViewController"];
    userGuideVC.textContent = guide.textContent;
    userGuideVC.preferredContentSize = CGSizeMake(180, 64);
    
    popover = [[UIPopoverController alloc] initWithContentViewController:userGuideVC];
    popover.passthroughViews = @[];
    popover.delegate = self;
    NSLog(@"%@", NSStringFromCGRect(guide.fromRect));
    if ([guide.textContent isEqualToString:kUserGuideSelectCity]) {
        [popover presentPopoverFromRect:guide.presentingViewController.view.frame inView:guide.fromView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [popover presentPopoverFromRect:guide.fromRect inView:guide.fromView permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    }
    
    
    [guideQueue removeObject:guide];
}

- (void)showGuideForPhone:(UserGuideObject*)guide
{
    if (phonePopover!=nil) {
        if (phonePopover.isPopoverVisible) {
            [phonePopover dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
        }
    }
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UserGuideViewController* userGuideVC = [sb instantiateViewControllerWithIdentifier:@"UserGuideViewController"];
    userGuideVC.textContent = guide.textContent;
    userGuideVC.preferredContentSize = CGSizeMake(180, 64);
    
    phonePopover = [[WYPopoverController alloc] initWithContentViewController:userGuideVC];
    phonePopover.passthroughViews = @[];
    phonePopover.wantsDefaultContentAppearance = YES;
    phonePopover.delegate = self;
    
    if ([guide.textContent isEqualToString:kUserGuideSelectCity]) {
        [phonePopover presentPopoverFromRect:guide.presentingViewController.view.frame inView:guide.fromView permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES options:WYPopoverAnimationOptionFadeWithScale];
        
    } else {
        [phonePopover presentPopoverFromRect:guide.fromRect inView:guide.fromView permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES options:WYPopoverAnimationOptionFadeWithScale];
    }

    [guideQueue removeObject:guide];
}

- (void) showNextGuide {
    if (guideQueue.count > 0) {
        UserGuideObject* userGuide = [guideQueue firstObject];
        if (userGuide != nil) {
            if (userGuide.presentingViewController.isViewLoaded && userGuide.presentingViewController.view.window) {
                [self showGuide:userGuide];
            } else {
                [self cancelUserGuide:userGuide];
                [self showNextGuide];
            }
        }
        
    }
}

- (void) cancelUserGuide:(UserGuideObject*) guide {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:guide.textContent];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [guideQueue removeObject:guide];
}

- (BOOL) checkUserGuideIsValidToAdd:(NSString*) guide {
    NSString* key = guide;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
        return YES;
    } else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue] == YES) {
            return YES;
        }
    }
    return NO;
}

- (void)resetUserGuide
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide1];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide2];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide3];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide4];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide5];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide6];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide7];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuide8];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideCircle];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideOval];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideReconnect];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideSelectCity];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideShowTips];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideSquare];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideTurnLeft];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserGuideTurnRight];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isPlaying
{
    if (isPhone) {
        if (phonePopover.isPopoverVisible) {
            return YES;
        }
        return NO;
    } else {
        if (popover.isPopoverVisible) {
            return YES;
        }
        return NO;
    }
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(id)popoverController
{
    UserGuideObject* nextGuide = [guideQueue firstObject];
    if (nextGuide!=nil) {
        [self showNextGuide];
    }
}

- (void)popoverControllerDidPresentPopover:(id)popoverController
{
    NSLog(@"%@", popover.contentViewController);
}

@end
