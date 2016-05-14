//
//  ForumSearchItemTableViewCell.h
//  JoinUs
//
//  Created by Liang Qian on 9/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumSearchItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) NSURLSessionDataTask* task;
@end
