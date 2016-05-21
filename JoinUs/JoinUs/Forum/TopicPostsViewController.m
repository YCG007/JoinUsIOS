//
//  TopicPostsViewController.m
//  JoinUs
//
//  Created by Liang Qian on 18/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "TopicPostsViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "PostItemTableViewCell.h"

@interface TopicPostsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *topicView;
@property (weak, nonatomic) IBOutlet UILabel *topicTitleLabel;


@end

@implementation TopicPostsViewController {
    NSMutableArray<PostItem*>* _listItems;
    TopicInfo* _topicInfo;
    BOOL _isLoggedInLastLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
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
    NSString* url = [NSString stringWithFormat:@"topic/%@?offset=%d&limit=%d", self.topicId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            PostListLimited* postList = [[PostListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                _topicInfo = postList.topicInfo;
                self.topicTitleLabel.text = _topicInfo.title;
                
                CGFloat height = [self.topicView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                CGRect headerFrame = self.topicView.frame;
                headerFrame.size.height = height;
                self.topicView.frame = headerFrame;
                self.tableView.tableHeaderView = self.topicView;
                
//                if (postList.forumInfo.deleteable) {
//                    self.deleteForumButton.hidden = NO;
//                } else {
//                    self.deleteForumButton.hidden = YES;
//                }
                
                if (postList.limit > postList.postItems.count) {
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
                
                for (PostItem* item in postList.postItems) {
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
    PostItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PostItem* post = _listItems[indexPath.row];
    
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
    if (post.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:post.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.userPhotoImageView.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    cell.userNameLabel.text = post.postedBy.name;
    if (post.postedBy.gender.id == 2) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
    } else if (post.postedBy.gender.id == 3) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
    }
    cell.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d ", post.postedBy.level];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.postDateLabel.text = [dateFormatter stringFromDate:post.postDate];
    
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (post.deleteable) {
        cell.deleteButton.hidden = NO;
    } else {
        cell.deleteButton.hidden = YES;
    }

    cell.contentLabel.text = post.content;
    
    [cell.imagesStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [cell.imagesStackView removeArrangedSubview:obj];
        [obj removeFromSuperview];
    }];
    
    if (post.imageItems != nil && post.imageItems.count > 0) {
        float width = self.view.frame.size.width - 16;
        for (ImageItem* image in post.imageItems) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_image"]];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [imageView.widthAnchor constraintEqualToConstant:width].active = YES;
            NSLayoutConstraint* constraint = [imageView.heightAnchor constraintEqualToConstant:width * image.height / image.width];
            constraint.priority = 999;
            constraint.active = YES;
            imageView.clipsToBounds = YES;
            [cell.imagesStackView addArrangedSubview:imageView];
            
            NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:image.name width:width * UIScreen.mainScreen.scale completionHandler:^(long statusCode, NSData *data) {
                if (statusCode == 200) {
                    imageView.image = [UIImage imageWithData:data];
                }
            }];
            [cell.tasks addObject:task];
        }
    }
    
    return cell;
}

- (void)deleteButtonPressed:(UIButton*)sender {
    long row = sender.tag;
    NSString* postId = [_listItems objectAtIndex:row].id;
    NSString* url = [NSString stringWithFormat:@"post/%@", postId];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushCreateTopic"]) {
//        CreateTopicViewController* createTopicViewController = [segue destinationViewController];
//        createTopicViewController.forumId = _forumInfo.id;
    }
}

@end
