//
//  ForumTopicsViewController.m
//  JoinUs
//
//  Created by Liang Qian on 12/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ForumTopicsViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "TopicItemTableViewCell.h"
#import "CreateTopicViewController.h"
#import "TopicPostsViewController.h"

@interface ForumTopicsViewController ()
@property (weak, nonatomic) IBOutlet UIStackView *actionsStackView;
@property (weak, nonatomic) IBOutlet UIButton *postTopicButton;
@property (weak, nonatomic) IBOutlet UIButton *watchListButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteForumButton;

@property (weak, nonatomic) IBOutlet UIView *forumView;
@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *forumIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *forumStatisticsLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@property (weak, nonatomic) IBOutlet UILabel *forumDescLabel;
@property (weak, nonatomic) IBOutlet UIView *watchedByMeView;
@property (weak, nonatomic) IBOutlet UILabel *myLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *myPostsLabel;
@property (weak, nonatomic) IBOutlet UIButton *unwatchButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ForumTopicsViewController {
    NSMutableArray<TopicItem*>* _listItems;
    ForumInfo* _forumInfo;
    BOOL _isLoggedInLastLoad;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.actionsStackView.hidden = YES;
    
    [self addRefreshViewAndLoadMoreView];
    [self loadWithLoadingView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (_isLoggedInLastLoad != [[NetworkManager sharedManager] isLoggedIn]) {
        [self loadWithToastActivity];
    }
}

- (void)loadData {
    _isLoggedInLastLoad = [[NetworkManager sharedManager] isLoggedIn];
    NSString* url = [NSString stringWithFormat:@"forum/%@?offset=%d&limit=%d", self.forumId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            TopicListLimited* topicList = [[TopicListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                _forumInfo = topicList.forumInfo;
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
                    self.forumIconImageView.image = [UIImage imageNamed:@"no_image"];
                }
                self.forumStatisticsLabel.text = [NSString stringWithFormat:@"关注:%d 帖子:%d", topicList.forumInfo.watch, topicList.forumInfo.posts];
                self.forumDescLabel.text = topicList.forumInfo.desc;
                
                if (topicList.forumInfo.watchedByMe != nil) {
                    self.watchedByMeView.hidden = NO;
                    self.myLevelLabel.text = [NSString stringWithFormat:@" LV.%d ", topicList.forumInfo.watchedByMe.level];
                    self.myPostsLabel.text = [NSString stringWithFormat:@"发帖:%d", topicList.forumInfo.watchedByMe.posts];
                    self.watchButton.hidden = YES;
                } else {
                    self.watchedByMeView.hidden = YES;
                    self.watchButton.hidden = NO;
                }
                
                CGFloat height = [self.forumView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                CGRect headerFrame = self.forumView.frame;
                headerFrame.size.height = height;
                self.forumView.frame = headerFrame;
                self.tableView.tableHeaderView = self.forumView;
                
                if (topicList.forumInfo.deleteable) {
                    self.deleteForumButton.hidden = NO;
                } else {
                    self.deleteForumButton.hidden = YES;
                }
                
                if (topicList.limit > topicList.topicItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (self.loadingStatus == LoadingStatusLoadingWithLoadingView
                    || self.loadingStatus == LoadingStatusLoadingWithRefreshView
                    || self.loadingStatus == LoadingStatusLoadingWithToastActivity)
                {
                    [_listItems removeAllObjects];
                }
                
                for (TopicItem* item in topicList.topicItems) {
                    [_listItems addObject:item];
                }
                
                [self.tableView reloadData];
            } else {
                NSLog(@"%@", error);
            }
        } else {
            if (self.loadingStatus == LoadingStatusLoadingWithLoadingView) {
                [self showErrorViewWithMessage:errorMessage];
            } else {
                [self.view makeToast:errorMessage];
            }
        }
        
        [self removeLoadingViews];
    }];
}

- (IBAction)actionsButtonPressed:(id)sender {
    self.actionsStackView.hidden = !self.actionsStackView.hidden;
}

- (IBAction)deleteForumPressed:(id)sender {
    NSString* url = [NSString stringWithFormat:@"forum/%@", _forumInfo.id];
//    NSLog(@"%@", url);
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] deleteDataWithUrl:url data:nil completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (IBAction)watchButtonPressed:(id)sender {
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        [self.view makeToastActivity:CSToastPositionCenter];
        NSString* url = [NSString stringWithFormat:@"forum/%@/watch", _forumInfo.id];
        [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                [self loadWithToastActivity];
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
    }
}

- (IBAction)unwatchButtonPressed:(id)sender {
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        [self.view makeToastActivity:CSToastPositionCenter];
        NSString* url = [NSString stringWithFormat:@"forum/%@/unwatch", _forumInfo.id];
        [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                [self loadWithToastActivity];
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
    }
}

- (void)deleteTopicButtonPressed:(UIButton*)sender {
    long row = sender.tag;
    NSString* topicId = [_listItems objectAtIndex:row].id;
    NSString* url = [NSString stringWithFormat:@"topic/%@", topicId];
    NSLog(@"%@", url);
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] deleteDataWithUrl:url data:nil completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            [self loadWithToastActivity];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
    TopicItem* topic = _listItems[indexPath.row];
    
    if (cell.tasks != nil && cell.tasks.count > 0) {
        for (NSURLSessionTask* task in cell.tasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
    }
    
    if (cell.tasks == nil) {
        cell.tasks = [[NSMutableArray alloc] init];
    } else {
        [cell.tasks removeAllObjects];
    }
    
    cell.userPhotoImageView.layer.cornerRadius = cell.userPhotoImageView.frame.size.width / 2;
    cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
    if (topic.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.userPhotoImageView.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
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
    
    cell.deleteTopicButton.tag = indexPath.row;
    [cell.deleteTopicButton addTarget:self action:@selector(deleteTopicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (topic.deleteable) {
        cell.deleteTopicButton.hidden = NO;
    } else {
        cell.deleteTopicButton.hidden = YES;
    }
    
    cell.topicTitleLabel.text = topic.title;
    cell.topicStatisticsLabel.text = [NSString stringWithFormat:@"帖子:%d 浏览:%d", topic.posts, topic.views];
    cell.firstPostContentLabel.text = topic.firstPost.content;
    
    cell.firstPostImageView1.image = nil;
    cell.firstPostImageView2.image = nil;
    cell.firstPostImageView3.image = nil;
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 0) {
        cell.firstPostImageStackViewHeightConstraint.constant = (self.view.frame.size.width - 16 - 6) / 3;
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
    
//    [cell layoutSubviews];
    
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
    [self performSegueWithIdentifier:@"PushPosts" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushCreateTopic"]) {
        CreateTopicViewController* createTopicViewController = [segue destinationViewController];
        createTopicViewController.forumId = _forumInfo.id;
    } else if ([segue.identifier isEqualToString:@"PushPosts"]) {
        TopicPostsViewController* topicPostsViewController = [segue destinationViewController];
        TopicItem* topic = _listItems[self.tableView.indexPathForSelectedRow.row];
        topicPostsViewController.topicId = topic.id;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}


@end
