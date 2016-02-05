//
//  UserGuideViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 12/14/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "UserGuideViewController.h"
#import "Config.h"

@implementation UserGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isPhone) {
        self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
        self.lbTextContent.textColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.lbTextContent.textColor = [UIColor blackColor];//[Colours colorFromHex:@"24a1cc"];
        self.lbTextContent.font = [UIFont systemFontOfSize:14.0f];
    }
    self.lbTextContent.text = self.textContent;
}
- (CGSize)preferredContentSize {
    return CGSizeMake(180, 64);
}

@end
