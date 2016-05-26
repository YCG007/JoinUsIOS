//
//  TopicPostsViewController.h
//  JoinUs
//
//  Created by Liang Qian on 18/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"
#import "NYTPhotosViewController.h"
#import "CTAssetsPickerController.h"

@interface TopicPostsViewController : BaseListViewController <NYTPhotosViewControllerDelegate, UITextViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, CTAssetsPickerControllerDelegate>

@property NSString* topicId;

@end
