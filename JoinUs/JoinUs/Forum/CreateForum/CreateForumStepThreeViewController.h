//
//  CreateForumStepThreeViewController.h
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumModels.h"

@interface CreateForumStepThreeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) ForumAdd* forumAdd;
@end
