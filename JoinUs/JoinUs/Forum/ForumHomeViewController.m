//
//  ForumHomeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 25/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ForumHomeViewController.h"
#import "ForumSearchResultViewController.h"

@interface ForumHomeViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ForumHomeViewController {
    UISearchController* _searchController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ForumSearchResultViewController* searchResultController = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumSearchResult"];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultController];
    _searchController.searchResultsUpdater = searchResultController;
    _searchController.delegate = self;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.dimsBackgroundDuringPresentation = YES;
    _searchController.searchBar.placeholder = @"搜索热门论坛";
    _searchController.searchBar.delegate = searchResultController;
    self.navigationItem.titleView = _searchController.searchBar;
    //
    self.definesPresentationContext = YES;
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearchController");
}
- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearchController");
}
- (void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"willDismissSearchController");
}
- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"didDismissSearchController");
}



- (IBAction)segmentValueChanged:(id)sender {
//    NSLog(@"segment index: %ld", (long)self.segment.selectedSegmentIndex);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.scrollView.contentOffset = CGPointMake(self.segment.selectedSegmentIndex * self.view.bounds.size.width, 0);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"offset x: %f", scrollView.contentOffset.x);
    float offset = scrollView.contentOffset.x;
    float screenWidth = self.view.bounds.size.width;
    
    int index =  (int)roundf(offset / screenWidth);
    self.segment.selectedSegmentIndex = index;
//    [self onScreenViewControllerChangedToIndex:index];
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
