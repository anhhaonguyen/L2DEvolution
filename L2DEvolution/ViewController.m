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

#define kURL @"ws://188.166.225.139:9000"
#define kURL2 @"ws://188.166.225.139:8000"

@interface ViewController () <SRWebSocketDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    SRWebSocket* socket;
    __weak IBOutlet UIButton *buttonState;
    NSTimer* timer;
    BOOL isConnected;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isConnected = NO;
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
    NSLog(@"Connected");
    isConnected = YES;
    [self sendToken];
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

- (void)sendToken
{
    if (!isConnected) {
        return;
    }
    [socket send:[NSString stringWithFormat:@"send-token,%@,%@", @"abc", @"123123"]];
}

- (void)setupSocket
{
    if (self.tag==9000) {
        NSLog(@"Connect to port 9000");
        socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURL]]];
    } else {
        NSLog(@"Connect to port 8000");
        socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURL2]]];
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

- (IBAction)buttonPressed:(id)sender
{
    if (!isConnected) {
        return;
    }
    UIButton* btn = (UIButton*)sender;
    NSLog(@"Button %ld pressed", (long)btn.tag);
    NSString* message = [NSString stringWithFormat:@"%ld", (long)btn.tag];
    [socket send:message];
}

- (IBAction)buttonReleased:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"5"];
}

- (IBAction)squareBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"y"];
}
- (IBAction)circleBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"x"];
}
- (IBAction)ovalBtnSelected:(id)sender
{
    if (!isConnected) {
        return;
    }
    [socket send:@"z"];
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
