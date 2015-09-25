//
//  CEditKnoteItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditKnoteItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "CUtil.h"
#import "GMSolidLayer.h"
#import "CKnoteItem.h"
#import "ObjCMongoDB.h"
#import "ProgressHUD.h"
#import "ImageCollectionViewCell.h"
#import "KnoteTextView.h"
#import "DesignManager.h"
#import "Constant.h"
#import "PostPicturesCell.h"
#import "TextUtil.h"
#import "CMessageItem.h"
#import "CUtil.h"

#define kButtonMoreH 22
#define kSpaceFromBottom    10.0f

@interface CEditKnoteItemView ()<UITextViewDelegate>

@property (assign) BOOL doubleTap;
#if NEW_DESIGN
#else
@property (nonatomic, strong) UILabel *titleLabel;
#endif
@property (nonatomic, retain) IBOutlet  KnoteTextView   *textView;
@property (nonatomic, strong)           MASConstraint   *heightConstraint;

@property (nonatomic, strong)   NSMutableIndexSet   *highlightedIndexSet;
@property (nonatomic, strong)   NSDictionary        *attributedTextProperties;
@property (nonatomic, strong)   NSDictionary        *highlightedTextProperties;

@end

@implementation CEditKnoteItemView

@synthesize pictureCellView = _pictureCellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.gridViewHeight = 0;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        _attributedTextProperties = @{
                                      NSFontAttributeName:[DesignManager knoteBodyFont],
                                      NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                      NSBackgroundColorAttributeName:[UIColor clearColor],
                                      NSParagraphStyleAttributeName:[paragraphStyle copy]
                                      };
        
        NSDictionary *highlightedSpecificProperties = @{
                                                        NSBackgroundColorAttributeName:[UIColor yellowColor],
                                                        NSForegroundColorAttributeName:[UIColor blackColor]
                                                        };
        NSMutableDictionary *highlightedPropertiesMutable = [_attributedTextProperties mutableCopy];
        [highlightedPropertiesMutable addEntriesFromDictionary:highlightedSpecificProperties];
        
        _highlightedTextProperties = [highlightedPropertiesMutable copy];
        
        // TextView Region
        
        if (!_textView) {
            
            NSTextStorage* textStorage = [NSTextStorage new];
            NSLayoutManager* layoutManager = [NSLayoutManager new];
            layoutManager.usesFontLeading = YES;
            [textStorage addLayoutManager:layoutManager];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.contentView.bounds.size];
            textContainer.heightTracksTextView = YES;
            textContainer.widthTracksTextView = YES;
            [layoutManager addTextContainer:textContainer];
            
            self.textView = [[KnoteTextView alloc] initWithFrame:self.contentView.bounds textContainer:textContainer];
            _textView.delegate = self;
            _textView.backgroundColor = [UIColor clearColor];
            _textView.textColor = [DesignManager knoteBodyTextColor];
            _textView.font = [DesignManager knoteBodyFont];
            _textView.dataDetectorTypes = UIDataDetectorTypeLink;
            _textView.linkTextAttributes = [DesignManager linkTextAttributes];
            _textView.selectable = YES;
            _textView.userInteractionEnabled = YES;
            _textView.scrollEnabled = NO;
            _textView.contentInset = UIEdgeInsetsZero;
            _textView.editable = NO;
            _textView.textContainerInset = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
        }
        
        [self.contentView addSubview:self.textView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];

    NSInteger   postImageCount = [[self.getItemData files] count];
    NSInteger   embedImageCount = [[self.getItemData.userData loadedEmbeddedImages] count];
    NSInteger   totalImageCount = postImageCount + embedImageCount;
    // Picture Cell View
    if (totalImageCount)
    {
        [self.pictureCellView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if (self.getItemData.userData.expanded && totalImageCount>4)
            {
                make.height.equalTo(@(ceil(totalImageCount/2.0)*(ENTERPRIZEPOSTIMAGEHEIGHT/2.0)));
            }
            else
            {
                make.height.equalTo(@(ENTERPRIZEPOSTIMAGEHEIGHT));
            }
            make.top.equalTo(self.textView.mas_bottom).offset(4);
            
#if NEW_DESIGN
            make.left.equalTo(self).offset(-25);
            make.right.equalTo(self);
#else
            make.left.and.right.equalTo(self);
#endif
            
        }];
    }
    if (self.getItemData.userData.isImageDataAvailable)
    {
        [self.HTMLimgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(ENTERPRIZEPOSTIMAGEHEIGHT));
            make.top.equalTo(self.textView.mas_bottom).offset(4);
#if NEW_DESIGN
            make.left.equalTo(self).offset(4);
            make.right.equalTo(self).offset(-8);
#else
            make.left.and.right.equalTo(self.textView);
#endif
        }];
    }
#if NEW_DESIGN
#else
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        int height = 0;
        if (self.titleLabel.text.length>0){
            height = [CUtil getTextRect:self.titleLabel.text Font:self.titleLabel.font Width:CGRectGetWidth([UIScreen mainScreen].bounds) - kTheadLeftGap - 12].size.height;
        }
        make.top.equalTo(self).offset(0);
        _heightConstraint = make.height.mas_equalTo(height);
        make.left.equalTo(self).offset(kTheadLeftGap - 4);
        make.right.equalTo(self);
    }];
#endif
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        int height;
        if (!self.getItemData.userData.expanded){
            height = [self.getItemData getNotExpandedCellTextViewHeight];
        }
        else{
            height = [self.getItemData getExpandedCellTextViewHeight];
        }
        
#if NEW_DESIGN
        
        make.height.mas_equalTo(height);
        CreplyUtils *cre=[[CreplyUtils alloc]init];
        CGFloat newheight=[cre getHeightOfTitleInfo:_itmTemp.userData];
        make.top.equalTo(self).offset(newheight);
        make.left.equalTo(self).offset(4);
        make.right.equalTo(self).offset(-8);
#else
        if (self.titleLabel && self.titleLabel.hidden == NO) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(0);
        } else {
            make.top.equalTo(self).offset(0);
        }
        _heightConstraint = make.height.mas_equalTo(height);
        make.left.equalTo(self).offset(kTheadLeftGap - 12);
        make.right.equalTo(self);
    }];
    
    [self.showMoreButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(kButtonMoreH));
        make.right.equalTo(self.commentButton.mas_left).offset(-10);
        make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom-self.infoBarHeight + 5);
        
#endif
    }];
//    [super updateConstraints];
    
}

-(void)keyboardDidHide{};

- (void)layoutSubviews {
    [super layoutSubviews];
    _textView.textContainer.size = _textView.bounds.size;
}
- (void)formatDotText:(UITextView *)textView withFont:(UIFont *)font
{
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, textView.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSString *str = (NSString *)value;
        if (str && [str isKindOfClass:[NSString class]] && [str isEqualToString:@"more"])
        {
            NSMutableAttributedString *someString = [textView.attributedText mutableCopy];
            UIFont *linkFont = font;
            
            [someString setAttributes:@{
                                        NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                        NSBackgroundColorAttributeName : [UIColor clearColor],
                                        NSAttachmentAttributeName : @"more",
                                        NSFontAttributeName : linkFont,
                                        NSUnderlineColorAttributeName:[UIColor clearColor],
                                        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
                                        } range:range];
            
            textView.attributedText = someString;
        }
    }];
}

-(void) startEditing
{
    [_textView becomeFirstResponder];
}

-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
#if NEW_DESIGN
    _itmTemp=itemData;
#else
    if (itemData.userData)
    {
        self.titleBarHeight = kDefalutTitleBarH;
        if (itemData.title && itemData.title.length>0) {
            if (!self.titleLabel) {
                self.titleLabel = [[UILabel alloc] init];
                self.titleLabel.numberOfLines = 0;
                self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
            }
            self.titleBarHeight = kDefalutTitleBarH + [CUtil getTextRect:itemData.title Font:self.titleLabel.font Width:CGRectGetWidth([UIScreen mainScreen].bounds) - kTheadLeftGap - 12].size.height;
            self.titleLabel.text = itemData.title;
            [self.contentView addSubview:self.titleLabel];
            self.titleLabel.hidden = NO;
        }
        else
        {
            self.titleLabel.hidden = YES;
        }
    }
    else
#endif
    {
        if (!itemData.userData)
        {
#if !NEW_DESIGN
            self.titleBarHeight = 0;
#endif
        }
    }
    CKnoteItem *idata = (CKnoteItem *)itemData;
    
    self.showMore = itemData.needShowMoreButton;
    
    if (!(self.showMore))
    {
        if (self.showMoreButton && [self.showMoreButton superview]) {
            [self.showMoreButton removeFromSuperview];
            self.showMoreButton = nil;
        }
    }
    
    self.gridViewHeight = 0;
    NSString *text = itemData.body;
    
    if(text == nil)
    {
        text = @"";
    }
    
    NSMutableAttributedString *auxAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:idata.attributedString];
    
    if(auxAttributedString.length > 0)
    {
        [auxAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@": tap to `"]];
    }
    else
    {
        auxAttributedString = [[NSMutableAttributedString alloc] initWithString:@"tap to open file"];
    }
    BOOL shouldLimitTextViewHeight = (!idata.expandedMode);
    
    if (shouldLimitTextViewHeight)
    {
        _textView.textContainer.maximumNumberOfLines = ((CKnoteItem *)self.getItemData).maximumNumberOfLinesInNotExpandedMode;
    }
    else
    {
        _textView.textContainer.maximumNumberOfLines = 0;
    }
#if !NEW_FEATURE
    if (idata.needShowMoreButton)
    {
        if (idata.expandedMode)
        {
            _textView.attributedText = idata.attributedString;
            [self formatDotText:_textView withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
        }
        else
        {
            _textView.attributedText = idata.lessAttString;
            [self formatDotText:_textView withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
        }
    }
    else
    {
        _textView.attributedText = idata.attributedString;
        [self formatDotText:_textView withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
    }
#else
    if (itemData.userData.expanded) {
        _textView.textContainer.maximumNumberOfLines = 0;
        _textView.attributedText = idata.attributedString;
    } else {
        _textView.textContainer.maximumNumberOfLines = ((CKnoteItem *)self.getItemData).maximumNumberOfLinesInNotExpandedMode;
        if (itemData.userData.replys) {
            if (idata.lessAttString) {
                _textView.attributedText = idata.lessAttString;
            } else {
                _textView.attributedText = idata.attributedString;
            }
        } else {
            if (idata.needShowMoreButton) {
                if (idata.lessAttString) {
                    _textView.attributedText = idata.lessAttString;
                } else {
                    _textView.attributedText = idata.attributedString;
                }
            } else {
                _textView.attributedText = idata.attributedString;
            }
        }
    }

    [self formatDotText:_textView withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
#endif
    [_textView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    //Load highlights
    self.highlightedIndexSet = [[NSMutableIndexSet alloc] init];
    
    if(itemData.highlights && itemData.highlights.length > 0)
    {
        NSArray *stringRanges = [itemData.highlights componentsSeparatedByString:@"|"];
        
        [stringRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_highlightedIndexSet addIndexesInRange:NSRangeFromString(obj)];
        }];
        
        [self updateHighlights];
    }
    
    // Update Picture cell here
    
    NSInteger   postImageCount = [[itemData files] count];
    NSInteger   embedImageCount = [[itemData.userData loadedEmbeddedImages] count];
    
    NSInteger   totalImageCount = postImageCount + embedImageCount;
    if (totalImageCount==0)
    {
        if (itemData.userData.isImageDataAvailable)
        {
            totalImageCount=1;
        }
    }
    if (totalImageCount)
    {
        [self.HTMLimgView removeFromSuperview];
        
        if (itemData.userData.isImageDataAvailable)
        {
            [self.pictureCellView removeFromSuperview];

            self.HTMLimgView =[UIImageView new];
            NSString *strOfData=[[[[[[itemData.userData.documentHTML componentsSeparatedByString:@"base64"] objectAtIndex:1] componentsSeparatedByString:@","]objectAtIndex:1] componentsSeparatedByString:@"style"] firstObject];
            strOfData=[NSString stringWithFormat:@"\"%@",strOfData];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:strOfData
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image=[UIImage imageWithData:data];
            self.HTMLimgView.backgroundColor=[UIColor whiteColor];
            [self.HTMLimgView setFrame:self.bounds];
            self.HTMLimgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.HTMLimgView.image = Nil;
            self.HTMLimgView.image = image;
            
            self.HTMLimgView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentView addSubview:self.HTMLimgView];
            [self.contentView bringSubviewToFront:self.HTMLimgView];
            
        }
        else
        {
            [self.pictureCellView removeFromSuperview];
            
            if (!self.pictureCellView)
            {
                self.pictureCellView = [PostPicturesCell new];
            }
            
            [self.contentView addSubview:self.pictureCellView];
            [self.contentView bringSubviewToFront:self.pictureCellView];
            
            [self.pictureCellView setHidden:NO];
            
            self.pictureCellView.isExpand = YES;
            
            self.pictureCellView.itemData = itemData;
            [self.pictureCellView.imageGridView reloadData];
            
            if (self.baseItemDelegate)
            {
                self.pictureCellView.baseItemDelegate = self.baseItemDelegate;
            }
            else
            {
                NSLog(@"Could not allocate delegate to PostImageCell");
            }
        }
    }
    else
    {
        [self.pictureCellView removeFromSuperview];
    }
    
    [self needsUpdateConstraints];
    
    // To avoid catching the tap on the textview (and not on the item itself).
    _textView.userInteractionEnabled = NO;
}

- (void)moreBtnClicked:(UIButton *)btn
{
    if (self.baseItemDelegate
        && [self.baseItemDelegate respondsToSelector:@selector(showMoreButtonClicked:atIndex:)])
    {
        [self.baseItemDelegate showMoreButtonClicked:self atIndex:self.index ];
    }
}

- (BOOL)isImageFileType:(NSString *)filetype
{
    if( ([filetype isEqualToString:@".jpeg"]) ||
        ([filetype isEqualToString:@".tiff"]) ||
        ([filetype isEqualToString:@".raw"]) ||
        ([filetype isEqualToString:@".bmp"]) ||
        ([filetype isEqualToString:@".jpg"]) ||
        ([filetype isEqualToString:@".png"]) ||
        ([filetype isEqualToString:@".tiff"]) ||
        ([filetype isEqualToString:@".gif"]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)getFileAttachmentImageWithFileType:(NSString *)filetype
{
    NSString* toRet = @"archive.png";
    if([filetype isEqualToString:@".css"])
        toRet = @"css.png";
    else if([filetype isEqualToString:@".txt"])
        toRet = @"txt.png";
    else if([filetype isEqualToString:@".ttf"])
        toRet = @"ttf.png";
    else if([filetype isEqualToString:@".jpg"])
        toRet = @"jpg.png";
    else if([filetype isEqualToString:@".otf"])
        toRet = @"otf.png";
    else if([filetype isEqualToString:@".js"])
        toRet = @"svg.png";
    else if([filetype isEqualToString:@".svg"])
        toRet = @"js.png";
    else if([filetype isEqualToString:@".html"])
        toRet = @"html.png";
    else if([filetype isEqualToString:@".gif"])
        toRet = @"gif.png";
    else if([filetype isEqualToString:@".wav"])
        toRet = @"wav.png";
    else if([filetype isEqualToString:@".png"])
        toRet = @"png.png";
    else if([filetype isEqualToString:@".php"])
        toRet = @"php.png";
    else if([filetype isEqualToString:@".torrent"])
        toRet = @"torrent.png";
    else if( ([filetype isEqualToString:@".avi"]) ||
            ([filetype isEqualToString:@".asf"]) ||
            ([filetype isEqualToString:@".mov"]) ||
            ([filetype isEqualToString:@".mpeg"]) ||
            ([filetype isEqualToString:@".wmv"]) ||
            ([filetype isEqualToString:@".mpg"]) ||
            ([filetype isEqualToString:@".mp4"]) ||
            ([filetype isEqualToString:@".flv"]))
        toRet = @"video.png";
    else if( ([filetype isEqualToString:@".aiff"]) ||
            ([filetype isEqualToString:@".flac"]) ||
            ([filetype isEqualToString:@".mp3"]) ||
            ([filetype isEqualToString:@".m4p"]) ||
            ([filetype isEqualToString:@".wav"]) ||
            ([filetype isEqualToString:@".dvf"]) ||
            ([filetype isEqualToString:@".wma"]))
        toRet = @"music.png";
    else if( ([filetype isEqualToString:@".xls"]) ||
            ([filetype isEqualToString:@".xlt"]) ||
            ([filetype isEqualToString:@".xlsx"]) ||
            ([filetype isEqualToString:@".xltx"]))
        toRet = @"excel.png";
    else if( ([filetype isEqualToString:@".doc"]) ||
            ([filetype isEqualToString:@".docx"]) ||
            ([filetype isEqualToString:@".dot"]) ||
            ([filetype isEqualToString:@".dotx"]))
        toRet = @"word.png";
    else if( ([filetype isEqualToString:@".flv"]) ||
            ([filetype isEqualToString:@".swf"]))
        toRet = @"flash.png";
    else if( ([filetype isEqualToString:@".ppt"]) ||
            ([filetype isEqualToString:@".pptx"]) ||
            ([filetype isEqualToString:@".sldx"]))
        toRet = @"powerpoint.png";
    else if( ([filetype isEqualToString:@".psd"]) ||
            ([filetype isEqualToString:@".psb"]) ||
            ([filetype isEqualToString:@".pdd"]))
        toRet = @"photoshop.png";
    else if( ([filetype isEqualToString:@".dwt"]))
        toRet = @"dreamweaver.png";
    else if( ([filetype isEqualToString:@".jsf"]) ||
            ([filetype isEqualToString:@".stl"]) ||
            ([filetype isEqualToString:@".fw"]))
        toRet = @"fireworks.png";
    else if( ([filetype isEqualToString:@".indd"]) ||
            ([filetype isEqualToString:@".indl"]) ||
            ([filetype isEqualToString:@".indt"]))
        toRet = @"indesign.png";
    else if( ([filetype isEqualToString:@".ai"]) ||
            ([filetype isEqualToString:@".ait"]) ||
            ([filetype isEqualToString:@".eps"]))
        toRet = @"illustrator.png";
    else if( ([filetype isEqualToString:@".arp"]) ||
            ([filetype isEqualToString:@".cp"]) ||
            ([filetype isEqualToString:@".cel"]) ||
            ([filetype isEqualToString:@".imp"]) ||
            ([filetype isEqualToString:@".ses"]))
        toRet = @"audition.png";
    else if([filetype isEqualToString:@".pdf"])
        toRet = @"acrobat.png";
    else if( ([filetype isEqualToString:@".zip"]) ||
            ([filetype isEqualToString:@".rar"]))
        toRet = @"archive.png";
    
    return toRet;
}

- (UIImage *)setImageURL:(NSString *)fileURL
{
	if ( fileURL != (id)[NSNull null] && fileURL.length > 0 )
	{
        NSString *imageCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *file_id = [[fileURL componentsSeparatedByString:@"/"] lastObject];
        NSString * filePath = [imageCachePath stringByAppendingPathComponent:file_id];
        if (file_id && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
			return image;
		}
	}
	
	return nil;
}

-(CItem*) getItemData
{
    return [super getItemData];
}

- (BOOL)becomeFirstResponder
{
    BOOL flag =  [_textView becomeFirstResponder];
    return flag;
    
}
-(BOOL)isFirstResponder
{
    BOOL flag = [_textView isFirstResponder];
    return flag;
}
-(BOOL)resignFirstResponder
{
    BOOL flag = [_textView resignFirstResponder];
    return flag;
}

#pragma mark -

- (BOOL)canBecomeFirstResponder { return YES; }


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender];
}

- (void)highlight:(UIMenuController *)menuController
{
    NSRange range = _textView.selectedRange;
    if(range.length == 0){
        return;
    }
    
    if(!_highlightedIndexSet){
        self.highlightedIndexSet = [[NSMutableIndexSet alloc] init];
    }
    
    if([self.highlightedIndexSet containsIndexesInRange:range]){
        //Remove Highlight
        [self.highlightedIndexSet removeIndexesInRange:range];
    } else {
        //Highlight
        [_highlightedIndexSet addIndexesInRange:range];
    }
    [self updateHighlights];
}

-(void)updateHighlights
{
    NSString *text = _textView.text;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text attributes:_attributedTextProperties];
    
    [_highlightedIndexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [attText setAttributes:_highlightedTextProperties range:range];
    }];
    
    [_textView setAttributedText:[attText copy]];
}
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize image:(UIImage *)sourceImage{
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

- (void)quoteText:(UIMenuController *)menuController
{
    NSString *quoted = [_textView.text substringWithRange:_textView.selectedRange];
    NSLog(@"quoteText: %@", quoted);
    
    NSString *withEllipses = [NSString stringWithFormat:@"...%@...", quoted];
    
    [self.baseItemDelegate addNewItemFromString:withEllipses];
    
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0)
{
    if ([URL.absoluteString isEqualToString:@"more"]) {
        [self moreBtnClicked:nil];
        return NO;
    }
    return YES;
}
@end
