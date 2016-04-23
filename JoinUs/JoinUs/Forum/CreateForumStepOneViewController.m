//
//  CreateForumStepOneViewController.m
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CreateForumStepOneViewController.h"
#import "NetworkManager.h"
#import "CreateForumStepTwoViewController.h"

@interface CreateForumStepOneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *validateNameMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *descLabel;

@end

@implementation CreateForumStepOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)nextStepButtonPressed:(id)sender {
    
    if (self.forumAdd == nil) {
        self.forumAdd = [[ForumAdd alloc] init];
    }
    self.forumAdd.name = self.nameLabel.text;
    self.forumAdd.desc = self.descLabel.text;
    
    [self performSegueWithIdentifier:@"PushStepTwo" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushStepTwo"]) {
        
        CreateForumStepTwoViewController* createForumStepTwoViewController = segue.destinationViewController;
        createForumStepTwoViewController.forumAdd = self.forumAdd;
    }
}


@end
