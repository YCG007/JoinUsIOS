//
//  CreateForumSummaryTableViewController.m
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CreateForumSummaryTableViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface CreateForumSummaryTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation CreateForumSummaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = self.forumAdd.name;
    self.descLabel.text = self.forumAdd.desc;
    self.iconImageView.image = self.forumAdd.iconImage;
    
    self.categoryLabel.text = @"";
    for (Category* category in self.categories) {
        if (category.selected != nil) {
            self.categoryLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.categoryLabel.text, @"\n", category.name];
        }
    }
}

- (IBAction)submitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    NSData* imageData = UIImageJPEGRepresentation(self.forumAdd.iconImage, 0.9);
    [[NetworkManager sharedManager] uploadImageWithUrl:@"upload/image" data:imageData completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            UploadImage* uploadImage = [[UploadImage alloc] initWithData:data error:&error];
            self.forumAdd.iconImageId = uploadImage.imageId;
            
            [[NetworkManager sharedManager] putDataWithUrl:@"forum" data:[self.forumAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                [self.view hideToastActivity];
                if (statusCode == 200) {
//                    [self performSegueWithIdentifier:@"UnwindToForumHome" sender:self];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    [self.view makeToast:errorMessage];
                }
            }];
            
        } else {
            [self.view hideToastActivity];
            [self.view makeToast:errorMessage];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
