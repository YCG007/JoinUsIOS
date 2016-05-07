//
//  CountriesViewController.m
//  JoinUs
//
//  Created by Liang Qian on 6/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CountriesViewController.h"
#import "NetworkManager.h"
#import "Utils.h"
#import "CountriesSearchResultViewController.h"

@interface CountriesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CountriesViewController {
    NSArray<Country*>* _countries;
    UISearchController* _searchController;
    UIView* _searchHistoryView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadDataWithSearchText:@""];
    
    CountriesSearchResultViewController* searchResultController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountriesSearchResult"];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultController];
    _searchController.searchResultsUpdater = searchResultController;
    _searchController.delegate = self;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.dimsBackgroundDuringPresentation = NO;
////    _searchController.searchBar.tintColor = [UIColor redColor];
////    _searchController.searchBar.barTintColor = [UIColor whiteColor];
//    _searchController.searchBar.placeholder = @"Search Something";
////    _searchController.searchBar.prompt = @"Quick Search";
//    _searchController.searchBar.delegate = self;
//    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchController.searchBar;
//
    self.definesPresentationContext = YES;
}

//- (void)loadData {
//    [[NetworkManager sharedManager] getDataWithUrl:@"test/countries" completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
//        
//        if (statusCode == 200) {
//            NSError *error;
//            _countries = [Country arrayOfModelsFromData:data error:&error];
//            if (error == nil) {
//            [self.tableView reloadData];
//            } else {
//                NSLog(@"%@", error);
//            }
//        } else {
//            [self.view makeToast:errorMessage];
//        }
//    }];
//}

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

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearchController");
    [self showSearchHistory];
}
- (void)didPresentSearchController:(UISearchController *)searchController {
    
}
- (void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"willDismissSearchController");
    [self removeSearchHistory];
}
- (void)didDismissSearchController:(UISearchController *)searchController {
    
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

- (void)showSearchHistory {
    _searchHistoryView = [[UIView alloc] init];
    _searchHistoryView.backgroundColor = [UIColor whiteColor];
    _searchHistoryView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_searchHistoryView];
    
    [_searchHistoryView.topAnchor constraintEqualToAnchor:_searchHistoryView.superview.topAnchor].active = YES;
    [_searchHistoryView.bottomAnchor constraintEqualToAnchor:_searchHistoryView.superview.bottomAnchor].active = YES;
    [_searchHistoryView.leadingAnchor constraintEqualToAnchor:_searchHistoryView.superview.leadingAnchor].active = YES;
    [_searchHistoryView.trailingAnchor constraintEqualToAnchor:_searchHistoryView.superview.trailingAnchor].active = YES;
    
    UIImageView* iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_error"]];
    iconImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchHistoryView addSubview:iconImage];
    [iconImage.centerXAnchor constraintEqualToAnchor:_searchHistoryView.centerXAnchor].active = YES;
    [iconImage.centerYAnchor constraintEqualToAnchor:_searchHistoryView.centerYAnchor].active = YES;
    
    UILabel* promotingMsgLabel = [[UILabel alloc] init];
    promotingMsgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    promotingMsgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    promotingMsgLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    promotingMsgLabel.text = @"点击搜索China";
    [_searchHistoryView addSubview:promotingMsgLabel];
    [promotingMsgLabel.topAnchor constraintEqualToAnchor:iconImage.bottomAnchor constant:10].active = YES;
    [promotingMsgLabel.centerXAnchor constraintEqualToAnchor:iconImage.centerXAnchor].active = YES;
    
    UITapGestureRecognizer *tapToSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchHistoryTapped)];
    [_searchHistoryView addGestureRecognizer:tapToSearch];
}

- (void)searchHistoryTapped {
    NSLog(@"Search history Tapped");
    _searchController.searchBar.text = @"China";
}

- (void)removeSearchHistory {
    if (_searchHistoryView != nil) {
        [_searchHistoryView removeFromSuperview];
    }
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
