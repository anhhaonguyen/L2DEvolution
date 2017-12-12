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
#import "SharedLocation.h"

#define kYokohamaURL        @"ws://139.162.47.39"//@"ws://188.166.225.139:4000"
#define kSaigonClassicURL   @"ws://139.162.47.39:4000"
#define kSaigonURL          @"ws://139.162.47.39"
#define kLaserURL           @"ws://139.162.47.39:9000" // Linode
#define kSocketURL          @"ws://139.162.47.39:3388"


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
    BOOL isConnected;
    
    SRWebSocket* currentActiveSocket;
    
    SRWebSocket* laserSocket;
    BOOL isLaserConnected;
}

@end

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isConnected = NO;
    isLaserConnected = NO;
    [self setupSocket];
    [self setupLaserSocket];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [socket closeWithCode:-1 reason:@"goback"];
    [laserSocket closeWithCode:-1 reason:@"goback"];
    [currentActiveSocket closeWithCode:-1 reason:@"goback"];
}

- (void)dealloc
{
    
}

- (void)setupLaserSocket
{
    laserSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kLaserURL]]];
    [laserSocket setDelegate:self];
    [laserSocket open];
}

- (void)setupSocket
{
    switch (self.tag) {
        case 0:
            socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSaigonClassicURL]]];
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

- (void)setupActiveCurrentSocket {
    currentActiveSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSocketURL]]];
    [currentActiveSocket setDelegate:self];
    [currentActiveSocket open];
}

- (void)sendLocation {
    CLPlacemark* placemark = [SharedLocation placemark];
    CLLocation* location = [SharedLocation location];
    
    if (placemark && location) {
        NSDictionary* dictionary = @{
                                     @"lat": @(location.coordinate.latitude),
                                     @"lng": @(location.coordinate.longitude),
                                     @"country_code": placemark.ISOcountryCode,
                                     @"country_name": placemark.country
                                     };
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Send location: %@", jsonString);
        [currentActiveSocket send:jsonString];
    }
}

- (void)reconnect
{
    socket = nil;
    laserSocket = nil;
    [self setupSocket];
    [self setupLaserSocket];
}

#pragma mark - WebSocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected");
    if (webSocket==laserSocket) {
        isLaserConnected = YES;
    } else if (webSocket==socket) {
        isConnected = YES;
        
    }
//    [self sendToken];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received \"%@\"", message);
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
    if (!isConnected) {
        return;
    }
    UIButton* button = (UIButton*)sender;
    NSString* message = [NSString stringWithFormat:@"%d", button.tag];
    [socket send:message];
    [self sendLocation];
}

- (IBAction)buttonReleased:(id)sender
{
    if (!isConnected) {
        return;
    }
    UIButton* button = (UIButton*)sender;
    
    if (button.tag==3 || button.tag==1) {
        [socket send:@"0"];
    } else {
        [socket send:@"5"];
    }
}
- (IBAction)laserButtonSelected:(id)sender
{
    if (!isLaserConnected) {
        return;
    }
    [laserSocket send:@"lz"];
    [self sendLocation];
}

- (IBAction)circleBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [laserSocket send:@"x"];
    [self sendLocation];
}

- (IBAction)squareBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [laserSocket send:@"y"];
    [self sendLocation];
}
- (IBAction)ovalBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [laserSocket send:@"z"];
    [self sendLocation];
}

- (IBAction)btnStateSelected:(id)sender
{
    if (socket.readyState==SR_CONNECTING || socket.readyState==SR_OPEN) {
        return;
    }
    [self reconnect];
}
#pragma mark - Helpers
//
//- (void)sendToken
//{
//    if (!isConnected) {
//        return;
//    } else if (isConnected) {
//        [socket send:[NSString stringWithFormat:@"send-token,%@,%@", @"abc", @"123123"]];
//    } else if (!isLaserConnected) {
//        return;
//    } else if (isLaserConnected) {
//        [socket send:[NSString stringWithFormat:@"send-token,%@,%@", @"abc", @"123123"]];
//    }
//    
//}

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
    if (!isConnected) {
        return;
    }
    
    [socket send:@"5"];
    [socket send:@"0"];
    [socket close];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Timeout" message:@"Your session is ended. System will disconnect now. Please help us spread this remote to the world" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles: @"OK", nil];
    alertView.tag = 2;
    [alertView show];
    [buttonState setImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
    
    if (!isLaserConnected) {
        return;
    }
    [laserSocket send:@"0"];
    [laserSocket close];
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
