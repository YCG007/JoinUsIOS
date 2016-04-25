//
//  ForumModels.h
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "JSONModel.h"
#import "Models.h"
#import <UIKit/UIKit.h>

@interface Category : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString<Ignore>* selected;
@end

@protocol Category
@end

@interface CategoryList : JSONModel
@property (nonatomic) NSArray<Category>* categories;
@end

@interface ForumAdd : JSONModel
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* desc;
@property (nonatomic) NSString* iconImageId;
@property (nonatomic) NSArray<NSNumber*>* categoryIds;
@property (nonatomic) UIImage<Ignore>* iconImage;
@end

@interface ForumItem : JSONModel
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* desc;
@property (nonatomic) NSString* icon;
@property (nonatomic) int posts;
@property (nonatomic) int watch;
@end

@protocol ForumItem
@end

@interface ForumListLimited : JSONModel
@property (nonatomic) NSArray<ForumItem>* forumItems;
@property (nonatomic) int offset;
@property (nonatomic) int limit;
@end
