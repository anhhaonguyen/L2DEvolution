//
//  SocketConnection.h
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/4/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface SocketConnection : NSObject

+ (SRWebSocket*)connectionWithPort:(NSInteger)port inViewController:(UIViewController*)viewController;

@end
