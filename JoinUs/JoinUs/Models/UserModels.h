//
//  UserModels.h
//  JoinUs
//
//  Created by Liang Qian on 26/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "JSONModel.h"
#import "Models.h"

@interface MobileVerifyCode : JSONModel

@property (nonatomic) NSString* mobile;
@property (nonatomic) NSString* verifyCode;

@end

@interface MobilePassword : JSONModel

@property (nonatomic) NSString* mobile;
@property (nonatomic) NSString* password;

@end

@protocol Role
@end

@interface UserProfile : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* mobile;
@property (nonatomic) NSString<Optional>* email;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString<Optional>* photo;
@property (nonatomic) Gender* gender;
@property (nonatomic) Role* role;
@property (nonatomic) City<Optional>* city;
@property (nonatomic) NSDate* lastUpdateDate;
@property (nonatomic) NSDate* registerDate;

@end

@interface UserToken : JSONModel
@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* securityToken;
@property (nonatomic) NSDate* experiationDate;
@end

@interface UserProfileWithToken : JSONModel
@property (nonatomic) UserProfile* userProfile;
@property (nonatomic) UserToken* userToken;
@end

@interface UserPassword : JSONModel
@property (nonatomic) NSString* currentPassword;
@property (nonatomic) NSString* password;
@end

@interface UserName : JSONModel
@property (nonatomic) NSString* name;
@end



