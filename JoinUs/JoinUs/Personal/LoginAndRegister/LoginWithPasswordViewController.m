//
//  LoginWithPasswordViewController.m
//  JoinUs
//
//  Created by Liang Qian on 21/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "LoginWithPasswordViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface LoginWithPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginWithPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginButton.layer.cornerRadius = 5;
    //    self.loginButton.layer.borderWidth = 1.0f;
    //    self.loginButton.layer.borderColor = [UIColor grayColor].CGColor;
//    self.loginButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//    self.loginButton.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
//    self.loginButton.layer.shadowRadius = 5.0f;
//    self.loginButton.layer.shadowOpacity = 1.0f;
}

- (IBAction)loginButtonPressed:(id)sender {
    
    AccountPassword* accountPassword = [[AccountPassword alloc] init];
    accountPassword.account = self.accountTextField.text;
    accountPassword.password = self.passwordTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"login/password" data:[accountPassword toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        
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


- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
