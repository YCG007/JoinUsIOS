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

@interface ImageItem : JSONModel
@property (nonatomic) NSString* name;
@property (nonatomic) int width;
@property (nonatomic) int height;
@end

@interface ForumUserInfo : JSONModel
@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString<Optional>* photo;
@property (nonatomic) Gender* gender;
@property (nonatomic) NSDate* registerDate;
@property (nonatomic) int level;
@property (nonatomic) int posts;
@property (nonatomic) BOOL isAdmin;
@property (nonatomic) NSDate<Optional>* joinDate;
@property (nonatomic) NSDate<Optional>* lastPostDate;
@end

@interface PostAdd : JSONModel
@property (nonatomic) NSString* topicId;
@property (nonatomic) NSString* content;
@property (nonatomic) NSArray<NSString*>* imageIds;
@end

@protocol ImageItem
@end

@interface PostItem : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) ForumUserInfo* postedBy;
@property (nonatomic) NSString* content;
@property (nonatomic) NSDate* postDate;
@property (nonatomic) NSArray<ImageItem>* imageItems;
@property (nonatomic) BOOL deleteable;
@end

@interface PostInfo : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) ForumUserInfo* postedBy;
@property (nonatomic) NSString* content;
@property (nonatomic) NSDate* postDate;
@property (nonatomic) NSArray<NSString*>* images;
@end

@interface TopicAdd : JSONModel
@property (nonatomic) NSString* forumId;
@property (nonatomic) NSString* title;
@property (nonatomic) PostAdd* firstPost;
@end

@interface TopicItem : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* title;
@property (nonatomic) ForumUserInfo* postedBy;
@property (nonatomic) int posts;
@property (nonatomic) int views;
@property (nonatomic) PostInfo* firstPost;
@property (nonatomic) NSDate* firstPostDate;
@property (nonatomic) PostInfo* lastPost;
@property (nonatomic) NSDate* lastPostDate;
@property (nonatomic) BOOL onTop;
@property (nonatomic) BOOL deleteable;
@end

@interface TopicInfo : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* title;
@property (nonatomic) ForumUserInfo* postedBy;
@property (nonatomic) int posts;
@property (nonatomic) int views;
@end

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
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* desc;
@property (nonatomic) NSString* icon;
@property (nonatomic) int posts;
@property (nonatomic) int watch;
@end

@interface ForumInfo : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* desc;
@property (nonatomic) NSString* icon;
@property (nonatomic) int posts;
@property (nonatomic) int watch;
@property (nonatomic) int activity;
@property (nonatomic) ForumUserInfo* createdBy;
@property (nonatomic) NSDate* createDate;
@property (nonatomic) ForumUserInfo<Optional>* watchedByMe;
@property (nonatomic) BOOL deleteable;
@end

@protocol PostItem
@end

@interface PostListLimited : JSONModel
@property (nonatomic) TopicInfo* topicInfo;
@property (nonatomic) NSArray<PostItem>* postItems;
@property (nonatomic) int offset;
@property (nonatomic) int limit;
@end

@protocol TopicItem
@end

@interface TopicListLimited : JSONModel
@property (nonatomic) ForumInfo* forumInfo;
@property (nonatomic) NSArray<TopicItem>* topicItems;
@property (nonatomic) int offset;
@property (nonatomic) int limit;
@end

@protocol ForumItem
@end

@interface ForumListLimited : JSONModel
@property (nonatomic) NSArray<ForumItem>* forumItems;
@property (nonatomic) int offset;
@property (nonatomic) int limit;
@end






