//
//  TopicPostsViewController.h
//  JoinUs
//
//  Created by Liang Qian on 18/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"
#import "NYTPhotosViewController.h"

@interface TopicPostsViewController : BaseListViewController <NYTPhotosViewControllerDelegate>

@property NSString* topicId;

@end
