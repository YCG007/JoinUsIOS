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
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginWithPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [self.view makeToastActivity:CSToastPositionCenter];
    
    MobilePassword* mobilePassword = [[MobilePassword alloc] init];
    mobilePassword.mobile = self.mobileTextField.text;
    mobilePassword.password = self.passwordTextField.text;
    
    [[NetworkManager sharedManager] postDataWithUrl:@"login/password" data:[mobilePassword toJSONData] completionHandler:^(long statusCode, NSData *data) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Response body: %@", responseBody);
            NSError* error;
            UserProfileWithToken* userProfileWithToken = [[UserProfileWithToken alloc] initWithData:data error:&error];
            
            if (error == nil) {
                [[NetworkManager sharedManager] setMyProfile:[userProfileWithToken userProfile]];
                [[NetworkManager sharedManager] setToken:[userProfileWithToken userToken]];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
            
            
        } else  if (statusCode == 400) {
            Message* msg = [[Message alloc] initWithData:data error:nil];
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter];
        } else if (statusCode == kCFURLErrorNotConnectedToInternet) {
            [self.view makeToast:@"请检查您的网络连接" duration:1.0f position:CSToastPositionCenter];
        } else {
            [self.view makeToast:@"网络异常" duration:1.0f position:CSToastPositionCenter];
            NSLog(@"Status Code: %ld; Data:%@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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
