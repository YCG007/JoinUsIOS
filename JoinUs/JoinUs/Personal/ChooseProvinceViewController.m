//
//  ChooseProvinceViewController.m
//  JoinUs
//
//  Created by Liang Qian on 16/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ChooseProvinceViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ProvinceCityTableViewCell.h"
#import "ChooseCityViewController.h"

@interface ChooseProvinceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseProvinceViewController {
    ProvinceList* _provinceList;
    UIView* _loadingView;
    UIView* _errorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showLoadingView];
    [self loadData];
}

- (void)loadData {
    [[NetworkManager sharedManager] getDataWithUrl:@"myProfile/provinces" completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        
        if (statusCode == 200) {
            NSError *error;
            _provinceList = [[ProvinceList alloc] initWithData:data error:&error];
            if (error != nil) NSLog(@"%@", error);
            [self.tableView reloadData];
            if (_loadingView) {
                [_loadingView removeFromSuperview];
            }
        } else {
            [self showErrorViewWithMessage:errorMessage];
        }
    }];
}

- (void)reloadData {
    if (_errorView) {
        [_errorView removeFromSuperview];
    }
    if (!_loadingView) {
        [self showLoadingView];
    }
    [self loadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_provinceList != nil) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_provinceList != nil && _provinceList.provinceItems != nil) {
            return _provinceList.provinceItems.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProvinceCityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ProvinceItem* provinceItem = [_provinceList.provinceItems objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = provinceItem.name;
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile != nil && myProfile.city != nil && myProfile.city.province != nil && myProfile.city.province.id == provinceItem.id)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"PushChooseCity" sender:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushChooseCity"]) {
        
        ChooseCityViewController* chooseCityViewController = segue.destinationViewController;
        chooseCityViewController.provinceItem = [_provinceList.provinceItems objectAtIndex:self.tableView.indexPathForSelectedRow.row];;
    }
}

- (void)showLoadingView {
    _loadingView = [[UIView alloc] init];
    _loadingView.backgroundColor = [UIColor whiteColor];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_loadingView];
    
    [_loadingView.topAnchor constraintEqualToAnchor:_loadingView.superview.topAnchor].active = YES;
    [_loadingView.bottomAnchor constraintEqualToAnchor:_loadingView.superview.bottomAnchor].active = YES;
    [_loadingView.leadingAnchor constraintEqualToAnchor:_loadingView.superview.leadingAnchor].active = YES;
    [_loadingView.trailingAnchor constraintEqualToAnchor:_loadingView.superview.trailingAnchor].active = YES;
    
    //    UIImageView* loadingIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loading"]];
    //    loadingIconImage.translatesAutoresizingMaskIntoConstraints = NO;
    //    [loadingView addSubview:loadingIconImage];
    //    [loadingIconImage.centerXAnchor constraintEqualToAnchor:loadingView.centerXAnchor].active = YES;
    //    [loadingIconImage.centerYAnchor constraintEqualToAnchor:loadingView.centerYAnchor].active = YES;
    
    float radius = 30;
    
    UIView* circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    circleView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_loadingView addSubview:circleView];
    circleView.backgroundColor = [UIColor clearColor];
    [circleView.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor].active = YES;
    [circleView.centerYAnchor constraintEqualToAnchor:_loadingView.centerYAnchor].active = YES;
    [circleView.widthAnchor constraintEqualToConstant:radius * 2].active = YES;
    [circleView.heightAnchor constraintEqualToConstant:radius * 2].active = YES;
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:1.8 * M_PI clockwise:YES].CGPath;
    circleLayer.strokeColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0].CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.lineCap = kCALineCapRound;
    circleLayer.lineWidth = 3;
    circleLayer.frame = CGRectMake(0, 0, radius * 2, radius * 2);
    circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [circleLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [circleView.layer addSublayer:circleLayer];
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    titleLabel.text = @"正在加载";
    [_loadingView addSubview:titleLabel];
    [titleLabel.topAnchor constraintEqualToAnchor:circleView.bottomAnchor constant:8].active = YES;
    [titleLabel.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor].active = YES;
}


- (void)showErrorViewWithMessage:(NSString*)message {
    _errorView = [[UIView alloc] init];
    _errorView.backgroundColor = [UIColor whiteColor];
    _errorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_errorView];
    
    [_errorView.topAnchor constraintEqualToAnchor:_errorView.superview.topAnchor].active = YES;
    [_errorView.bottomAnchor constraintEqualToAnchor:_errorView.superview.bottomAnchor].active = YES;
    [_errorView.leadingAnchor constraintEqualToAnchor:_errorView.superview.leadingAnchor].active = YES;
    [_errorView.trailingAnchor constraintEqualToAnchor:_errorView.superview.trailingAnchor].active = YES;
    
    UIImageView* errorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_error"]];
    errorImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_errorView addSubview:errorImage];
    [errorImage.centerXAnchor constraintEqualToAnchor:_errorView.centerXAnchor].active = YES;
    [errorImage.centerYAnchor constraintEqualToAnchor:_errorView.centerYAnchor].active = YES;
    
    UILabel* errorMsgLabel = [[UILabel alloc] init];
    errorMsgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    errorMsgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    errorMsgLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    errorMsgLabel.text = message;
    [_errorView addSubview:errorMsgLabel];
    [errorMsgLabel.topAnchor constraintEqualToAnchor:errorImage.bottomAnchor constant:10].active = YES;
    [errorMsgLabel.centerXAnchor constraintEqualToAnchor:_errorView.centerXAnchor].active = YES;
    
    UITapGestureRecognizer *errorReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadData)];
    [_errorView addGestureRecognizer:errorReload];
}

@end
