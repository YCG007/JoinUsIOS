//
//  RegisterGetVerifyCodeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 21/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "RegisterGetVerifyCodeViewController.h"
#import "NetworkManager.h"
#import "Models.h"
#import "Utils.h"

@interface RegisterGetVerifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;

@end

@implementation RegisterGetVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // button round corner
    self.getVerifyCodeButton.layer.cornerRadius = 5;
    
    // disable submit button
    self.getVerifyCodeButton.enabled = NO;
    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* text = textField.text;
    if (range.length > 0) {
        text = [text substringToIndex:(text.length - range.length)];
    } else {
        text = [text stringByAppendingString:string];
    }
    NSLog(@"Range location: %ld, length: %ld, string: %@, text: %@, will be: %@", range.location, range.length, string, textField.text, text);
    if (text.length < 11) {
        self.getVerifyCodeButton.enabled = NO;
        self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    } else if (text.length == 11) {
        self.getVerifyCodeButton.enabled = YES;
        self.getVerifyCodeButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
    } else if (text.length > 11) {
        return NO;
    }
    return YES;
}

- (IBAction)getVerifyCodeButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"register/%@", self.mobileTextField.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
//            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"Response body: %@", responseBody);
            Message* msg = [[Message alloc] initWithData:data error:nil];
            
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [self performSegueWithIdentifier:@"PushRegisterWIthVerifyCode" sender:self];
            }];
            
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

- (IBAction)showAgreementButtonPressed:(id)sender {
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

//kCFURLErrorUnknown   = -998,
//kCFURLErrorCancelled = -999,
//kCFURLErrorBadURL    = -1000,
//kCFURLErrorTimedOut  = -1001,
//kCFURLErrorUnsupportedURL = -1002,
//kCFURLErrorCannotFindHost = -1003,
//kCFURLErrorCannotConnectToHost    = -1004,
//kCFURLErrorNetworkConnectionLost  = -1005,
//kCFURLErrorDNSLookupFailed        = -1006,
//kCFURLErrorHTTPTooManyRedirects   = -1007,
//kCFURLErrorResourceUnavailable    = -1008,
//kCFURLErrorNotConnectedToInternet = -1009,
//kCFURLErrorRedirectToNonExistentLocation = -1010,
//kCFURLErrorBadServerResponse             = -1011,
//kCFURLErrorUserCancelledAuthentication   = -1012,
//kCFURLErrorUserAuthenticationRequired    = -1013,
//kCFURLErrorZeroByteResource        = -1014,
//kCFURLErrorCannotDecodeRawData     = -1015,
//kCFURLErrorCannotDecodeContentData = -1016,
//kCFURLErrorCannotParseResponse     = -1017,
//kCFURLErrorInternationalRoamingOff = -1018,
//kCFURLErrorCallIsActive               = -1019,
//kCFURLErrorDataNotAllowed             = -1020,
//kCFURLErrorRequestBodyStreamExhausted = -1021,
//kCFURLErrorFileDoesNotExist           = -1100,
//kCFURLErrorFileIsDirectory            = -1101,
//kCFURLErrorNoPermissionsToReadFile    = -1102,
//kCFURLErrorDataLengthExceedsMaximum   = -1103,
