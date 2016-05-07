//
//  LoginWithEmailVeifyCodeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 5/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "LoginWithEmailVeifyCodeViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface LoginWithEmailVeifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation LoginWithEmailVeifyCodeViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.getVerifyCodeButton.layer.cornerRadius = 3;
    self.loginButton.layer.cornerRadius = 5;
    
    if (kTimer != nil) {
        [kTimer invalidate];
        kTimer = nil;
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
        [self onTick];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    
    if (self.emailTextField.text.length < 5) {
        [self.view makeToast:@"请输入有效的邮箱"];
        return;
    }
    
    self.getVerifyCodeButton.enabled = NO;
    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    
    kCountDown = 60;
    if (kTimer == nil) {
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    }
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"login/email/%@", self.emailTextField.text];
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

- (IBAction)loginButtonPressed:(id)sender {
    
    if (self.emailTextField.text.length < 5 || self.verifyCodeTextField.text.length != 6) {
        [self.view makeToast:@"请输入有效的邮箱与验证码"];
        return;
    }
    
    EmailVerifyCode* emailVerifyCode = [[EmailVerifyCode alloc] init];
    emailVerifyCode.email = self.emailTextField.text;
    emailVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"login/email/verifyCode" data:[emailVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            //            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //            NSLog(@"Response body: %@", responseBody);
            NSError* error;
            UserProfileWithToken* userProfileWithToken = [[UserProfileWithToken alloc] initWithData:data error:&error];
            if (error == nil) {
                [[NetworkManager sharedManager] setMyProfile:[userProfileWithToken userProfile]];
                [[NetworkManager sharedManager] setToken:[userProfileWithToken userToken]];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
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
