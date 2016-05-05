//
//  UpdateGenderTableViewController.m
//  JoinUs
//
//  Created by Liang Qian on 31/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UpdateGenderTableViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface UpdateGenderTableViewController ()

@end

@implementation UpdateGenderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self loadData];
}

- (void)loadData {
    if ([NetworkManager sharedManager].myProfile.gender) {
        for (int i = 0; i < 3; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if ([NetworkManager sharedManager].myProfile.gender.id == i + 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < 3; i++) {
        NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:tempIndexPath];
        if (i == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [self.tableView  deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)submitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    UserGender* userGender = [[UserGender alloc] init];
    userGender.genderId = 1;
    for (int i = 0; i < 3; i++) {
        NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:tempIndexPath];
   
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            userGender.genderId = i + 1;
    }
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/gender" data:[userGender toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
//        NSLog(@"Status code: %ld, Data: %@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError *error;
            UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
            if (error != nil) NSLog(@"%@", error);
            
            [[NetworkManager sharedManager] setMyProfile:myProfile];
            //                NSLog(@"%@", myProfile);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
