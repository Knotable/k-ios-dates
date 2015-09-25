//
//  NSString+MailExtensions.m
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "NSString+MailExtensions.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (MailExtensions)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG) strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

- (NSArray *) words
{
    NSCharacterSet *charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    //NSMutableCharacterSet *charset = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    //[charset formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    return [self componentsSeparatedByCharactersInSet:charset];
}

- (NSUInteger) wordCount {
    return self.words.count;
}

- (NSUInteger) characterCount {
    NSUInteger count = 0;
    for (NSString *word in self.words)
        count += word.length;
    return count;
}

- (TextCount) characterAndWordCounts
{
    NSArray* words = self.words;
    NSUInteger characterCount = 0;
    for (NSString *word in words)
        characterCount += word.length;
    TextCount tc = {characterCount,words.count};
    return tc;
}


@end
