//
//  SocketConnection.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/4/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "SocketConnection.h"
#import "Config.h"

@implementation SocketConnection

+ (SRWebSocket*)connectionWithPort:(NSInteger)port inViewController:(UIViewController *)viewController
{
    SRWebSocket* connection = nil;
    switch (port) {
        case kYokohamaPort:
            connection = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kYokohamaURL]]];
            break;
        case kTokyoPort:
            connection = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kTokyoURL]]];
            break;
        case kSaigonPort:
            connection = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSaigonURL]]];
            break;
        case kLosAngelesPort:
            connection = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kLosAngelesURL]]];
            break;
    }
    return connection;
}

@end
