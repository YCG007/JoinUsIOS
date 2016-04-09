//
//  UpdateNameViewController.m
//  JoinUs
//
//  Created by Liang Qian on 9/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UpdateNameViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface UpdateNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation UpdateNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    self.nameTextField.text = myProfile.name;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* proposedtext = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    self.nameTextField.layer.borderColor = [UIColor blueColor].CGColor;
    self.nameTextField.layer.borderWidth = 1;
    self.nameTextField.layer.cornerRadius = 5;
    self.submitButton.enabled = NO;
    self.submitButton.backgroundColor = [UIColor lightGrayColor];
    
    UserName* userName = [[UserName alloc] init];
    userName.name = proposedtext;
    
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/validateName" data:[userName toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        
        if (statusCode == 200) {
            NSError *error;
            UserName* validUserName = [[UserName alloc] initWithData:data error:&error];
            if (error != nil) NSLog(@"%@", error);
            
            if ([validUserName.name isEqualToString:self.nameTextField.text]) {
                self.messageLabel.text = @"      ";
                self.nameTextField.layer.borderColor = [UIColor greenColor].CGColor;
                self.nameTextField.layer.borderWidth = 1;
                self.nameTextField.layer.cornerRadius = 5;
                self.submitButton.enabled = YES;
                self.submitButton.backgroundColor = [UIColor colorForButtonParimary];
            }
            
        } else if (statusCode == 406) {
            Message* msg = [[Message alloc] initWithData:data error:nil];
            if (msg != nil) {
                self.messageLabel.text = msg.message;
            }
            self.nameTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.nameTextField.layer.borderWidth = 1;
            self.nameTextField.layer.cornerRadius = 5;
            self.submitButton.enabled = NO;
            self.submitButton.backgroundColor = [UIColor lightGrayColor];
            
        }
    }];
    
    
    return YES;
}

- (IBAction)submitButtonPressed:(id)sender {
    UserName* userName = [[UserName alloc] init];
    userName.name = self.nameTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/name" data:[userName toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {

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
