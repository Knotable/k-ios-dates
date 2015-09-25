//
//  NSString+Knotable.m
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import "NSString+Knotes.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Knotable)

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

- (NSString *)trimmed {
    if (self == (id)[NSNull null] || ![self isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)startsWith:(NSString *)string
{
    NSRange r = [self rangeOfString:string];
    return r.location == 0 && r.length > 0;
}

-(BOOL)isValidURL
{
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    
    NSRange urlStringRange = NSMakeRange(0, [self length]);
    NSMatchingOptions matchingOptions = 0;
    
    if (1 != [linkDetector numberOfMatchesInString:self options:matchingOptions range:urlStringRange])
    {
        return NO;
    }
    
    NSTextCheckingResult *checkingResult = [linkDetector firstMatchInString:self options:matchingOptions range:urlStringRange];
    
    return checkingResult.resultType == NSTextCheckingTypeLink && NSEqualRanges(checkingResult.range, urlStringRange);
}

-(BOOL)isPhoneNumber
{
    id phoneLinkDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    
    NSUInteger numberOfPhoneLink = [phoneLinkDetector numberOfMatchesInString:self
                                                                      options:0
                                                                        range:NSMakeRange(0, self.length)];
    
    return (numberOfPhoneLink == 1);
}

- (BOOL)isValidEmail
{
    NSError *error = nil;
    NSString *pattern = @"^[a-zA-Z0-9\\._\\-\\+]+@[a-zA-Z0-9\\.\\-]+\\.[a-zA-Z]{2,6}$";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    NSUInteger matchCount = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if(error){
        NSLog(@"REGEX Error: %@", error);
    }
    return matchCount == 1;
}

- (NSString *)noPrefix:(NSString *)prefix
{
    NSString *new_str = @"";
    if ([self hasPrefix:prefix]) {
        new_str = [self substringFromIndex:[prefix length]];
    } else {
        new_str = self;
    }
    return new_str;
}


#pragma mark - Trimming

- (NSString *)stringByTrimmingLeadingAndTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    return [[self stringByTrimmingLeadingCharactersInSet:characterSet]
            stringByTrimmingTrailingCharactersInSet:characterSet];
}


- (NSString *)stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters {
    return [[self stringByTrimmingLeadingWhitespaceAndNewlineCharacters]
            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
}


- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}


- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location + 1]; // Non-inclusive
}


- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


#pragma mark - Knotable Title and Contents
/// Chunji added 20150916
- (NSString*) trimHtmlSpace
{
    NSString* netString = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* htmlSpace = @"&nbsp;";
    NSInteger spaceLen = htmlSpace.length;
    
    while ([netString hasPrefix:htmlSpace])
    {
        netString = [netString substringFromIndex: spaceLen];
        netString = [netString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    while ([netString hasSuffix:htmlSpace])
    {
        netString = [netString substringToIndex: netString.length - spaceLen];
        netString = [netString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return netString;
}

- (NSArray*) knotableTitleAndContent
{
    NSString* htmlText = self;
    NSString* parTag = @"<p>";
    NSString* divTag = @"<div>";
    NSString* lessMark = @"<";
    NSString* title = [NSString string];
    NSString* body = [NSString string];
    
    htmlText = [htmlText trimHtmlSpace];
    
    if ([htmlText hasPrefix: lessMark])
    {
        if ([htmlText hasPrefix: parTag])
        {
            NSInteger startLocation = parTag.length;
            NSRange endRange = [htmlText rangeOfString: @"</p>"];
            title = [htmlText substringWithRange: NSMakeRange(startLocation, endRange.location - startLocation)];
            body = [htmlText substringFromIndex: NSMaxRange(endRange)];
            
            title = [title trimHtmlSpace];
            title = [NSString stringWithFormat: @"<p>%@</p>", title];
        }
        else if ([htmlText hasPrefix: divTag])
        {
            NSInteger startLocation = divTag.length;
            NSRange endRange = [htmlText rangeOfString: @"</div>"];
            title = [htmlText substringWithRange: NSMakeRange(startLocation, endRange.location - startLocation)];
            body = [htmlText substringFromIndex: NSMaxRange(endRange)];
            title = [title trimHtmlSpace];
            title = [NSString stringWithFormat: @"<div>%@</div>", title];
        }
        else
        {// start with "<" but not tag for title, so it is body
            body = htmlText;
        }
        body = [body trimHtmlSpace];
    }
    else // not start "<"
    {
        NSRange endRange = [htmlText rangeOfString: lessMark];
        if (endRange.location == NSNotFound) // not contain html tag
        {
            NSArray* lines = [htmlText componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
            title = lines[0];
            if (title.length > 140)
                title = [title substringToIndex: 140];
            
            if (htmlText.length > title.length)
                body = [htmlText substringFromIndex: title.length];
        }
        else
        {
            title = [htmlText substringToIndex:endRange.location];
            body = [htmlText substringFromIndex: endRange.location];
        }
        title = [title trimHtmlSpace];
        body = [body trimHtmlSpace];

    }
    
    return @[title, body];
}

- (NSString*) planTitle
{
    NSString* title = self;
    NSString* parTag = @"<p>";
    NSString* divTag = @"<div>";
    
    if ([title hasPrefix: parTag])
    {
        NSInteger startLocation = parTag.length;
        NSRange endRange = [title rangeOfString: @"</p>"];
        title = [title substringWithRange: NSMakeRange(startLocation, endRange.location - startLocation)];
    }
    else if ([title hasPrefix: divTag])
    {
        NSInteger startLocation = divTag.length;
        NSRange endRange = [title rangeOfString: @"</div>"];
        title = [title substringWithRange: NSMakeRange(startLocation, endRange.location - startLocation)];
    }
    
    title = [title stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    title = [title stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return title;
}

@end
