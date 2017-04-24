//
//  SharedLocation.h
//  L2DEvolution
//
//  Created by Hao Nguyen on 4/17/17.
//  Copyright © 2017 Hao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SharedLocation : NSObject

+ (CLPlacemark*)placemark;
+ (void)requestLocation;
+ (CLLocation*)location;
@end
