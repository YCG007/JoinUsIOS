//
//  ViewingImage.m
//  JoinUs
//
//  Created by Liang Qian on 23/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ViewingImage.h"
#import "Utils.h"
#import "NetworkManager.h"

@implementation ViewingImage

- (UIImage *)image {
    
    NSData *data = [[NetworkManager sharedManager] getUploadImageSynchronouslyWithName:_imageName];
    
    if (data != nil) {
        return [UIImage imageWithData:data];
    }
    
    return [UIImage imageNamed:@"no_image"];
}

@end
