//
//  Student.h
//  JoinUs
//
//  Created by Liang Qian on 17/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "JSONModel.h"
#import "Team.h"

@interface Student : JSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* gender;
@property (nonatomic) NSInteger age;
@property (nonatomic) Team* team;
@end

@protocol Student
@end

@interface StudentList : JSONModel

@property (nonatomic) NSArray<Student>* list;
@property (nonatomic) NSInteger count;

@end
