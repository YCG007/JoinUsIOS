//
//  TopicsViewController.h
//  JoinUs
//
//  Created by Liang Qian on 26/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"

@interface TopicsViewController : BaseListViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString* forumId;
@end
