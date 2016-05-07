//
//  CreateForumStepThreeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CreateForumStepThreeViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "CategoryCollectionViewCell.h"
#import "CreateForumSummaryTableViewController.h"

@interface CreateForumStepThreeViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CreateForumStepThreeViewController {
    NSArray<Category>* _categories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.estimatedItemSize = CGSizeMake(80, 30);
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] getDataWithUrl:@"forum/categories" completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            //            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //            NSLog(@"Response body: %@", responseBody);
            NSError* error;
            CategoryList* categoryList = [[CategoryList alloc] initWithData:data error:&error];
            if (error == nil) {
                _categories = categoryList.categories;
                for (Category* category in _categories) {
                    category.selected = nil;
                    for (NSNumber* categoryId in self.forumAdd.categoryIds) {
                        if (category.id == categoryId.integerValue) {
                            category.selected = @"selected";
                        }
                    }
                }
                
                [self.collectionView reloadData];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
        } else {
            [self.view makeToast:errorMessage duration:1.0f position:CSToastPositionCenter];
        }
    }];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_categories != nil) {
        return _categories.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Category* category = _categories[indexPath.row];
    
    cell.nameLabel.text = category.name;
    
    if (category.selected == nil) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor parimaryButton];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    CategoryCollectionViewCell* cell = (CategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    Category* category = _categories[indexPath.row];
    if (category.selected == nil) {
        category.selected = @"selected";
    } else {
        category.selected = nil;
    }
    
    [self.collectionView reloadData];
}

- (IBAction)nextButtonPressed:(id)sender {
    NSMutableArray* categoryIds = [[NSMutableArray alloc] init];
    for (Category* category in _categories) {
        if (category.selected != nil) {
            [categoryIds addObject:[NSNumber numberWithInteger:category.id]];
        }
    }
    self.forumAdd.categoryIds = [categoryIds copy];
    [self performSegueWithIdentifier:@"PushForumSummary" sender:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushForumSummary"]) {
        CreateForumSummaryTableViewController* createForumSummaryTableViewController = segue.destinationViewController;
        createForumSummaryTableViewController.forumAdd = self.forumAdd;
        createForumSummaryTableViewController.categories = _categories;
    }
}


@end
