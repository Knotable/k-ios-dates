//
//  CEditReplysItemView.m
//  Knotable
//
//  Created by backup on 14-7-18.
//
//

#import "CEditReplysItemView.h"

#import "CUtil.h"
#import "GMSolidLayer.h"
#import "CKnoteItem.h"
#import "ObjCMongoDB.h"

#import "ImageCollectionViewCell.h"
#import "KnoteTextView.h"
#import "DesignManager.h"
#import "CReplysItem.h"
#import "ThreadItemManager.h"

#import <QuartzCore/QuartzCore.h>

@interface CEditReplysItemView()<UITextViewDelegate>

@property (nonatomic, retain) IBOutlet KnoteTextView* textView;
@property (nonatomic, retain) IBOutlet UILabel*         userName;
@property (nonatomic, retain) IBOutlet UILabel*         editDate;
@property (nonatomic , assign) CGRect originalFileImageFrame;
@property (nonatomic, retain) UIView *headerLine;
@property (nonatomic, copy) NSArray *imageArray;
@property (assign) BOOL doubleTap;
@property (nonatomic, strong) NSMutableIndexSet *highlightedIndexSet;
@property (nonatomic, strong) NSDictionary *attributedTextProperties;
@property (nonatomic, strong) NSDictionary *highlightedTextProperties;


@end

@implementation CEditReplysItemView

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
            
            //_textView.contentInset =
            //_textView.clipsToBounds = YES;
            //_textView.layer.masksToBounds = YES;
            
//            _textView.layer.borderColor = [UIColor grayColor].CGColor;
            
            _textView.layer.borderColor = [UIColor clearColor].CGColor;
            
            _textView.layer.borderWidth = 2;
            _textView.layer.cornerRadius = 6;
            _textView.contentInset = UIEdgeInsetsZero;
            
            //_textView.textContainerInset = UIEdgeInsetsZero;
            
            _textView.editable = NO;
            
            _textView.textContainerInset = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
        }
        
        [self.contentView addSubview:self.textView];
        
        [self.contentView bringSubviewToFront:self.textView];
        
        // User Name region
        
        if (!_userName)
        {
            _userName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 20)];
            
            _userName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
            
//            _userName.textColor = [DesignManager knoteUsernameColor];
            _userName.textColor = [UIColor lightGrayColor];
        }
        
        [self.contentView addSubview:self.userName];
        
        [self.contentView bringSubviewToFront:self.userName];
        
        // Edit Date
        
        if (!_editDate)
        {
            _editDate = [[UILabel alloc] init];
            
            _editDate.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
            
//            _editDate.textColor = [DesignManager knoteUsernameColor];
            _editDate.textColor = [UIColor lightGrayColor];
        }
        
        [self.contentView addSubview:self.editDate];
        
        [self.contentView bringSubviewToFront:self.editDate];
    }
    return self;
}

- (void)updateConstraints
{
#if NEW_DESIGN
#else
    self.titleBarHeight = 0;
#endif
    self.infoBarHeight  = 0;
    self.infoBar.hidden = YES;
    //NSLog(@"updateConstraints itemData.height: %f", [self getItemData].height);
    
    [self.userName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(50);
        make.right.equalTo(self.mas_right).offset(-50.0);
    }];
    
    [self.editDate mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(0);
        make.right.equalTo(self.mas_right).offset(-5.0);
    }];
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(0.0);
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap-12);
        make.right.equalTo(self.mas_right).offset(-5.0);
    }];
    
    [super updateConstraints];
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textView.textContainer.size = _textView.bounds.size;
}


-(void) endEditing
{
}

-(void) startEditing
{
    [_textView becomeFirstResponder];
}

-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
    
    //NSLog(@"setItemData: %@ id: %@ files: %@", [itemData.title substringToIndex:MIN(itemData.title.length, 10)], itemData.itemId, itemData.files);
    CKnoteItem *idata = (CKnoteItem *)itemData;
    
    self.showMore = itemData.needShowMoreButton;
    
    CReplysItem *replyInfo = (CReplysItem*)itemData;
    
    NSLog(@"Reply Information : %@", replyInfo);
    
    self.userName.text = [replyInfo.content objectForKey:@"from"];
    
    NSDate  *editDateVal = [replyInfo.content objectForKey:@"date"];
    NSTimeInterval interval = 0;
    if ([editDateVal isKindOfClass:[NSDate class]]) {
        interval = [editDateVal timeIntervalSince1970];
    } else if ([editDateVal isKindOfClass:[NSDictionary class]]) {
        NSNumber *t= [(NSDictionary *)editDateVal valueForKey:@"$date"];
        if (t && [t isKindOfClass:[NSNumber class]]) {
            interval = t.longLongValue;
        }
    }
    
    self.editDate.text = [[ThreadItemManager sharedInstance] getDateTimeIndicate:interval];
    
    self.commentButton.hidden = YES;
    
    if (self.showMore)
    {
        if (!self.showMoreButton)
        {
            self.showMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [DesignManager configureMoreButton:self.showMoreButton];
            
            [self.showMoreButton addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.showMoreButton];
            [self.contentView bringSubviewToFront:self.showMoreButton];
            [self.showMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(60));
                make.height.equalTo(@(kDefaultMoreBtnH));
                make.bottom.equalTo(@-12.0);
                make.right.equalTo(@-14.0);
            }];
        }
    }
    else
    {
        if (self.showMoreButton && [self.showMoreButton superview]) {
            [self.showMoreButton removeFromSuperview];
            self.showMoreButton = nil;
        }
    }
	
    //Displaying images in separate items
    
    self.gridViewHeight = 0;
    
    
    //Needed for bug in link detection
    //_textView.text = nil;
    
    NSString *text = itemData.body;
    
    if(text == nil){
        text = @"";
    }
    
    NSLog(@"%@", idata.attributedString);
    
    _textView.attributedText = idata.attributedString;
    
    [_textView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    //Load highlights
    self.highlightedIndexSet = [[NSMutableIndexSet alloc] init];
    
    if(itemData.highlights && itemData.highlights.length > 0)
    {
        NSArray *stringRanges = [itemData.highlights componentsSeparatedByString:@"|"];
        
        [stringRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            [_highlightedIndexSet addIndexesInRange:NSRangeFromString(obj)];
        }];
        
        [self updateHighlights];
    }
    
    [self needsUpdateConstraints];
}

-(void) moreBtnClicked{};

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
/*
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
 NSLog(@"touchesBegan");
 
 [super touchesBegan:touches withEvent:event];
 }
 
 - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
 {
 NSLog(@"touchesMoved");
 
 [super touchesMoved:touches withEvent:event];
 }
 
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
 {
 NSLog(@"touchesEnded");
 
 [super touchesEnded:touches withEvent:event];
 }
 
 - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
 {
 NSLog(@"touchesCancelled");
 
 [super touchesCancelled:touches withEvent:event];
 }
 */

#pragma mark -
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    
//    CGPoint tapPoint = [gestureRecognizer locationInView:self.imageGridView];
//    if (!CGRectContainsPoint(self.imageGridView.bounds, tapPoint)) {
//        //NSLog(@"NO");
//        return NO;
//    } else {
//        //NSLog(@"YES");
//        return YES;
//    }
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    CGPoint tapPoint = [touch locationInView:self.imageGridView];
//    if (CGRectContainsPoint(self.imageGridView.bounds, tapPoint)) {
//        //NSLog(@"NO");
//        return NO;
//    } else {
//        //NSLog(@"YES");
//        return YES;
//    }
//}


- (BOOL)canBecomeFirstResponder { return YES; }


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //NSLog(@".");
    return [super canPerformAction:action withSender:sender];
    
    //NSLog(@"CEditKnoteItemView canPerformAction: %@", NSStringFromSelector(action));
    
    //BOOL superResponse = [super canPerformAction:action withSender:sender];
    //Receives actions: cut: select: selectAll: paste: delete: etc.
    //NSLog(@"CEditKnoteItemView canPerformAction: %@ withSender: %@", NSStringFromSelector(action), sender);
    if (action == @selector(highlight:) || action == @selector(quoteText:)) {
        //NSLog(@"canPerform %@ for selectedRange? %@", NSStringFromSelector(action), NSStringFromRange(_textView.selectedRange));
        //NSLog(@"textContainerInset: %@", NSStringFromUIEdgeInsets(_textView.textContainerInset));
        
        //NSLog(@"textContainerInset: %@", NSStringFromUIEdgeInsets(_textView.textContainerInset));
        
        
        if (_textView.selectedRange.length > 0) {
            return YES;
        }
    }
    return NO;
}


/*
 
 - (id)targetForAction:(SEL)action withSender:(id)sender
 {
 id target = [super targetForAction:action withSender:sender];
 NSLog(@"CEditKnoteItemView targetForAction: %@ withSender: %@ = %@", NSStringFromSelector(action), sender, target);
 return target;
 }
 
 */

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

- (void)quoteText:(UIMenuController *)menuController
{
    NSString *quoted = [_textView.text substringWithRange:_textView.selectedRange];
    NSLog(@"quoteText: %@", quoted);
    
    NSString *withEllipses = [NSString stringWithFormat:@"...%@...", quoted];
    
    [self.baseItemDelegate addNewItemFromString:withEllipses];
    
    
}



@end
