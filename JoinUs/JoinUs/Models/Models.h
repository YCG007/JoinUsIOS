//
//  Models.h
//  JoinUs
//
//  Created by Liang Qian on 21/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "JSONModel.h"

@interface Message : JSONModel
@property (nonatomic) NSString* message;
@end

@interface Gender : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@end

@interface Role : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@end

@interface Country : JSONModel
@property (nonatomic) NSString* id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* code;
@end

@interface Province : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@end

@interface City : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@property (nonatomic) Province* province;
@end

@interface CityItem : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@end

@protocol CityItem
@end

@interface ProvinceItem : JSONModel
@property (nonatomic) int id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSArray<CityItem>* cityItems;

@end

@protocol ProvinceItem
@end

@interface ProvinceList : JSONModel
@property (nonatomic) NSArray<ProvinceItem>* provinceItems;
@end

@interface UploadImage : JSONModel
@property (nonatomic) NSString* imageId;
@property (nonatomic) NSString* name;
@end



