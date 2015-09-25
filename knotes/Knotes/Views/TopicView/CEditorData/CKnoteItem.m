//
//  CKeyNoteItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CKnoteItem.h"
#import "ThreadConst.h"
#import "FileInfo.h"
#import "DesignManager.h"
#import "TextUtil.h"
#import "CEditBaseItemView.h"
#import "KnoteTextView.h"

#define kNoteMaxLine                        15

@implementation CKnoteItem

@synthesize height = _height;

- (id)initWithMessage:(MessageEntity *)message
{
    self = [super init];
    if (self) {
        [self setCommonValueByMessage:message];
    }
    return self;
}

- (void)setCommonValueByMessage:(MessageEntity *)message
{
    [super setCommonValueByMessage:message];
    [self updateAttributedString];
}

- (void)updateAttributedString
{
    if (!self.userData) {
        _attributedString = [[NSAttributedString alloc] initWithString:@""];
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedTextProperties = @{
                                  NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0],
                                  NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                  NSBackgroundColorAttributeName:[UIColor clearColor],
                                  NSParagraphStyleAttributeName:[paragraphStyle copy]
                                  };

    NSString *text = self.userData.body;//self.title;
    
    if(!text)
    {
        text = @"";
    }
#if true
    if (!self.userData.documentHTML)
    {
        self.userData.documentHTML=@"";
    }
    NSMutableAttributedString *changable=[[NSMutableAttributedString alloc] initWithData:[self.userData.documentHTML dataUsingEncoding:NSUTF8StringEncoding]
                                                                          options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                               documentAttributes:&attributedTextProperties error:nil];
    [changable setAttributes:attributedTextProperties range:NSMakeRange(0, [changable length])];
    [changable addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0] range:NSMakeRange(0, [changable length])];
    changable= [[self attributedStringByTrimmingWhitespaceForString:changable] mutableCopy];

    _attributedString = [changable mutableCopy];
#else
    _attributedString =[[NSAttributedString alloc] initWithString:text attributes:attributedTextProperties];
#endif
#if NEW_FEATURE
    
    CGFloat max_width = kNoteMaxWidth;
    
    CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:_attributedString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
    
    CGSize moreInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:_attributedString withWidth:max_width];
    NSInteger   postImageCount = [[self files] count];
    NSInteger   embedImageCount = [[self.userData loadedEmbeddedImages] count];
    
    NSInteger   totalImageCount = postImageCount + embedImageCount;
    if ((moreInformationTextViewSize.height > lessInformationTextViewSize.height) || totalImageCount>4)
    {
        self.needShowMoreButton = YES;
       /* NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;*/
        
        text = [text stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
        text = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@"  "];
        
        //paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

#if NEW_DESIGN
        NSAttributedString* dotString = [[NSAttributedString alloc] initWithString:@" Continue reading..." attributes:@{NSAttachmentAttributeName : @"more",NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
#else
        NSAttributedString* dotString = [[NSAttributedString alloc] initWithString:@"..." attributes:@{NSAttachmentAttributeName : @"more"}];
#endif
        
        NSMutableAttributedString *mattString = nil;
        
        mattString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributedTextProperties];
        [mattString appendAttributedString:dotString];
        
        CGSize moreInformationTextViewSize1 = [[TextUtil sharedInstance] getTextViewSize:mattString withWidth:max_width];
        CGSize lessInformationTextViewSize1 = [[TextUtil sharedInstance] getTextViewSize:mattString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
        
        if (moreInformationTextViewSize1.height > lessInformationTextViewSize1.height)
        {
            self.needShowMoreButton = YES;
            CGFloat maxLen = klessInformationTextViewTextLength > text.length ? text.length : klessInformationTextViewTextLength;
            
            NSRange range = NSMakeRange(0, maxLen);
            text = [text substringWithRange:range];
            
            mattString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributedTextProperties];
            [mattString appendAttributedString:dotString];
            self.lessAttString = [mattString copy];
        } else {
            self.lessAttString = [mattString copy];
        }
    }
    else
    {
        self.lessAttString=[[NSMutableAttributedString alloc] initWithString:text attributes:attributedTextProperties];
#if true
        NSMutableAttributedString *changable=[[NSMutableAttributedString alloc] initWithData:[self.userData.documentHTML dataUsingEncoding:NSUTF8StringEncoding]
                                                                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                          documentAttributes:&attributedTextProperties error:nil];
        [changable setAttributes:attributedTextProperties range:NSMakeRange(0, [changable length])];
        [changable addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0] range:NSMakeRange(0, [changable length])];

changable= [[self attributedStringByTrimmingWhitespaceForString:changable] mutableCopy];
        _attributedString = [changable mutableCopy];
#else
       _attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributedTextProperties];
#endif
      
        
    }
#endif
    self.lessAttString=[self.lessAttString mutableCopy];
    [self.lessAttString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0] range:NSMakeRange(0, [self.lessAttString length])];
    
}
- (NSAttributedString *)attributedStringByTrimmingCharactersInSet:(NSCharacterSet *)set ForString:(NSMutableAttributedString *)newStr
{
    //NSMutableAttributedString *newStr = [self mutableCopy] ;
    NSRange range;
    
    // First clear any characters from the set from the
    //beginning of the string
    range = [[newStr string]
             rangeOfCharacterFromSet:set];
    while (range.length != 0 && range.location == 0)
    {
        [newStr replaceCharactersInRange:range
                              withString:@""];
        range = [[newStr string]
                 rangeOfCharacterFromSet:set];
    }
    
    // Then clear them from the end
    range = [[newStr string] rangeOfCharacterFromSet:set
                                             options:NSBackwardsSearch];
    while (range.length != 0 && NSMaxRange(range) ==
           [newStr length])
    {
        [newStr replaceCharactersInRange:range
                              withString:@""];
        range = [[newStr string] rangeOfCharacterFromSet:set
                                                 options:NSBackwardsSearch];
    }
    if (newStr ==nil)
    {
        newStr=[[NSMutableAttributedString alloc]initWithString:@""];
    }
    return [[NSAttributedString alloc]
             initWithAttributedString:newStr] ;
}
- (NSAttributedString *)attributedStringByTrimmingWhitespaceForString:(NSMutableAttributedString *)newStr
{
    return [self
            attributedStringByTrimmingCharactersInSet:[NSCharacterSet
                                                       newlineCharacterSet] ForString:newStr];
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [super dictionaryValue];
    
    NSString *htmlBody = [self.userData convertedHTMLBody];

    dict[@"body"] = htmlBody;
    dict[@"htmlBody"] =  htmlBody;
    NSArray * array = [self.userData.usertags componentsSeparatedByString:@","];
    if (array && array.count>0) {
        dict[@"usertags"] = array;
    }
    if (self.title.length>0) {
        dict[@"title"] = self.title;
    }

    dict[@"cname"] = @"knotes";
    dict[@"type"] = @"knote";
    NSMutableArray *file_ids = [[NSMutableArray alloc] initWithCapacity:3];
    
    NSLog(@"self.files: %@", self.files);
    
    for (int i = 0 ; i<[self.files count]; i++)
    {
        FileInfo *fInfo = [self.files objectAtIndex:i];
        
        if (![fInfo.imageId hasPrefix:kKnoteIdPrefix])
        {
            [file_ids addObject:fInfo.imageId];
        }
    }
    
    dict[@"file_ids"] = [file_ids copy];
    
    return dict;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.type = C_KNOTE;
    }
    
    return self;
}

-(int) getHeight
{
    return 0;
}

#if NEW_FEATURE
-(void)setExpandedMode:(BOOL)expandedMode
{
    [super setExpandedMode:YES];
}
#endif
#if !NEW_DESIGN
-(int) getCellHeight
{

    _height = 0;
    
    if (self.userData)
    {
#if NEW_FEATURE
        if (!self.userData.expanded) {
            if ([self.attributedString length]>0) {
                CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:kNoteMaxWidth andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
            if (lessInformationTextViewSize.height<32) {
                _height = 32;
            } else {
                _height = lessInformationTextViewSize.height;
            }
        } else {
            _height = 32;
        }
            BOOL hasLikesToShow = (self.likesId.count > 0);
            
            if (hasLikesToShow)
            {
                _height += 32;
            }
            if (self.userData.replys) {
                _height+=22;
            }
            if (self.userData.title && self.userData.title.length>0) {
                _height += [CUtil getTextRect:self.userData.title Font:[UIFont boldSystemFontOfSize:15] Width:CGRectGetWidth([UIScreen mainScreen].bounds) - kTheadLeftGap - 12].size.height;
            }

            if (_height<50) {
                _height = 50;
            }
            return _height;
        }
#endif
        BOOL notEmptyText = (self.attributedString.string.length);
        
        if (notEmptyText)
        {
            CGFloat max_width = kNoteMaxWidth;
            
            CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
            
            CGSize moreInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width];
            NSInteger   totalImageCount = 0;
#if NEW_FEATURE
            NSInteger   postImageCount = [[self files] count];
            NSInteger   embedImageCount = [[self.userData loadedEmbeddedImages] count];
            
            totalImageCount = postImageCount + embedImageCount;
#endif
            
            if (moreInformationTextViewSize.height > lessInformationTextViewSize.height || totalImageCount>4)
            {
                self.needShowMoreButton = YES;
#if NEW_FEATURE
#else
                NSString *str = self.userData.title;
                
                if(!str)
                {
                    str = @"";
                }
                
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

                NSMutableAttributedString * oriMattString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{
                                                                                                                               NSFontAttributeName:[DesignManager knoteBodyFont],
                                                                                                                               NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                                                                                                               NSBackgroundColorAttributeName:[UIColor clearColor],
                                                                                                                               NSParagraphStyleAttributeName:[paragraphStyle copy]
                                                                                                                               }];
                [oriMattString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  。。。  " attributes:@{NSLinkAttributeName : @"more"}]];
#if 0
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:@"eye-closed-gray-80@2x.png"];
                NSLog(@"here is the scale: %f", textAttachment.image.scale);
                NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [oriMattString appendAttributedString:attrStringWithImage];
#endif
                self.attributedString = [oriMattString copy];

                
                str = [str stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];
                str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
                str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                NSError *error = nil;
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
                str = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"  "];
                
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributedTextProperties = @{
                                                           NSFontAttributeName:[DesignManager knoteBodyFont],
                                                           NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                                           NSBackgroundColorAttributeName:[UIColor clearColor],
                                                           NSParagraphStyleAttributeName:[paragraphStyle copy]
                                                           };
                NSDictionary* attrtes = @{NSLinkAttributeName : @"more"};

                NSAttributedString* dotString = [[NSAttributedString alloc] initWithString:@" ..." attributes:attrtes];
#if 0
                NSTextAttachment *textAttachment1 = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:@"eye-closed-80@2x.png"];
                NSLog(@"here is the scale: %f", textAttachment.image.scale);
                NSAttributedString *dotString = [NSAttributedString attributedStringWithAttachment:textAttachment1];
//                [oriMattString appendAttributedString:attrStringWithImage]
#endif   
                NSMutableAttributedString *mattString = nil;
                
                mattString = [[NSMutableAttributedString alloc] initWithString:str attributes:attributedTextProperties];
                [mattString appendAttributedString:dotString];
                
                CGSize moreInformationTextViewSize1 = [[TextUtil sharedInstance] getTextViewSize:mattString withWidth:max_width];
                CGSize lessInformationTextViewSize1 = [[TextUtil sharedInstance] getTextViewSize:mattString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
                
                if (moreInformationTextViewSize1.height > lessInformationTextViewSize1.height)
                {
                    CGFloat maxLen = 108>str.length?str.length:108;
                    for (int i = maxLen; (i>(maxLen-10) && i>0); i--) {
                        NSString *space = [str substringWithRange:NSMakeRange(i-1, 1)];
                        if ([space isEqualToString:@" "] || [space isEqualToString:@"."] || [space isEqualToString:@"," ] || [space isEqualToString:@":"]) {
                            maxLen = i;
                            break;
                        }
                    }
                    
                    NSRange range = NSMakeRange(0, maxLen);
                    str = [str substringWithRange:range];
                    
                    mattString = [[NSMutableAttributedString alloc] initWithString:str attributes:attributedTextProperties];
                    [mattString appendAttributedString:dotString];
                    self.lessAttString = [mattString copy];
                } else {
                    self.lessAttString = [mattString copy];
                }
#endif
            }
            else
            {
                self.needShowMoreButton = NO;
            }
            
            if (self.expandedMode)
            {
                if (moreInformationTextViewSize.height<40) {
                    moreInformationTextViewSize.height = 40;
                }
                _height = moreInformationTextViewSize.height;
            }
            else
            {
                if (lessInformationTextViewSize.height<32) {
                    lessInformationTextViewSize.height = 32;
                }
                _height = lessInformationTextViewSize.height;
            }
        }
        else
        {
            _height = 32;
        }
        _height += 28;
        
        BOOL hasLikesToShow = (self.likesId.count > 0);
        
        if (hasLikesToShow)
        {
            _height += 32;
        }
        if (self.userData.title && self.userData.title.length>0) {
            _height += [CUtil getTextRect:self.userData.title Font:[UIFont boldSystemFontOfSize:15] Width:320].size.height;
        }
    }
    
    return _height;
}
#else
-(int) getCellHeight
{
    _height = 0;
    if (self.userData)
    {
        CreplyUtils *cre=[[CreplyUtils alloc]init];
        if (!self.userData.expanded)
        {
            if ([self.lessAttString length]>0)
            {
                CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.lessAttString withWidth:kNoteMaxWidth andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
                _height += lessInformationTextViewSize.height;
            }
            //For Comment Button
            _height +=[cre getSizeOfReplyView:self];
            _height+=[cre getHeightOfTitleInfo:self.userData];
            return _height;
        }
        else
        {
            {
                if ([self.attributedString length]>0)
                {
                    CGSize moreInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:kNoteMaxWidth];
                    _height += moreInformationTextViewSize.height;
                }
                
                //For Comment Button
                _height +=[cre getSizeOfReplyView:self];
                _height+=[cre getHeightOfTitleInfo:self.userData];
                return _height;
            }
        }
    }
    return _height;
}
#endif
- (int)getExpandedCellHeight
{
    _height = 0;
    
    if (self.userData) {
        
        BOOL notEmptyText = (self.attributedString.string.length);
        if (notEmptyText) {
            CGFloat max_width = kNoteMaxWidth;
            CGSize moreInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width];
            _height = moreInformationTextViewSize.height;
            _height += 50;
        }
    }
    
    BOOL hasLikesToShow = (self.likesId.count > 0);
    
    if (hasLikesToShow) {
        _height += 25;
    }
    
    return _height;
}

- (int)getExpandedCellTextViewHeight {
    int textViewHeight = 0;
    
    if (self.userData) {
        BOOL notEmptyText = (self.attributedString.string.length);
        if (notEmptyText) {
            CGFloat max_width = kNoteMaxWidth;
            CGSize moreInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width];
            textViewHeight = moreInformationTextViewSize.height;
        }
    }
#if !NEW_DESIGN
    if (textViewHeight<=1) {
        textViewHeight = 32;
    }
#endif

    return textViewHeight;
}

- (int)getNotExpandedCellTextViewHeight {
    int textViewHeight = 0;
    
    if (self.userData) {
        BOOL notEmptyText = (self.lessAttString.string.length);
        if (notEmptyText) {
            CGFloat max_width = kNoteMaxWidth;
            CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.lessAttString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
            textViewHeight = lessInformationTextViewSize.height;
        } else {
            if (self.attributedString.string.length>0)
            {
                CGFloat max_width = kNoteMaxWidth;
                CGSize lessInformationTextViewSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width andMaximumNumberOfLines:self.maximumNumberOfLinesInNotExpandedMode];
                textViewHeight = lessInformationTextViewSize.height;
            }
        }
    }
    
#if !NEW_DESIGN
    if (textViewHeight<=1) {
        textViewHeight = 32;
    }
#endif

    return textViewHeight;
}

- (void) reCalHeight
{
    NSLog(@"old height: %f", _height);
    
    [self getCellHeight];
    
    NSLog(@"new height: %f", _height);

}

-(BOOL) shouldShowHeader
{
#if NEW_DESIGN
    return YES;
#else
    return NO;
#endif
}

@end
