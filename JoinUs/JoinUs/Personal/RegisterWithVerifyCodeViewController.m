//
//  RegisterWithVerifyCodeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 26/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "RegisterWithVerifyCodeViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface RegisterWithVerifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerSubmitButton;

@end

@implementation RegisterWithVerifyCodeViewController {
    NSTimer* _timer;
    int _countDown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _countDown = 10;
    
    self.mobileNumberLabel.text = self.mobileNumber;
    self.resendVerifyCodeButton.layer.cornerRadius = 3;
    self.registerSubmitButton.layer.cornerRadius = 5;
    
    // disable resend button
    [self.resendVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ds)", _countDown] forState:UIControlStateDisabled];
    self.resendVerifyCodeButton.enabled = NO;
    self.resendVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    
    // disable submit button
    self.registerSubmitButton.enabled = NO;
    self.registerSubmitButton.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (void)onTick {
    NSLog(@"Tick!");
    _countDown--;
    
    if (_countDown > 0) {
        [self.resendVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ds)", _countDown] forState:UIControlStateDisabled];
        self.resendVerifyCodeButton.enabled = NO;
        self.resendVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    } else if (_countDown == 0) {
        [self.resendVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取"] forState:UIControlStateNormal];
        self.resendVerifyCodeButton.enabled = YES;
        self.resendVerifyCodeButton.backgroundColor = [UIColor colorWithRGBValue:0x00bbd5];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* text = textField.text;
    if (range.length > 0) {
        text = [text substringToIndex:(text.length - range.length)];
    } else {
        text = [text stringByAppendingString:string];
    }
//    NSLog(@"Range location: %ld, length: %ld, string: %@, text: %@, will be: %@", range.location, range.length, string, textField.text, text);
    if (text.length < 6) {
        self.registerSubmitButton.enabled = NO;
        self.registerSubmitButton.backgroundColor = [UIColor lightGrayColor];
    } else if (text.length == 6) {
        self.registerSubmitButton.enabled = YES;
        self.registerSubmitButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
    } else if (text.length > 6) {
        return NO;
    }
    return YES;
}

- (IBAction)resendVerifyCodeButtonPressed:(id)sender {
    self.resendVerifyCodeButton.enabled = NO;
    self.resendVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    _countDown = 10;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"register/%@", self.mobileNumberLabel.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            Message* msg = [[Message alloc] initWithData:data error:nil];
            
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter];
            
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

- (IBAction)registerSubmitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    MobileVerifyCode* mobileVerifyCode = [[MobileVerifyCode alloc] init];
    mobileVerifyCode.mobile = self.mobileNumberLabel.text;
    mobileVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [[NetworkManager sharedManager] putDataWithUrl:@"register" data:[mobileVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data) {
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
