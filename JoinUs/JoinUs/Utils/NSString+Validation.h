//
//  NSString+Validation.h
//  JoinUs
//
//  Created by Liang Qian on 3/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)isIncludeChineseInString:(NSString*)string;
- (BOOL)validateNotEmpty;
- (BOOL)validateMinimumLength:(NSInteger)length;
- (BOOL)validateMaximumLength:(NSInteger)length;

- (BOOL)validateMatchesConfirmation:(NSString *)confirmation;
- (BOOL)validateInCharacterSet:(NSMutableCharacterSet *)characterSet;

- (BOOL)validateAlpha;
- (BOOL)validateAlphanumeric;
- (BOOL)validateNumeric;
- (BOOL)validateAlphaSpace;
- (BOOL)validateAlphanumericSpace;

- (BOOL)validateUsername;
- (BOOL)validateEmail:(BOOL)stricterFilter;
- (BOOL)validatePhoneNumber;
@end
