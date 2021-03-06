//
//  BaseListViewController.h
//  JoinUs
//
//  Created by Liang Qian on 26/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RefreshView;

typedef enum : NSUInteger {
    LoadingStatusLoadingWithLoadingView,
    LoadingStatusLoadingWithRefreshView,
    LoadingStatusLoadingWithToastActivity,
    LoadingStatusLoadingMore,
    LoadingStatusIdle
} LoadingStatus;

@interface BaseListViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) LoadingStatus loadingStatus;
@property (nonatomic) RefreshView* refreshView;
@property (nonatomic) UIView* loadingView;
@property (nonatomic) UIView* errorView;
@property (nonatomic) UIView* loginView;
@property (nonatomic) BOOL noMoreData;

- (UITableView*)tableView;

- (void)addRefreshViewAndLoadMoreView;
- (void)loadData;
- (void)loadWithLoadingView;
- (void)loadWithRefreshView;
- (void)loadWithToastActivity;
- (void)loadMore;
- (void)removeLoadingViews;
- (void)stopLoadMoreAnimation;
- (void)startLoadMoreAnimation;
- (void)showLoadingView;
- (void)showErrorViewWithMessage:(NSString*)message;
- (void)errorReload;
- (void)showLoginView;
- (void)presentLoginTapped;
- (void)removeLoginView;
@end
