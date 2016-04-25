//
//  ChooseCityViewController.m
//  JoinUs
//
//  Created by Liang Qian on 16/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ChooseCityViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ProvinceCityTableViewCell.h"

@interface ChooseCityViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.provinceItem != nil) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.provinceItem != nil && self.provinceItem.cityItems != nil) {
            return self.provinceItem.cityItems.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProvinceCityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CityItem* cityItem = [self.provinceItem.cityItems objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = cityItem.name;
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile != nil && myProfile.city != nil && myProfile.city.id == cityItem.id)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CityItem* cityItem = [self.provinceItem.cityItems objectAtIndex:indexPath.row];
    
    UserCity* userCity = [[UserCity alloc] init];
    userCity.cityId = cityItem.id;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/city" data:[userCity toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        //        NSLog(@"Status code: %ld, Data: %@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError *error;
            UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
            if (error != nil) NSLog(@"%@", error);
            [[NetworkManager sharedManager] setMyProfile:myProfile];
            
            [self performSegueWithIdentifier:@"UnwindToMyProfile" sender:self];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
