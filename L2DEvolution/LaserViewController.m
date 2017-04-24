//
//  LaserViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 3/24/16.
//  Copyright © 2016 Hao Nguyen. All rights reserved.
//

#import "LaserViewController.h"
#import "SRWebSocket.h"
#import "SharedLocation.h"

#define kURL @"ws://139.162.47.39:9000"
#define kSocketURL @"ws://139.162.47.39:3388"

@interface LaserViewController () <SRWebSocketDelegate> {
    SRWebSocket* socket;
    SRWebSocket* currentActiveSocket;
    BOOL isConnected;
}

@end

@implementation LaserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isConnected = NO;
    [self setupSocket];
    [self setupActiveCurrentSocket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [socket closeWithCode:-1 reason:@"goback"];
    [currentActiveSocket closeWithCode:-1 reason:@"goback"];
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
    [self sendLocation];
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
        NSLog(@"Send location: %@", [dictionary description]);
        [currentActiveSocket send:[dictionary description]];
    }
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

- (void)setupActiveCurrentSocket {
    currentActiveSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSocketURL]]];
    [currentActiveSocket setDelegate:self];
    [currentActiveSocket open];
}

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
