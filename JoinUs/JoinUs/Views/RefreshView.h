//
//  RefreshView.h
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
static const float kRefreshViewHeight = 120.0f;

@interface RefreshView : UIView

- (void)setVisibleHeight:(float)visibleHeight;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)reset;

@end
