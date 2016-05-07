//
//  UpdateMobileViewController.m
//  JoinUs
//
//  Created by Liang Qian on 5/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UpdateMobileViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface UpdateMobileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentMobileLabel;

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation UpdateMobileViewController {
    NSTimer* _timer;
    int _countDown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.getVerifyCodeButton.layer.cornerRadius = 3;
    self.submitButton.layer.cornerRadius = 5;
    
    UserProfile* myProfile = [NetworkManager sharedManager].myProfile;
    if (myProfile.mobile != nil && myProfile.mobile.length > 0) {
        self.currentMobileLabel.text = myProfile.mobile;
    } else {
        self.currentMobileLabel.text = @"未设置";
    }
    
    if (kTimer != nil) {
        [kTimer invalidate];
        kTimer = nil;
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
        [self onTick];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTick {
    if (kCountDown > 0) {
        kCountDown--;
    }
    NSLog(@"Tick! %d", kCountDown);
    
    if (kCountDown > 0) {
        [self.getVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ds)", kCountDown] forState:UIControlStateDisabled];
        self.getVerifyCodeButton.enabled = NO;
        self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    } else {
        [self.getVerifyCodeButton setTitle:[NSString stringWithFormat:@"获取验证码"] forState:UIControlStateNormal];
        self.getVerifyCodeButton.enabled = YES;
        self.getVerifyCodeButton.backgroundColor = [UIColor secondaryButton];
        
        [kTimer invalidate];
        kTimer = nil;
    }
}

- (IBAction)getVerifyCodeButtonPressed:(id)sender {
    self.getVerifyCodeButton.enabled = NO;
    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    
    kCountDown = 60;
    if (kTimer == nil) {
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    }
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"myProfile/updateMobileVerifyCode/%@", self.mobileTextField.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError* error;
            Message* msg = [[Message alloc] initWithData:data error:&error];
            if (error == nil) {
                [self.view makeToast:msg.message];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (IBAction)submitButtonPressed:(id)sender {
    
    if (self.mobileTextField.text.length < 11 || self.verifyCodeTextField.text.length != 6) {
        [self.view makeToast:@"请输入有效的手机号码与验证码"];
        return;
    }
    
    MobileVerifyCode* mobileVerifyCode = [[MobileVerifyCode alloc] init];
    mobileVerifyCode.mobile = self.mobileTextField.text;
    mobileVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/mobile" data:[mobileVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError *error;
            UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
            if (error == nil) {
                [[NetworkManager sharedManager] setMyProfile:myProfile];
            } else {
                NSLog(@"%@", error);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
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
