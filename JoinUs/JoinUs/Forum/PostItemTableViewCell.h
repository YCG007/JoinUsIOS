//
//  PostItemTableViewCell.h
//  JoinUs
//
//  Created by Liang Qian on 18/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImageView;

@property (weak, nonatomic) IBOutlet UILabel *userLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIStackView *imagesStackView;

@property (nonatomic) NSMutableArray<NSURLSessionDataTask*>* tasks;

@end
