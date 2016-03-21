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
}
- (IBAction)getVerifyCodeButtonPressed:(id)sender {
    NSString* url = [NSString stringWithFormat:@"register/%@", self.mobileTextField.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data) {
        if (statusCode == 200) {
            
            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Response body: %@", responseBody);
            
            Message* msg = [[Message alloc] initWithData:data error:nil];
            NSLog(@"Message: %@", msg.message);
            
        } else {
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
