//
//  UpdatePasswordViewController.m
//  JoinUs
//
//  Created by Liang Qian on 9/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface UpdatePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([NetworkManager sharedManager].myProfile.isPasswordSet) {
        self.currentPasswordTextField.hidden = NO;
    } else {
        self.currentPasswordTextField.hidden = YES;
    }
    self.submitButton.enabled = NO;
    self.submitButton.backgroundColor = [UIColor lightGrayColor];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* proposedtext = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.currentPasswordTextField) {
        if ((proposedtext.length >= 4 && proposedtext.length <= 16) || proposedtext.length == 0) {
            self.currentPasswordTextField.layer.borderColor = [UIColor greenColor].CGColor;
            self.currentPasswordTextField.layer.borderWidth = 1;
            self.currentPasswordTextField.layer.cornerRadius = 5;
        } else {
            self.currentPasswordTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.currentPasswordTextField.layer.borderWidth = 1;
            self.currentPasswordTextField.layer.cornerRadius = 5;
        }
    } else if (textField == self.passwordTextField) {
        if (proposedtext.length >= 4 && proposedtext.length <= 16) {
            self.passwordTextField.layer.borderColor = [UIColor greenColor].CGColor;
            self.passwordTextField.layer.borderWidth = 1;
            self.passwordTextField.layer.cornerRadius = 5;
        } else {
            self.passwordTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.passwordTextField.layer.borderWidth = 1;
            self.passwordTextField.layer.cornerRadius = 5;
        }
    } else if (textField == self.confirmPasswordTextField) {
        if ([proposedtext isEqualToString:self.passwordTextField.text]
            && self.passwordTextField.text.length >= 4) {

            self.confirmPasswordTextField.layer.borderColor = [UIColor greenColor].CGColor;
            self.confirmPasswordTextField.layer.borderWidth = 1;
            self.confirmPasswordTextField.layer.cornerRadius = 5;
            self.submitButton.enabled = YES;
            self.submitButton.backgroundColor = [UIColor colorForButtonParimary];
        } else {
            self.confirmPasswordTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.confirmPasswordTextField.layer.borderWidth = 1;
            self.confirmPasswordTextField.layer.cornerRadius = 5;
            self.submitButton.enabled = NO;
            self.submitButton.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    return YES;
}

- (IBAction)submitButtonPressed:(id)sender {
    
    UserPassword* userPassword = [[UserPassword alloc] init];
    userPassword.currentPassword = self.currentPasswordTextField.text;
    userPassword.password = self.passwordTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/password" data:[userPassword toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        //        NSLog(@"Status code: %ld, Data: %@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError *error;
            UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
            if (error != nil) NSLog(@"%@", error);
            [[NetworkManager sharedManager] setMyProfile:myProfile];
            
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
