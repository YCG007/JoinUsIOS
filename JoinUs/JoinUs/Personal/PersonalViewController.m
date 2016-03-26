//
//  PersonalViewController.m
//  JoinUs
//
//  Created by Liang Qian on 26/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "PersonalViewController.h"
#import "NetworkManager.h"

@interface PersonalViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myProfileLabel;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)loadData {
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        self.myProfileLabel.text = [NetworkManager sharedManager].myProfile.name;
    } else {
        self.myProfileLabel.text = @"您还没有登录，请登录或注册！";
    }
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
