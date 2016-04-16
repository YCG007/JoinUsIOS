//
//  NSString+Validation.m
//  JoinUs
//
//  Created by Liang Qian on 3/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

// 最常用的范围是 U+4E00～U+9FA5，即名为：CJK Unified Ideographs 的区块，
// 但 U+9FA6～U+9FFF 之间的字符还属于空码，
- (BOOL)isIncludeChineseInString:(NSString*)string
{
    for (int i=0; i<string.length; i++)
    {
        unichar ch = [string characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff)
        {
            return true;
        }
    }
    return false;
}

- (BOOL)validateNotEmpty
{
    return ([self length] != 0);
}

//--------------------------------------------------------------
- (BOOL)validateMinimumLength:(NSInteger)length
{
    return ([self length] >= length);
}

//--------------------------------------------------------------
- (BOOL)validateMaximumLength:(NSInteger)length
{
    return ([self length] <= length);
}

//--------------------------------------------------------------
- (BOOL)validateMatchesConfirmation:(NSString *)confirmation
{
    return [self isEqualToString:confirmation];
}

//--------------------------------------------------------------
- (BOOL)validateInCharacterSet:(NSMutableCharacterSet *)characterSet
{
    return ([self rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound);
}

//--------------------------------------------------------------
- (BOOL)validateAlpha
{
    return [self validateInCharacterSet:[NSMutableCharacterSet letterCharacterSet]];
}

//--------------------------------------------------------------
- (BOOL)validateAlphanumeric
{
    return [self validateInCharacterSet:[NSMutableCharacterSet alphanumericCharacterSet]];
}

//--------------------------------------------------------------
- (BOOL)validateNumeric
{
    return [self validateInCharacterSet:[NSMutableCharacterSet decimalDigitCharacterSet]];
}

//--------------------------------------------------------------
- (BOOL)validateAlphaSpace
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet letterCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------
- (BOOL)validateAlphanumericSpace
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------
// Alphanumeric characters, underscore (_), and period (.)
- (BOOL)validateUsername
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"'_."];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------
// http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
// http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
- (BOOL)validateEmail:(BOOL)stricterFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL) validateEmail2:(NSString*) emailAddress {
    
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc]
                                  initWithPattern:regExPattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailAddress
                                                     options:0
                                                       range:NSMakeRange(0, [emailAddress length])];
    return (regExMatches == 0) ? NO : YES ;
    
}

//--------------------------------------------------------------
- (BOOL)validatePhoneNumber
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [characterSet addCharactersInString:@"'-*+#,;. "];
    return [self validateInCharacterSet:characterSet];
}
@end
