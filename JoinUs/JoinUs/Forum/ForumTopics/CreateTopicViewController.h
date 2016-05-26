//
//  CreateTopicViewController.h
//  JoinUs
//
//  Created by Liang Qian on 15/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAssetsPickerController.h"

@interface CreateTopicViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate, CTAssetsPickerControllerDelegate>

@property (nonatomic) NSString* forumId;

@end
