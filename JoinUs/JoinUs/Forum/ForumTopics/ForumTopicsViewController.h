//
//  ForumTopicsViewController.h
//  JoinUs
//
//  Created by Liang Qian on 12/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"

@interface ForumTopicsViewController : BaseListViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString* forumId;
@end
