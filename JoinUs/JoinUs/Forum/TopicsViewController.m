//
//  TopicsViewController.m
//  JoinUs
//
//  Created by Liang Qian on 26/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "TopicsViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "TopicItemTableViewCell.h"

@interface TopicsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;

@end

@implementation TopicsViewController{
    NSMutableArray<TopicItem*>* _listItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.forumNameLabel.text = @"dfdfdfdf";
    
    [self addLoadingViews];
    [self showLoadingView];
    [self startupLoad];
}

- (void)loadData {
    NSString* url = [NSString stringWithFormat:@"forum/%@?offset=%d&limit=%d", self.forumId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            TopicListLimited* topicList = [[TopicListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                if (topicList.limit > topicList.topicItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (self.loadingStatus == LoadingStatusReloading) {
                    [_listItems removeAllObjects];
                }
                
                for (TopicItem* item in topicList.topicItems) {
                    [_listItems addObject:item];
                }
                
                [self.tableView reloadData];
            } else {
                NSLog(@"JSON Error: %@", error);
            }
        } else {
            if (self.loadingStatus == LoadingStatusStartupLoading) {
                [self showErrorViewWithMessage:errorMessage];
            } else {
                [self.view makeToast:errorMessage];
            }
        }
        
        [self removeLoadingViews];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_listItems != nil) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TopicItem* item = _listItems[indexPath.row];
    if (cell.task != nil && cell.task.state == NSURLSessionTaskStateRunning) {
        [cell.task cancel];
    }
    
//    if (item.icon != nil) {
//        cell.task = [[NetworkManager sharedManager] getResizedImageWithName:item.icon dimension:120 completionHandler:^(long statusCode, NSData *data) {
//            if (statusCode == 200) {
//                cell.iconImageView.image = [UIImage imageWithData:data];
//            } else {
//                cell.iconImageView.image = [UIImage imageNamed:@"no_photo"];
//            }
//        }];
//    } else {
//        cell.iconImageView.image = [UIImage imageNamed:@"no_photo"];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
