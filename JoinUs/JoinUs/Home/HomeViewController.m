//
//  HomeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 13/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "HomeViewController.h"
#import "CTBasicViewController.h"
#import "CTMasterViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)assetsPickerButtonPressed:(id)sender {
    CTMasterViewController* masterViewController = [[CTMasterViewController alloc] init] ;
    [self.navigationController pushViewController:masterViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
