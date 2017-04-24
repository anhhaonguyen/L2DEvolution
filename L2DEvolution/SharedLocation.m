//
//  SharedLocation.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 4/17/17.
//  Copyright © 2017 Hao Nguyen. All rights reserved.
//

#import "SharedLocation.h"

@interface SharedLocation () <CLLocationManagerDelegate>

@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property CLGeocoder* geoCoder;
@property CLPlacemark* currentPlacemark;
@end

static SharedLocation* _shared = nil;

@implementation SharedLocation

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [SharedLocation new];
        _shared.locationManager = [CLLocationManager new];
        _shared.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _shared.locationManager.delegate = _shared;
    });
    return _shared;
}

+ (void)requestLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [[[SharedLocation shared] locationManager] requestWhenInUseAuthorization];
    } else {
        [[[SharedLocation shared] locationManager] startUpdatingLocation];
    }
}

+ (CLPlacemark*)placemark {
    return _shared.currentPlacemark;
}

+ (CLLocation*)location {
    return _shared.currentLocation;
}

- (void)reverseGeoCoding:(CLLocation*)location {
    if (!self.geoCoder) {
        self.geoCoder = [[CLGeocoder alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            CLPlacemark* currentPlacemark = [placemarks lastObject];
            weakSelf.currentPlacemark = currentPlacemark;
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [manager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if([manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [manager requestAlwaysAuthorization];
            }
            break;
        case kCLAuthorizationStatusRestricted:
            [manager stopUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* newLocation = [locations lastObject];
    self.currentLocation = newLocation;
    
    [self.locationManager stopUpdatingLocation];
    
    [self reverseGeoCoding:self.currentLocation];
}

@end
