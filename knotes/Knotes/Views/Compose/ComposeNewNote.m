//
//  ComposeNewNote.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeNewNote.h"

#import "CEditInfoBar.h"
#import "ContactsEntity.h"
#import "CEditCandContactItem.h"
#import "CEditInfoItem.h"
#import "HybridDocument.h"
#import "InputAccessViewManager.h"

#import "UIImage+RoundedCorner.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

@interface UIWebView (HackishAccessoryHiding)
@property (nonatomic, assign) BOOL hidesInputAccessoryView;
@end

@implementation UIWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass
{
    if (!hackishFixClass)
    {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value
{
    UIView *browserView = [self hackishlyFoundBrowserView];
    
    if (browserView == nil)
    {
        return;
    }
    
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
	
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("UIWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end

@interface ComposeNewNote()
<
UITextViewDelegate,
CEditInfoBarDelegate,
RKRichTextViewDelegate,
UIWebViewDelegate,
UITextFieldDelegate
>
@property (nonatomic, strong) CEditInfoBar      *candBar;
@property (nonatomic, strong) CEditInfoBar      *infoBar;
@property (nonatomic, assign) CGFloat           infoBarHeight;
@property (nonatomic, strong) NSArray           *allContactsArray;
@property (nonatomic, strong) NSMutableArray    *candArray;
@property (nonatomic, strong) UIImageView       *sharingLine;
@property (nonatomic, strong) UIToolbar         *toolbarHolder;
@property (nonatomic, strong) UIWebView         *editorView;
@property (nonatomic, strong) UIView *sepectView;

@property (nonatomic, assign) CGFloat keyBoardHeight;

@end
@implementation ComposeNewNote

- (BOOL)isIpad {
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}//end

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleHeight = kInputTitleH;
        
        self.keyBoardHeight = 260;
        
//      self.richTextView = [[RKRichTextView alloc] initWithFrame:CGRectZero];
//      self.richTextView.hidesInputAccessoryView = YES;
//      self.richTextView.aDelegate = self;
//        
//      [self addSubview:self.richTextView];
//      self.richTextView.text = @"";
        
        self.editorView.delegate = self;
        self.editorView.scalesPageToFit = YES;
        self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.editorView.scrollView.bounces = NO;
        
        [self addSubview:self.editorView];
        
        // Background Toolbar
        // Parent holding view
        
        self.toolbarHolder =[[InputAccessViewManager sharedInstance] inputAccessViewWithCameraDup];
        
        [self.toolbarHolder setFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), 320, 44)];
        
        self.toolbarHolder.hidden = YES;
        
        NSString *html = @"<!-- This is an HTML comment -->"
        "<p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
        
        // Set the base URL if you would like to use relative links, such as to images.
        //self.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
        
        [self setHTML:html];

        self.imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload-devider"]];
        
        [self addSubview:self.imgLine];

        self.sharingLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload-devider"]];
        
        [self addSubview:self.sharingLine];

        [self setUpCollectionView];
        
        //self.imageGridView.backgroundColor = [UIColor blackColor];
        
        if (!self.allContactsArray)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username!=nil"];
            
            self.allContactsArray = [ContactsEntity MR_findAllWithPredicate:predicate];
        }        
    }
    
    return self;
}

- (void)quoteText:(UIMenuController *)menuController
{
    return;
}

- (void)highlight:(UIMenuController *)menuController
{
//     [self.richTextView stringByEvaluatingJavaScriptFromString:@"setHighlight()"];

}

- (void)setHTML:(NSString *)html
{
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight:)];
    UIMenuItem *quoteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Quote" action:@selector(quoteText:)];
    [UIMenuController sharedMenuController].menuItems = @[highlightMenuItem, quoteMenuItem];
}

- (NSString *)getHTML {
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
	return html;
}
#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}//end


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}//end

-(void)setTitleHeight:(CGFloat)titleHeight
{
    [super setTitleHeight:titleHeight];
    
    if (titleHeight>0)
    {
        if (!self.titleTextField)
        {
            self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, self.bounds.size.width-8, kInputTitleH)];
            self.titleTextField.textColor = [UIColor blackColor];
            self.titleTextField.placeholder = @"";
            self.titleTextField.font = kCustomBoldFont(kDefaultFontSize);
            self.titleTextField.borderStyle = UITextBorderStyleNone;
            self.titleTextField.backgroundColor = [UIColor whiteColor];
            self.titleTextField.layer.masksToBounds=YES;
            
            self.titleTextField.delegate = self;
            
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, kInputTitleH)];
            self.titleTextField.leftView = paddingView;
            self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
            self.titleTextField.rightView = paddingView;
            self.titleTextField.rightViewMode = UITextFieldViewModeAlways;
            
            //[self addSubview:self.titleTextField];
            
            // The line under of title view
            self.sepectView = [[UIView alloc] init];
            self.sepectView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            
            //[self addSubview:self.sepectView];
            
            [self.sepectView setFrame:CGRectMake(4, kInputTitleH, self.bounds.size.width-8, 1)];
        }
    }
}

-(void)setUserIds:(NSMutableArray *)userIds
{
    if (_userIds!=userIds) {
        _userIds = userIds;
    }
    if (!self.showsContactAvatars) {
        return;
    }
    self.infoBarHeight = kDefalutInfoBarH;
    if (!self.infoBar) {
        self.infoBar = [[CEditInfoBar alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
        self.infoBar.delegate = self;
        [self addSubview:self.infoBar];
    }
    [self.infoBar reloadData];

    self.infoBar.hidden = NO;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat h = CGRectGetHeight(self.bounds);
    
    if ([self.imageArray count]>0)
    {
        DLog(@"%f - %f", h, self.gridViewHeight);
        
        [self.richTextView.view setFrame:CGRectMake(5, 0, 312, h - 20)];
        self.richTextView.editorView.frame = CGRectMake(0, 0, self.richTextView.view.frame.size.width, self.richTextView.view.frame.size.height - 20);
        [self.richTextView setContentHeight:self.richTextView.editorView.frame.size.height];
    }
    else
    {
        [self.richTextView.view setFrame:CGRectMake(5, 0, 312, h + 40)];
        
        self.richTextView.editorView.frame = CGRectMake(0, 0, self.richTextView.view.frame.size.width, self.richTextView.view.frame.size.height - 20);
        [self.richTextView setContentHeight:self.richTextView.editorView.frame.size.height];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kVGap+self.titleHeight);
        make.bottom.equalTo(self.imgLine.mas_top).offset(-kVGap);
        make.left.equalTo(self.mas_left).offset(kHGap);
        make.right.equalTo(self.mas_right).offset(-kHGap);
    }];
    
    if(self.imageArray.count>0)
    {
        [self.imgLine setHidden:NO];
        
        [self.imgLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.imageGridView.mas_top).offset(-kVGap);
            make.left.equalTo(self.mas_left).offset(kHGap);
            make.right.equalTo(self.mas_right).offset(-kHGap);
            make.height.equalTo(@(1));
        }];
    }
    else
    {
        [self.imgLine setHidden:YES];
    }

    if(self.imageArray.count>0)
    {
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(       @(self.gridViewHeight));
            make.bottom.equalTo(self.bgView.mas_bottom).offset(50);//darshana
            make.left.equalTo(self.bgView.mas_left).offset(10);
            make.right.equalTo(self.bgView.mas_right).offset(-10);
        }];
    }
    else
    {
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(self.gridViewHeight));
            make.bottom.equalTo(self.bgView.mas_bottom).offset(10); //darshana
            make.left.equalTo(self.bgView.mas_left).offset(10);
            make.right.equalTo(self.bgView.mas_right).offset(-10);
        }];
    }

    
    [self.sharingLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imageGridView.mas_bottom).offset(-12.0);
        make.left.equalTo(self.mas_left).offset(kHGap);
        make.right.equalTo(self.mas_right).offset(-kHGap);
        make.height.equalTo(@(1));
    }];


    if(self.showsContactAvatars)
    {
        [self.infoBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(self.infoBarHeight));
            make.left.equalTo(self.bgView.mas_left).offset(0);
            make.right.equalTo(self.bgView.mas_right).offset(0);
            make.bottom.equalTo(self.bgView.mas_bottom).offset(0);
        }];
    }
    else
    {
        
    }
}

-(void)hideToolBar
{
    self.toolbarHolder.hidden = YES;
}

#pragma mark ComposeProtocol

- (void)setTitlePlaceHold:(NSString *)str
{
}

- (void)setTitleContent:(NSString *)str
{
    if (str && [str length]>0) {
        self.textView.text = str;
    }
    // added by Donald Pae(1/29/2014)
    else
        self.textView.text = @"";
}

- (void)setDocument:(HybridDocument *)document
{
    [super setDocument:document];
    
    self.textView.text = document.text;

    NSRange range = [document.documentHTML rangeOfString:@"<div class=\"thumbnail-wrapper"];
    if (range.location == NSNotFound) {
        
//        self.richTextView.text = document.documentHTML;
        [self.richTextView setHTML:document.documentHTML];
        
    } else {
        range = NSMakeRange(0,range.location);
        NSString *str = [document.documentHTML substringWithRange:range];
//        self.richTextView.text = str;
        [self.richTextView setHTML:str];
    }
}

- (void)setCotent:(id)content
{
    if ([content isKindOfClass:[NSArray class]])
    {
        self.imageArray = [content mutableCopy];
    }
    else if ([content isKindOfClass:[NSMutableArray class]])
    {
        self.imageArray = content;
    }
    
    NSInteger num = ceilf(([self.imageArray count]+1)/5.0);
    
    if (num > 0)
    {
        self.gridViewHeight = num * kGridViewH + 16;
    }
    else
    {
        self.gridViewHeight = 0;
    }
    
    [self.imageGridView reloadData];
    
    [self updateConstraints];
}

- (id)getCotent
{
	NSLog( @"%s [Line %d]" , __FUNCTION__ , __LINE__ );
    return self.imageArray;
}

- (NSMutableArray *)getUsertags
{
    return self.userTagsArray;
}

-(void)setEditorMode:(BOOL)editorMode
{
    self.textView.userInteractionEnabled = editorMode;
    self.textView.editable = editorMode;
    self.imageGridView.userInteractionEnabled = editorMode;
    self.imageGridView.allowsSelection = editorMode;
}

-(ContactsEntity *)getContactByName:(NSString *)contactstr
{
    for (ContactsEntity *entity in self.allContactsArray) {
        if (![entity isFault]) {
            if ([entity.username isEqualToString:contactstr]) {
                return entity;
            }
        }
    }
    return nil;
}

-(BOOL)isHaveFistElemHtmlTag:(NSString *)str
{
    BOOL ret = NO;
    if (str && str.length>2) {
        if ([[str substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"<"]) {
            NSRange range = [str rangeOfString:@">"];
            if (range.location != NSNotFound) {
                ret = YES;
            }
        }
    }
    return ret;
}

- (NSString *)getTitle
{
    return @"TESTTITLETEST";
}

- (NSString *)getBody
{
    //[self.richTextView endEditing:YES];
    
    if (!self.userTagsArray)
    {
        self.userTagsArray = [NSMutableArray new];
    }
    
    [self.userTagsArray removeAllObjects];
    
    NSString *text = [self.richTextView getHTML];
    
    NSMutableString *retStr = [NSMutableString new];
    
    if (text && text.length>0)
    {
        NSArray *array  =[text componentsSeparatedByString:@"@"];
        
        if (array.count>1)
        {
            for (NSString *string in array)
            {
                if (string.length>0)
                {
                    if ([self isHaveFistElemHtmlTag:string])
                    {
                        [retStr appendFormat:@"%@",string];
                    }
                    else
                    {
                        NSArray *subarray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        NSString *contactstr = subarray.firstObject;
                        
                        if (contactstr && contactstr.length>0)
                        {
                            ContactsEntity *entity = [self getContactByName:contactstr];
                            
                            if (entity)
                            {
                                [self.userTagsArray addObject:entity.contact_id];
                                
                                NSRange range= NSMakeRange(0, contactstr.length);
                                
                                NSString *formatStr = [NSString stringWithFormat:@"<span class='usertag' title='%@'>@%@</span>",entity.username,entity.name];
                                
                                NSString *newString = [string stringByReplacingCharactersInRange:range withString:formatStr];
                                
                                [retStr appendString:newString];
                            }
                            else
                            {
                                [retStr appendFormat:@"@%@",string];
                            }
                        }
                        else
                        {
                            [retStr appendFormat:@"@%@",string];
                        }
                    }
                }
            }
        }
        else
        {
            retStr = [text mutableCopy];
        }
    }

    return [retStr copy];
}

- (void) setBody : (NSString*)b
{
    [self.richTextView setHTML:b];
}

- (void)endEditor
{
    
}

- (void)onAddImage:(id)sender
{
    double delayInSeconds = 0.3;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(onAddPicture:)])
        {
            [self.delegate onAddPicture:sender];
        }
        
    });
}

- (NSUInteger)numOfCellsInCandidateBar:(CEditInfoBar *)candBar
{
    if ([candBar isEqual:self.infoBar]) {
        return [self.userIds count];
    } else if ([candBar isEqual:self.candBar]){
        return [_candArray count];
    }
    return 0;
}

- (CGSize)candidateBar:(CEditInfoBar *)candBar sizeOfCellAtIndex:(NSUInteger)index
{
    if ([candBar isEqual:self.infoBar]) {
        return CGSizeMake(30, 30);
    } else if ([candBar isEqual:self.candBar]){
        return CGSizeMake(118, 40);
    }
    return CGSizeZero;
}

- (BI_GridViewCell *)candidateBar:(CEditInfoBar *)candBar cellForFrame:(BI_GridFrame *)frame
{
    if ([candBar isEqual:self.infoBar])
    {
        
        static NSString *kCandBarCell  = @"CandidateBarCell";
        
        CEditInfoItem *cell = (CEditInfoItem *)[candBar dequeueReusableCellWithIdentifier:kCandBarCell];
        if (nil == cell)
        {
            cell = [[CEditInfoItem alloc] initWithReuseIdentifier:kCandBarCell];
        }
        ContactsEntity *entity =  [self.userIds objectAtIndex:frame.startIndex];
        
        if (entity) {
            [entity getAsyncImageWithBlock:^(id img, BOOL flag) {
                if (img) {
                    if ([cell.imgView isKindOfClass:[UIImageView class]]) {
                        img = [img circlePlainImageSize:kDefalutPaityIconH];
                        [(UIImageView *)cell.imgView setImage:img];
                    }
                }
            }];
        }
        [cell setNeedsUpdateConstraints];
        return cell;
    }
    else if ([candBar isEqual:self.candBar])
    {//todo
        static NSString *kCandBarCell  = @"CandidateBarCell1";
        
        CEditCandContactItem *cell = (CEditCandContactItem *)[candBar dequeueReusableCellWithIdentifier:kCandBarCell];
        if (nil == cell)
        {
            cell = [[CEditCandContactItem alloc] initWithReuseIdentifier:kCandBarCell];
        }
        ContactsEntity *entity =  [self.candArray objectAtIndex:frame.startIndex];
        if (![entity isFault]) {
            cell.entity = entity;
        }

        [cell setNeedsUpdateConstraints];
        return cell;
    }
    return nil;
}

- (void)candidateBar:(CEditInfoBar *)candBar didSelectCellAtIndex:(NSUInteger)index
{
    if ([candBar isEqual:self.infoBar])
    {
        ContactsEntity *entity =  [self.userIds objectAtIndex:index];
        BI_GridViewCell *cell = [candBar cellAtIndex:index];
        NSString *userName = entity.username;
        if (!userName || [userName length]<=0) {
            userName = [[entity.name componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(infoItemTaped:sender:)]) {
            [self.delegate infoItemTaped:userName sender:cell];
        }
    }
    else if ([candBar isEqual:self.candBar])
    {
        ContactsEntity *entity =  [self.candArray objectAtIndex:index];
        [self insertContactMention:entity.username];
        self.candBar.hidden = YES;
        self.candArray = [@[] mutableCopy];

    }
}

- (void)insertContactMention:(NSString *)username {
    
    NSString *string = [self.richTextView getText];
    {
        NSRange rangeToSearch = NSMakeRange(0, [string length] - 1); // get a range without the space character
        NSRange rangeOfSecondToLastChar = [string rangeOfString:@"@" options:NSBackwardsSearch range:rangeToSearch];
        NSString *lastChar = [string substringWithRange:NSMakeRange(string.length-1, 1)];
        if (rangeOfSecondToLastChar.location != NSNotFound && ![lastChar isEqualToString:@"@"]) {
            NSString *inserStr =@"";
#if 0
            inserStr = [NSString stringWithFormat:@"%@&nbsp;",username];
            string = [string stringByReplacingCharactersInRange:NSMakeRange(rangeOfSecondToLastChar.location+1, string.length-rangeOfSecondToLastChar.location-1) withString:inserStr];
            //self.richTextView.text = string;
            [self.richTextView setHtml:string];
#else
            string = [string substringWithRange:NSMakeRange(rangeOfSecondToLastChar.location+1, string.length-rangeOfSecondToLastChar.location-1)];
            NSRange range = [username rangeOfString:string options:NSBackwardsSearch];
            if (range.location != NSNotFound) {
                inserStr = [username substringWithRange:NSMakeRange(string.length, username.length - string.length)];
                NSString *trigger = [NSString stringWithFormat:@"insertTextAtCursor(\"%@\",\"%@\")",inserStr,username];
//                [self.richTextView stringByEvaluatingJavaScriptFromString:trigger];
                [self.richTextView.editorView stringByEvaluatingJavaScriptFromString:trigger];
                
            }
#endif
            
        } else {
            NSString *trigger = [NSString stringWithFormat:@"insertTextAtCursor(\"%@\",\" \")",username];
            [self.richTextView.editorView stringByEvaluatingJavaScriptFromString:trigger];
        }
    }
}

#pragma mark UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.document) {
        [self.document changeTextInRange:range replacementText:text deleteEmptyTags:NO];
    }
    return YES;
}

#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.titleTextField])
    {
        if ( [textField.text length] == 0
            || [textField.text isEqualToString:@""]
            || (textField.text == nil) )
        {
            // do not change focus to body region
            
            return NO;
        }
        else
        {
            // change focus to body
            
//            if (self.richTextView.isFirstResponder == NO)
//            {
//                [self.richTextView becomeFirstResponder];
//                
//                [self.richTextView setText:@""];
//            }
            
            
            
            return NO;
        }
    }
    else
        return YES;
}

#pragma mark - UIWebView Delegate

//-(void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    self.editorView.keyboardDisplayRequiresUserAction = NO;
//    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
//    [self.editorView stringByEvaluatingJavaScriptFromString:js];
//    
//}
//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:self.toolbarHolder];
//}
//
//-(void)removeFromSuperview
//{ 
//    [super removeFromSuperview];
//    self.toolbarHolder.hidden = YES;
//    [self.toolbarHolder removeFromSuperview];
//}

#pragma mark - Keyboard status

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
    // User Info
    NSDictionary *info = notification.userInfo;
    
//    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
//    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.keyBoardHeight = keyboardEnd.size.height;
    
    // Toolbar Sizes
    CGFloat sizeOfToolbar = self.toolbarHolder.frame.size.height;
    
    // Keyboard Size
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? keyboardEnd.size.width : keyboardEnd.size.height;
    
    // Correct Curve
    // UIViewAnimationOptions animationOptions = curve << 16;
    
	if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
    {
        self.toolbarHolder.hidden = NO;
        
        // Toolbar
        CGRect frame = self.toolbarHolder.frame;
        frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds) - (keyboardHeight + sizeOfToolbar);
        self.toolbarHolder.frame = frame;
        
	}
    else
    {
        CGRect frame = self.toolbarHolder.frame;
        
        frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds) + keyboardHeight;
        self.toolbarHolder.frame = frame;
        self.toolbarHolder.hidden = YES;
	}//end
    
}

#pragma mark RKRichTextViewDelegate

//-(void) onMention:(RKRichTextView *)richTextView withText:(NSString *)text
//{
//    if (!self.candBar)
//    {
//        self.candBar = [[CEditInfoBar alloc] initWithFrame:[self.toolbarHolder bounds]];
//        self.candBar.style = 1;
//        self.candBar.delegate = self;
//        self.candBar.backgroundColor = [UIColor whiteColor];
//
//    }
//    if (![self.candBar superview])
//    {
//        [self.toolbarHolder addSubview:self.candBar];
//    }
//
//    if ([self.allContactsArray count]>0) {
//        self.candBar.hidden = NO;
//        self.candArray = [self.allContactsArray copy];
//        [self.candBar reloadData];
//    } else {
//        self.candBar.hidden = YES;
//    }
//}

//-(void)delayCheck:(RKRichTextView *)richTextView
//{
//    //get @---?
//    NSString *string = richTextView.text;
//    if([string rangeOfString:@"What is your point?"].location != NSNotFound){
//        if([string rangeOfString:@"What is your point?"].location == 0){
//            richTextView.text = [string substringFromIndex:[string rangeOfString:@"What is your point?"].length];
//            
//            if (self.richTextView.isFirstResponder == NO)
//            {
//                [richTextView becomeFirstResponder];
//            }
//        }
//    }
//
//    if ([string isEqualToString:@""] == NO)
//    {
//        NSRange rangeToSearch = NSMakeRange(0, [string length] - 1); // get a range without the space character
//        
//        NSRange rangeOfSecondToLastChar = [string rangeOfString:@"@" options:NSBackwardsSearch range:rangeToSearch];
//        
//        if (rangeOfSecondToLastChar.location != NSNotFound)
//        {
//            NSString *searchLastStr = [string substringWithRange:NSMakeRange(rangeOfSecondToLastChar.location + 1,
//                                                                             string.length - rangeOfSecondToLastChar.location-1)];
//            
//            NSLog(@"%@", searchLastStr);
//            
//            NSMutableArray *array = [NSMutableArray new];
//            
//            for (ContactsEntity *entity in self.allContactsArray)
//            {
//                NSRange range = [entity.username rangeOfString:searchLastStr];
//                
//                if (range.location != NSNotFound)
//                {
//                    [array addObject:entity];
//                }
//            }
//            
//            self.candArray = array;
//            
//            if (array.count<=0)
//            {
//                self.candBar.hidden = YES;
//            }
//            else
//            {
//                self.candBar.hidden = NO;
//                
//                [self.candBar reloadData];
//            }
//        }
//    }
//}
//
//-(void) onInsert:(RKRichTextView *)richTextView withText:(NSString *)text
//{
//    [self performSelector:@selector(delayCheck:) withObject:richTextView afterDelay:0];
//}

@end
