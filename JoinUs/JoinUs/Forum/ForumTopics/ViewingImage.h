//
//  ViewingImage.h
//  JoinUs
//
//  Created by Liang Qian on 23/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhoto.h"

@interface ViewingImage : NSObject<NYTPhoto>

@property (nonatomic) NSString* imageName;

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
