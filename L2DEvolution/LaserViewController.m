//
//  LaserViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 3/24/16.
//  Copyright © 2016 Hao Nguyen. All rights reserved.
//

#import "LaserViewController.h"
#import "SRWebSocket.h"

#define kURL @"ws://139.162.47.39:9000"

@interface LaserViewController () <SRWebSocketDelegate> {
    SRWebSocket* socket;
    BOOL isConnected;
}

@end

@implementation LaserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isConnected = NO;
    [self setupSocket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [socket closeWithCode:-1 reason:@"goback"];
}

- (void)dealloc
{
    socket = nil;
}

- (IBAction)laserButtonPressed:(UIButton*)sender
{
    NSLog(@"Laser %d pressed, lz%d", sender.tag, sender.tag);
    NSString* message = [NSString stringWithFormat:@"lz%ld", (long)sender.tag];
    [socket send:message];
}

#pragma mark - WS Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected");
    isConnected = YES;
//    [self sendToken];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received \"%@\"", message);
}

#pragma mark - Helpers

- (void)setupSocket
{
    socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kURL]]];
    [socket setDelegate:self];
    [socket open];
}

- (void)reconnect
{
    socket = nil;
    [self setupSocket];
}


@end
