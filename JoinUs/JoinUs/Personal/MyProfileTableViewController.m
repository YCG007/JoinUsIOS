//
//  MyProfileTableViewController.m
//  JoinUs
//
//  Created by Liang Qian on 31/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface MyProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerDateLabel;


@end

@implementation MyProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}


- (void)loadData {
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile.photo) {
        [[NetworkManager sharedManager] getResizedImageWithName:myProfile.photo dimension:80 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                self.photoImageView.image = [UIImage imageWithData:data];
            }
        }];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
    self.nameLabel.text = myProfile.name;
    self.mobileLabel.text = myProfile.mobile ? myProfile.mobile : @"未设置";
    self.emailLabel.text = myProfile.email ? myProfile.email : @"未设置";
    self.passwordLabel.text = myProfile.isPasswordSet ? @"修改密码" : @"设置密码";
    self.genderLabel.text = myProfile.gender.name;
    self.cityLabel.text = myProfile.city ? [NSString stringWithFormat:@"%@ %@", myProfile.city.province.name, myProfile.city.name] : @"选择所在地区";
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    self.lastUpdateDateLabel.text = [dateFormatter stringFromDate:myProfile.lastUpdateDate];
    self.registerDateLabel.text = [dateFormatter stringFromDate:myProfile.registerDate];
}


- (IBAction)logoutButtonPressed:(id)sender {
    [[NetworkManager sharedManager] logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - Navigation

- (IBAction)unwindToMyProfile:(UIStoryboardSegue*)sender
{
    // UIViewController *sourceViewController = sender.sourceViewController;
    // Pull any data from the view controller which initiated the unwind segue.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
