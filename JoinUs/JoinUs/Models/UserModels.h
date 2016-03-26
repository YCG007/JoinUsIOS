//
//  UserModels.h
//  JoinUs
//
//  Created by Liang Qian on 26/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "JSONModel.h"

@interface MobileVerifyCode : JSONModel

@property (nonatomic) NSString* mobile;
@property (nonatomic) NSString* verifyCode;

@end
