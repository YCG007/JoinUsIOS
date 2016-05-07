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

@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *forumIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *forumStatisticsLabel;
@property (weak, nonatomic) IBOutlet UIButton *forumWatchButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


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
                
                self.forumNameLabel.text = topicList.forumInfo.name;
                if (topicList.forumInfo.icon != nil) {
                    [[NetworkManager sharedManager] getResizedImageWithName:topicList.forumInfo.icon dimension:120 completionHandler:^(long statusCode, NSData *data) {
                        if (statusCode == 200) {
                            self.forumIconImageView.image = [UIImage imageWithData:data];
                        } else {
                            self.forumIconImageView.image = [UIImage imageNamed:@"no_image"];
                        }
                    }];
                } else {
                    self.forumIconImageView.image = [UIImage imageNamed:@"no_photo"];
                }
                self.forumStatisticsLabel.text = [NSString stringWithFormat:@"关注:%d 帖子:%d", topicList.forumInfo.watch, topicList.forumInfo.posts];
                
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
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    TopicItem* topic = _listItems[indexPath.row];
    
    if (cell.tasks != nil && cell.tasks.count > 0) {
        for (NSURLSessionTask* task in cell.tasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
    }
    
    if (cell == nil) {
        cell.tasks = [[NSMutableArray alloc] init];
    }
    
    cell.userPhotoImageView.layer.cornerRadius = cell.userPhotoImageView.frame.size.width / 2;
    if (topic.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.userPhotoImageView.image = [UIImage imageWithData:data];
            } else {
                cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
            }
        }];
        [cell.tasks addObject:task];
    } else {
        cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
    
    cell.userNameLabel.text = topic.postedBy.name;
    if (topic.postedBy.gender.id == 2) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
    } else if (topic.postedBy.gender.id == 3) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
    }
    cell.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d ", topic.postedBy.level];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.topicPostDateLabel.text = [dateFormatter stringFromDate:topic.firstPostDate];
    cell.topicTitleLabel.text = topic.title;
    cell.topicStatisticsLabel.text = [NSString stringWithFormat:@"帖子:%d 浏览:%d", topic.posts, topic.views];
    cell.firstPostContentLabel.text = topic.firstPost.content;
    
    cell.firstPostImageView1.image = nil;
    cell.firstPostImageView2.image = nil;
    cell.firstPostImageView3.image = nil;
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 0) {
        cell.firstPostImageStackViewHeightConstraint.constant = (cell.frame.size.width - 16 - 6) / 3;
    } else {
        cell.firstPostImageStackViewHeightConstraint.constant = 0;
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 0) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[0] dimension:240 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView1.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 1) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[1] dimension:240 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView2.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 2) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[2] dimension:240 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView3.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
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
