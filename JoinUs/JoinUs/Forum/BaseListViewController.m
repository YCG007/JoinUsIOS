//
//  BaseListViewController.m
//  JoinUs
//
//  Created by Liang Qian on 26/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "RefreshView.h"

@interface BaseListViewController ()

@end

@implementation BaseListViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITableView*)tableView {
    [NSException raise:@"Wo KAO!" format:@"You must override this method!"];
    return nil;
}

- (void)addLoadingViews{
    _refreshView = [[RefreshView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight, self.view.frame.size.width, kRefreshViewHeight)];
    [self.tableView insertSubview:_refreshView atIndex:0];
    
    UIView* refreshViewCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    refreshViewCover.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView insertSubview:refreshViewCover atIndex:1];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
}

- (void)loadData {
    [NSException raise:@"Wo KAO!" format:@"You must override this method!"];
}

- (void)startupLoad {
    _loadingStatus = LoadingStatusStartupLoading;
    [self loadData];
}

- (void)loadMore {
    _loadingStatus = LoadingStatusLoadingMore;
    [self loadData];
}

- (void)reloadData {
    _loadingStatus = LoadingStatusReloading;
    [self loadData];
}


- (void)removeLoadingViews {
    if (_loadingStatus == LoadingStatusStartupLoading) {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }
        if (_errorView) {
            [_errorView removeFromSuperview];
        }
    } else if (_loadingStatus == LoadingStatusReloading) {
        [_refreshView endRefreshing];
        [UIView animateWithDuration:1.0f animations:^{
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.top -= kRefreshViewHeight;
            self.tableView.contentInset = insets;
        } completion:^(BOOL finished) {
            [_refreshView reset];
        }];
    } else if (_loadingStatus == LoadingStatusLoadingMore) {
        [self stopLoadMoreAnimation];
    } else {
        NSLog(@"Wo KAO!");
    }
    _loadingStatus = LoadingStatusIdle;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_refreshView setVisibleHeight:-(scrollView.contentOffset.y + scrollView.contentInset.top)];
    
    float maximumOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
    NSLog(@"content offset: %f / max: %f", self.tableView.contentOffset.y, maximumOffset);
    if (_loadingStatus == LoadingStatusIdle && !_noMoreData && (maximumOffset - self.tableView.contentOffset.y <= -2)) {
        [self startLoadMoreAnimation];
        [self loadMore];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"velocity: %f; offset:%f", velocity.y, targetContentOffset->y);
    if (_loadingStatus == LoadingStatusIdle && self.tableView.contentOffset.y < -kRefreshViewHeight - scrollView.contentInset.top) {
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top += kRefreshViewHeight;
        self.tableView.contentInset = insets;
        
        targetContentOffset->y = -kRefreshViewHeight - scrollView.contentInset.top;
        
        [_refreshView beginRefreshing];
        [_refreshView setVisibleHeight:kRefreshViewHeight];
        [self reloadData];
    }
}

#pragma mark - load more animation

- (void)stopLoadMoreAnimation {
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void)startLoadMoreAnimation {
    if (self.tableView.tableFooterView.subviews.count == 0 ) {
        int numberOfCircles = 5;
        float spacing = 5;
        float radius = 10;
        float width = radius * 2 * numberOfCircles + spacing * (numberOfCircles - 1);
        float firstX = (self.tableView.tableFooterView.frame.size.width - width) / 2;
        for (NSUInteger i = 0; i < numberOfCircles; i++) {
            UIColor *color = nil;
            CGFloat red   = (arc4random() % 256)/255.0;
            CGFloat green = (arc4random() % 256)/255.0;
            CGFloat blue  = (arc4random() % 256)/255.0;
            CGFloat alpha = 1.0f;
            color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            UIView *circle = [self createCircleWithRadius:10
                                                    color:color
                                                positionX:(firstX + i * ((2 * radius) + spacing))];
            [circle setTransform:CGAffineTransformMakeScale(0, 0)];
            [circle.layer addAnimation:[self createAnimationWithDuration:0.8 delay:(i * 0.2)] forKey:@"scale"];
            [self.tableView.tableFooterView addSubview:circle];
        }
    }
}

- (UIView *)createCircleWithRadius:(CGFloat)radius
                             color:(UIColor *)color
                         positionX:(CGFloat)x {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(x, 8, radius * 2, radius * 2)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.translatesAutoresizingMaskIntoConstraints = NO;
    return circle;
}

- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.delegate = self;
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

#pragma mark - init loading view

- (void)showLoadingView {
    _loadingView = [[UIView alloc] init];
    _loadingView.backgroundColor = [UIColor whiteColor];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_loadingView];
    
    [_loadingView.topAnchor constraintEqualToAnchor:_loadingView.superview.topAnchor].active = YES;
    [_loadingView.bottomAnchor constraintEqualToAnchor:_loadingView.superview.bottomAnchor].active = YES;
    [_loadingView.leadingAnchor constraintEqualToAnchor:_loadingView.superview.leadingAnchor].active = YES;
    [_loadingView.trailingAnchor constraintEqualToAnchor:_loadingView.superview.trailingAnchor].active = YES;
    
    //    UIImageView* loadingIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loading"]];
    //    loadingIconImage.translatesAutoresizingMaskIntoConstraints = NO;
    //    [loadingView addSubview:loadingIconImage];
    //    [loadingIconImage.centerXAnchor constraintEqualToAnchor:loadingView.centerXAnchor].active = YES;
    //    [loadingIconImage.centerYAnchor constraintEqualToAnchor:loadingView.centerYAnchor].active = YES;
    
    float radius = 30;
    
    UIView* circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    circleView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_loadingView addSubview:circleView];
    circleView.backgroundColor = [UIColor clearColor];
    [circleView.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor].active = YES;
    [circleView.centerYAnchor constraintEqualToAnchor:_loadingView.centerYAnchor].active = YES;
    [circleView.widthAnchor constraintEqualToConstant:radius * 2].active = YES;
    [circleView.heightAnchor constraintEqualToConstant:radius * 2].active = YES;
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:1.8 * M_PI clockwise:YES].CGPath;
    circleLayer.strokeColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0].CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.lineCap = kCALineCapRound;
    circleLayer.lineWidth = 3;
    circleLayer.frame = CGRectMake(0, 0, radius * 2, radius * 2);
    circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [circleLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [circleView.layer addSublayer:circleLayer];
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    titleLabel.text = @"正在加载";
    [_loadingView addSubview:titleLabel];
    [titleLabel.topAnchor constraintEqualToAnchor:circleView.bottomAnchor constant:8].active = YES;
    [titleLabel.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor].active = YES;
}

- (void)showErrorViewWithMessage:(NSString*)message {
    _errorView = [[UIView alloc] init];
    _errorView.backgroundColor = [UIColor whiteColor];
    _errorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_errorView];
    
    [_errorView.topAnchor constraintEqualToAnchor:_errorView.superview.topAnchor].active = YES;
    [_errorView.bottomAnchor constraintEqualToAnchor:_errorView.superview.bottomAnchor].active = YES;
    [_errorView.leadingAnchor constraintEqualToAnchor:_errorView.superview.leadingAnchor].active = YES;
    [_errorView.trailingAnchor constraintEqualToAnchor:_errorView.superview.trailingAnchor].active = YES;
    
    UIImageView* errorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_error"]];
    errorImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_errorView addSubview:errorImage];
    [errorImage.centerXAnchor constraintEqualToAnchor:_errorView.centerXAnchor].active = YES;
    [errorImage.centerYAnchor constraintEqualToAnchor:_errorView.centerYAnchor].active = YES;
    
    UILabel* errorMsgLabel = [[UILabel alloc] init];
    errorMsgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    errorMsgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    errorMsgLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    errorMsgLabel.text = message;
    [_errorView addSubview:errorMsgLabel];
    [errorMsgLabel.topAnchor constraintEqualToAnchor:errorImage.bottomAnchor constant:10].active = YES;
    [errorMsgLabel.centerXAnchor constraintEqualToAnchor:_errorView.centerXAnchor].active = YES;
    
    UILabel* promotingMsgLabel = [[UILabel alloc] init];
    promotingMsgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    promotingMsgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    promotingMsgLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    promotingMsgLabel.text = @"请稍后点击重试";
    [_errorView addSubview:promotingMsgLabel];
    [errorMsgLabel.topAnchor constraintEqualToAnchor:errorMsgLabel.bottomAnchor constant:10].active = YES;
    [errorMsgLabel.centerXAnchor constraintEqualToAnchor:_errorView.centerXAnchor].active = YES;
    
    UITapGestureRecognizer *errorReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorReload)];
    [_errorView addGestureRecognizer:errorReload];
}

- (void)errorReload {
    if (_loadingStatus == LoadingStatusIdle) {
        [_errorView removeFromSuperview];
        [self startupLoad];
    }
}

- (void)showLoginView {
    _loginView = [[UIView alloc] init];
    _loginView.backgroundColor = [UIColor whiteColor];
    _loginView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_loginView];
    
    [_loginView.topAnchor constraintEqualToAnchor:_loginView.superview.topAnchor].active = YES;
    [_loginView.bottomAnchor constraintEqualToAnchor:_loginView.superview.bottomAnchor].active = YES;
    [_loginView.leadingAnchor constraintEqualToAnchor:_loginView.superview.leadingAnchor].active = YES;
    [_loginView.trailingAnchor constraintEqualToAnchor:_loginView.superview.trailingAnchor].active = YES;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.textColor = [UIColor colorWithRed:0.129 green:0.455 blue:0.627 alpha:1.0];
    titleLabel.text = @"请点击登录后浏览";
    
    [_loginView addSubview:titleLabel];
    
    [titleLabel.centerXAnchor constraintEqualToAnchor:_loginView.centerXAnchor constant:0].active = YES;
    [titleLabel.centerYAnchor constraintEqualToAnchor:_loginView.centerYAnchor constant:0].active = YES;
    
    UITapGestureRecognizer *pushLoginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentLoginTapped)];
    [_loginView addGestureRecognizer:pushLoginTap];
}

- (void)presentLoginTapped {
    [NSException raise:@"Wo KAO!" format:@"You must override this method!"];
}

- (void)removeLoginView {
    if (_loginView != nil) {
        [_loginView removeFromSuperview];
        _loginView = nil;
    }
}

@end
