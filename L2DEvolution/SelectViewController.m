//
//  SelectViewController.m
//  L2DEvolution
//
//  Created by Hao Nguyen on 11/18/14.
//  Copyright (c) 2014 Hao Nguyen. All rights reserved.
//

#import "SelectViewController.h"
#import "ViewController.h"
#import "NormalViewController.h"
#import "LaserViewController.h"

#define kLosAngelesTag 0
#define kSaigonTag 1
#define kTokyoTag 2
#define kYokohamaTag 3

@interface SelectViewController () {
    
    __weak IBOutlet UIButton *btnLA;
}

@end

@implementation SelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSLog(@"%@", NSStringFromCGRect(btnLA.frame));
//    [[UserGuide sharedInstance] addSimpleUserGuideWithText:kUserGuideSelectCity atView:btnLA fromRect:btnLA.frame fromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cityBtnSelected:(id)sender
{
    UIButton* button = (UIButton*)sender;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    NormalViewController* normalVC = [storyboard instantiateViewControllerWithIdentifier:@"NormalViewController"];
    LaserViewController* laserVC = [storyboard instantiateViewControllerWithIdentifier:@"LaserViewController"];
    switch (button.tag) {
        case kLosAngelesTag:
            normalVC.tag = kLosAngelesTag;
            [self.navigationController pushViewController:normalVC animated:YES];
            break;
        case kSaigonTag:
//            normalVC.tag = kSaigonTag;
            vc.tag = 9000;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case kYokohamaTag:
//            normalVC.tag = kYokohamaTag;
            [self.navigationController pushViewController:laserVC animated:YES];
            break;
        default:
//            normalVC.tag = kTokyoTag;
            vc.tag = 8000;
            [self.navigationController pushViewController:vc animated:YES];
            break;
    }
}

@end
