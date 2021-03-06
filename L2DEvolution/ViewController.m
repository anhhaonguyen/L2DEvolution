//
//  ViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 11/2/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "SRWebSocket.h"
#import "AFNetworking.h"
#import <Social/Social.h>
#import "SharedLocation.h"

#define kURL @"ws://139.162.47.39:9000" //Linode
#define kURL2 @"ws://139.162.47.39:8000"
#define kSocketURL @"ws://139.162.47.39:3388"

@interface ViewController () <SRWebSocketDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    SRWebSocket* socket;
    __weak IBOutlet UIButton *buttonState;
    NSTimer* timer;
    BOOL isConnected;
    
    NSString* evoPrefix;
    
    SRWebSocket* currentActiveSocket;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isConnected = NO;
    evoPrefix = @"";
    [self setupSocket];
    [self setupActiveCurrentSocket];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [socket closeWithCode:-1 reason:@"goback"];
    [currentActiveSocket closeWithCode:-1 reason:@"goback"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    socket = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - WebSocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (webSocket == socket) {
        NSLog(@"Connected");
        isConnected = YES;
    }
//    [self sendToken];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received \"%@\"", message);
    if ([message isEqualToString:@"success"]) {
        NSLog(@"login successfully");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Welcome to License 2 Draw. Your 5 minutes Drawing session begins now!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = 1;
        [alertView show];
    } else if ([message isEqualToString:@"norobot"]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Robot" message:@"There is no robot with this name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    } else if ([message isEqualToString:@"your robot not available"]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Robot" message:@"Your desired robot is busy at the moment, please try again after 5 minutes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
    [buttonState setBackgroundImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
    buttonState.userInteractionEnabled = YES;
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [buttonState setBackgroundImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
    buttonState.userInteractionEnabled = YES;
}

#pragma mark - Helpers

//- (void)sendToken
//{
//    if (!isConnected) {
//        return;
//    }
//    [socket send:[NSString stringWithFormat:@"send-token,%@,%@", @"abc", @"123123"]];
//}

- (void)setupActiveCurrentSocket {
    currentActiveSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSocketURL]]];
    [currentActiveSocket setDelegate:self];
    [currentActiveSocket open];
}

- (void)setupSocket
{
    if (self.tag==9000) {
        NSLog(@"Connect to port 9000");
        socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURL]]];
        evoPrefix = @"E1";
    } else {
        NSLog(@"Connect to port 8000");
        socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURL2]]];
        evoPrefix = @"E2";
    }
    
    [socket setDelegate:self];
    [socket open];
}

- (void)reconnect
{
    socket = nil;
    [self setupSocket];
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
    [socket close];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Timeout" message:@"Your session is ended. System will disconnect now. Please help us spread this remote to the world" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles: @"OK", nil];
    alertView.tag = 2;
    [alertView show];
    [socket close];
    [buttonState setImage:[UIImage imageNamed:@"lost.png"] forState:UIControlStateNormal];
    buttonState.userInteractionEnabled = YES;
}

- (void)share
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Help us share" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Actions

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

- (IBAction)buttonPressed:(id)sender
{
    if (!isConnected) {
        return;
    }
    UIButton* btn = (UIButton*)sender;
    NSLog(@"Button %ld pressed", (long)btn.tag);
    NSString* message = [NSString stringWithFormat:@"%@%ld", evoPrefix, (long)btn.tag];
    [socket send:message];
    [self sendLocation];
}

- (IBAction)buttonReleased:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:[NSString stringWithFormat:@"%@5", evoPrefix]];
}

- (IBAction)squareBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"y"];
    [self sendLocation];
}
- (IBAction)circleBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"x"];
    [self sendLocation];
}
- (IBAction)ovalBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"z"];
    [self sendLocation];
}
- (IBAction)btnStateSelected:(id)sender
{
    [self reconnect];
}
- (IBAction)laserButtonSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"lz"];
    [self sendLocation];
}
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        [self startTimerCounting];
        [buttonState setBackgroundImage:[UIImage imageNamed:@"connected.png"] forState:UIControlStateNormal];
        buttonState.userInteractionEnabled = NO;
    } else if (alertView.tag==2) {
        if (buttonIndex==1) {
            [self share];
        }
    }
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
