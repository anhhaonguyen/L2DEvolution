//
//  NormalViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/4/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "SRWebSocket.h"
#import "NormalViewController.h"
#import <Social/Social.h>
#import "UserGuide.h"

#define kYokohamaURL @"ws://128.199.223.211:3005"
#define kLosAngelesURL @"ws://128.199.223.211:5000"
#define kSaigonURL @"ws://128.199.223.211:4000"


@interface NormalViewController () <SRWebSocketDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    SRWebSocket* socket;
    __weak IBOutlet UIButton *buttonState;
    __weak IBOutlet UIButton *btnCircle;
    __weak IBOutlet UIButton *btnSquare;
    __weak IBOutlet UIButton *btnOval;
    __weak IBOutlet UIButton *btn2;
    __weak IBOutlet UIButton *btn8;
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UIButton *btn3;
}

@end

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSocket];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [socket closeWithCode:-1 reason:@"goback"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideReconnect atView:buttonState fromRect:buttonState.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideSquare atView:btnSquare fromRect:btnSquare.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideOval atView:btnOval fromRect:btnOval.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideCircle atView:btnCircle fromRect:btnCircle.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuide2 atView:btn2 fromRect:btn2.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuide8 atView:btn8 fromRect:btn8.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideTurnLeft atView:btn1 fromRect:btn1.frame fromViewController:self];
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideTurnRight atView:btn3 fromRect:btn3.frame fromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

- (void)setupSocket
{
    switch (self.tag) {
        case 0:
            socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kLosAngelesURL]]];
            break;
        case 1:
            socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSaigonURL]]];
            break;
        default:
            socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kYokohamaURL]]];
            break;
    }
    [socket setDelegate:self];
    [socket open];
}

- (void)reconnect
{
    socket = nil;
    [self setupSocket];
}

#pragma mark - WebSocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected");
    [self sendToken];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received \"%@\"", message);
    if ([message isEqualToString:@"success"]) {
        NSLog(@"login successfully");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Welcome to License 2 Draw. Your 5 minutes Drawing session begins now!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = 1;
        [buttonState setImage:[UIImage imageNamed:@"connected.png"] forState:UIControlStateNormal];
        [alertView show];
    } else if ([message isEqualToString:@"norobot"]) {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Robot" message:@"There is no robot with this name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
    } else if ([message isEqualToString:@"your robot not available"]) {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Robot" message:@"Your desired robot is busy at the moment, please try again after 5 minutes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
    [buttonState setBackgroundImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [buttonState setBackgroundImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
}

#pragma mark - Actions
- (IBAction)directionButtonSelected:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* message = [NSString stringWithFormat:@"%d", button.tag];
    [socket send:message];
}

- (IBAction)buttonReleased:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    if (button.tag==3 || button.tag==1) {
        [socket send:@"0"];
    } else {
        [socket send:@"5"];
    }
}

- (IBAction)circleBtnSelected:(id)sender
{
    [socket send:@"x"];
}

- (IBAction)squareBtnSelected:(id)sender
{
    [socket send:@"y"];
}
- (IBAction)ovalBtnSelected:(id)sender
{
    [socket send:@"z"];
}

- (IBAction)btnStateSelected:(id)sender
{
    if (socket.readyState==SR_CONNECTING || socket.readyState==SR_OPEN) {
        return;
    }
    [self reconnect];
}
#pragma mark - Helpers

- (void)sendToken
{
    [socket send:[NSString stringWithFormat:@"send-token,%@,%@", @"abc", @"123123"]];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        [self startTimerCounting];
        [buttonState setBackgroundImage:[UIImage imageNamed:@"connected.png"] forState:UIControlStateNormal];
//        [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideSquare atView:btnSquare fromRect:btnSquare.frame fromViewController:self];
    } else if (alertView.tag==2) {
        if (buttonIndex==1) {
            [self share];
        }
    }
}

- (void)startTimerCounting
{
    [self performSelector:@selector(disconnectSocket) withObject:nil afterDelay:300.0f];
}


- (void)disconnectSocket
{
    [socket send:@"5"];
    [socket send:@"0"];
    [socket close];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Timeout" message:@"Your session is ended. System will disconnect now. Please help us spread this remote to the world" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles: @"OK", nil];
    alertView.tag = 2;
    [alertView show];
    [buttonState setImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
}

- (void)share
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Help us share" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        //share facebook
        SLComposeViewController* facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebook setInitialText:@"Drawing with UuDam's License 2 Draw. Can't believe that!"];
        [self presentViewController:facebook animated:YES completion:nil];
    } else if (buttonIndex==1) {
        //share twitter
        SLComposeViewController* twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitter setInitialText:@"Drawing UuDam's License 2 Draw. Can't believe that!"];
        [self presentViewController:twitter animated:YES completion:nil];
    }
}
@end
