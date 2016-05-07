//
//  PersonalViewController.m
//  JoinUs
//
//  Created by Liang Qian on 26/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "PersonalViewController.h"
#import "NetworkManager.h"

const float kTableHeaderHeight = 220.0f;

@interface PersonalViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerTimeLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;

@end

@implementation PersonalViewController {
    UIView* _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // take away table header view
    _headerView = self.tableView.tableHeaderView;
    
    // set table header view height
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    
    // add it as table view's subview
    [self.tableView addSubview:_headerView];

    // adjust table content postition
    self.tableView.contentInset = UIEdgeInsetsMake(kTableHeaderHeight, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -kTableHeaderHeight);
    
    // round up photo image
    self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2;
    self.photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photoImageView.layer.borderWidth = 4;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    // transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self loadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    NSLog(@"viewWillLayoutSubviews");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    NSLog(@"viewDidLayoutSubviews");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    NSLog(@"viewDidDisappear");
    // remove transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)loadData{
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        UserProfile* myProfile = [NetworkManager sharedManager].myProfile;
        if (myProfile.photo) {
            [[NetworkManager sharedManager] getResizedImageWithName:myProfile.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
                if (statusCode == 200) {
                    self.photoImageView.image = [UIImage imageWithData:data];
                }
            }];
        } else {
            self.photoImageView.image = [UIImage imageNamed:@"no_photo"];
        }
        self.nameLabel.text = [NetworkManager sharedManager].myProfile.name;
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
        self.registerTimeLabel.text =  [NSString stringWithFormat:@"注册时间 %@", [dateFormater stringFromDate:[NetworkManager sharedManager].myProfile.registerDate]];
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"no_photo"];
        self.nameLabel.text = @"登录/注册";
        self.registerTimeLabel.text = @"注册会员体验更多功能!";
        self.navigationItem.rightBarButtonItem = self.loginButton;
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
}


- (IBAction)myProfileViewTapped:(UITapGestureRecognizer *)sender {
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        [self performSegueWithIdentifier:@"PushMyProfile" sender:self];
    } else {
        [self performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"Conent offset Y:%f", self.tableView.contentOffset.y);

    // update header view's position and height
    CGRect headerRect = CGRectMake(0, -kTableHeaderHeight, self.view.frame.size.width, kTableHeaderHeight);
    if (self.tableView.contentOffset.y < -kTableHeaderHeight) {
        headerRect.origin.y = self.tableView.contentOffset.y;
        headerRect.size.height = -self.tableView.contentOffset.y;
    }
    _headerView.frame = headerRect;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 5;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Section Header";
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    return @"Section Footer";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = @"XXXXXXXXXXX";
    cell.detailTextLabel.text = @"yyyyyyyyyyy";
    return cell;
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
