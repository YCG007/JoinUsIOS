//
//  CountriesSearchResultViewController.m
//  JoinUs
//
//  Created by Liang Qian on 6/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CountriesSearchResultViewController.h"
#import "NetworkManager.h"
#import "Utils.h"

@interface CountriesSearchResultViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CountriesSearchResultViewController{
    NSArray<Country*>* _countries;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadDataWithSearchText:(NSString*) text {
    NSString* url = [NSString stringWithFormat:@"test/countries?search=%@", text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        
        if (statusCode == 200) {
            NSError *error;
            _countries = [Country arrayOfModelsFromData:data error:&error];
            if (error == nil) {
                [self.tableView reloadData];
            } else {
                NSLog(@"%@", error);
            }
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController - %@", searchController.searchBar.text);
    [self loadDataWithSearchText:searchController.searchBar.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_countries != nil) {
        return _countries.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Country* country = _countries[indexPath.row];
    cell.textLabel.text = country.name;
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
