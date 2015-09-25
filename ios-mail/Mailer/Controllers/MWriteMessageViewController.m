//
//  MWriteMessageViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/22/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Masonry.h"
#import "MWriteMessageViewController.h"
#import "MMessageHeaderView.h"
#import "MMailManager.h"
#import "MDataManager.h"
#import "Message.h"
#import "Address.h"
#import "MDesignManager.h"
#import "MAppDelegate.h"
#import "Debug.h"
#import "TITokenField.h"
#import "TIToken.h"
const float REPLY_INDENT = 20.0;

@interface MWriteMessageViewController ()

@end

@implementation MWriteMessageViewController
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Wouldn't it be fantastic if, when in landscape mode, width was actually width and not height?
	keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    
    [self resizeViews];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
//    NSDictionary *info = [notification userInfo];
//    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardFrame = [kbFrame CGRectValue];
//    UIEdgeInsets insets = _scrollView.contentInset;
//    insets.bottom = keyboardFrame.size.height;
//    _scrollView.scrollIndicatorInsets = _scrollView.contentInset = insets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardHeight = 0;
    [self resizeViews];
}

- (void)resizeViews {
	
	CGRect newFrame = tokenFieldView.frame;
	newFrame.size.width = self.view.bounds.size.width;
	newFrame.size.height = self.view.bounds.size.height - keyboardHeight;
	[tokenFieldView setFrame:newFrame];
	[messageView setFrame:tokenFieldView.contentView.bounds];
    
    CGSize sizeThatShouldFitTheContent = [_textView sizeThatFits:_textView.frame.size];
    [_textView setFrame:CGRectMake(_textView.frame.origin.x, _headerView.frame.origin.y+_headerView.frame.size.height, CGRectGetWidth(_textView.bounds), sizeThatShouldFitTheContent.height)];
    
    [_tableView setFrame:CGRectMake(0, self.textView.frame.size.height + self.textView.frame.origin.y, 320, _imageArray.count*60+20)];
    [_scrollView setFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, messageView.bounds.size.height-6)];
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_scrollView.bounds),self.textView.contentSize.height+CGRectGetHeight(_tableView.bounds)+CGRectGetHeight(_headerView.bounds))];
}


- (void)keyboardDidHide:(NSNotification *)notification
{
    
}


- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame {
    
	[self textViewDidChange:messageView];
    
}


- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;

	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
    
	[tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[tokenFieldView updateContentSize];
}


-(void)setUpView{

    tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
    tokenFieldView.backgroundColor = [UIColor redColor];
	[tokenFieldView setDelegate:self];
    tokenFieldView.tokenDelegate = self;
	[tokenFieldView setSourceArray:emailArray];
	[tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;"]]; // Default is a comma
    
//    tokenFieldView.tokenField.delegate = self;
    
    [self.view addSubview:tokenFieldView];
    [tokenFieldView becomeFirstResponder];
    
    tokenFieldView.backgroundColor = [UIColor whiteColor];
    tokenFieldView.tokenField.backgroundColor = [UIColor whiteColor];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    totalSize = 0.0;
    
    _imageArray = [NSMutableArray arrayWithArray:nil];
    _imageNameArray  = [NSMutableArray arrayWithArray:nil];
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    picker.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
    
     emailArray = [[NSMutableArray alloc] initWithArray:delegate.addressArray];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = _originalMessage ? @"Reply" : @"New Message";
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 1024) {
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"topbar"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
     [self setUpView];
    
    
    
    
    messageView = [[UITextView alloc] initWithFrame:tokenFieldView.contentView.bounds];
	[messageView setScrollEnabled:NO];
	[messageView setAutoresizingMask:UIViewAutoresizingNone];
	[messageView setDelegate:self];
	[messageView setFont:[UIFont systemFontOfSize:15]];
//	[messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
	[tokenFieldView.contentView addSubview:messageView];
//    messageView.backgroundColor = [UIColor yellowColor];

    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.scrollEnabled = YES;
//    _scrollView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:_scrollView];
    [messageView addSubview:_scrollView];
    
    
    _headerView = [[MMessageHeaderView alloc] initWithFrame:CGRectZero];
//    _headerView.backgroundColor = [UIColor whiteColor];
    
//    isReply,isReplyAll,isForward
    
    switch (_boolVal) {
        case 1:
            [self updateHeaderFromOriginalMessage];
            self.navigationItem.title = @"Reply" ;
            break;
        case 2:
            [self uddateHeaderForReplyAll];
            self.navigationItem.title = @"Reply All" ;
            break;
        case 3:
            [self uddateHeaderForForward];
            self.navigationItem.title = @"Forward" ;
            break;
            
        default:
            break;
    }

    _headerView.subjectField.delegate = self;
    
    [_scrollView addSubview:_headerView];
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    
    textView.scrollEnabled = NO;
    [_scrollView addSubview:textView];
    self.textView = textView;
    
    UITableView *tblVw = [[UITableView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:tblVw];
    self.tableView = tblVw;
    
    float fontSize = 15.0;
    float lineSpacing = 4.0;
    float kerning = -0.11;
    float leftTextSpace = 11.0;
    float rightTextSpace = 8.0;
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.lineSpacing = lineSpacing;
    NSDictionary *attDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             paraStyle, NSParagraphStyleAttributeName,
                             font, NSFontAttributeName,
                             [NSNumber numberWithFloat:kerning], NSKernAttributeName,
                             nil];
    
    _textView.typingAttributes = attDict;
    
    
    if (_originalMessage) {
        [self quoteOriginalMessageContent];
    } else {
        
        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
        
        if (delegate.locationStr) {
            
            _textView.text = [NSString stringWithFormat:@"\n\nSent with Mailable from %@",delegate.locationStr];
            
        } else{
            _textView.text = @"\n\nSent with Mailable on mobile";
        }
        
    }
#if 1

    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_scrollView setFrame:messageView.bounds];
    [_headerView setFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.bounds), 40)];
    [_textView setFrame:CGRectMake(leftTextSpace,
                                   _headerView.frame.origin.y+_headerView.frame.size.height,
                                   CGRectGetWidth(_scrollView.bounds) - leftTextSpace - rightTextSpace,
                                   150)];
    
//    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_headerView.mas_bottom);
//        make.left.equalTo(_scrollView.mas_left).offset(leftTextSpace);
//        make.width.equalTo(_scrollView.mas_width).offset(-leftTextSpace - rightTextSpace);
//
//        make.height.greaterThanOrEqualTo(@150);
//
//        //Need to pin to bottom and right of scrollview to set contentSize
//        make.bottom.equalTo(_scrollView.mas_bottom);
//        make.right.equalTo(_scrollView.mas_right).offset(rightTextSpace);
//        
//    }];
//    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_textView.mas_bottom);
//        make.left.equalTo(_scrollView.mas_left).offset(leftTextSpace);
//        make.width.equalTo(_scrollView.mas_width).offset(-leftTextSpace - rightTextSpace);
//        make.height.greaterThanOrEqualTo(@150);
//    }];
#else
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(messageView.mas_top);
        make.left.equalTo(messageView.mas_left);
        make.width.equalTo(messageView.mas_width);
        make.height.equalTo(messageView.mas_height);
    }];
    

    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_top);
        make.left.equalTo(_scrollView.mas_left);
        make.width.equalTo(_scrollView.mas_width);
        make.height.equalTo(@40);
    }];
    
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headerView.mas_bottom);
        make.left.equalTo(_scrollView.mas_left).offset(leftTextSpace);
        make.width.equalTo(_scrollView.mas_width).offset(-leftTextSpace - rightTextSpace);
        
        make.height.greaterThanOrEqualTo(@150);
        
        //Need to pin to bottom and right of scrollview to set contentSize
        make.bottom.equalTo(_scrollView.mas_bottom);
        make.right.equalTo(_scrollView.mas_right).offset(rightTextSpace);
        
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView.mas_bottom);
        make.left.equalTo(_scrollView.mas_left).offset(leftTextSpace);
        make.width.equalTo(_scrollView.mas_width).offset(-leftTextSpace - rightTextSpace);
        make.height.greaterThanOrEqualTo(@150);
    }];
#endif
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    UITextRange *textRange = [_textView textRangeFromPosition:0 toPosition:0];
    [_textView setSelectedTextRange:textRange];
    _textView.delegate = self;
    
    
    
    //Modified by 3E ------START------
    
//    if (![_headerView.toField.text length]) {
    
         if (![tokenFieldView.tokenField.text length]) {
        
        
    
        tableDataArray = [[NSMutableArray alloc] init];
        
        //Setting up UITableView
        
        tableViewEmail = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, 320, 230)];
        tableViewEmail.dataSource = self;
        tableViewEmail.delegate = self;
        [self.view addSubview:tableViewEmail];
        tableViewEmail.hidden = YES;
    }
     [self addAttachmentButton];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [tokenFieldView setDelegate:nil];
}

-(void)addAttachmentButton {
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setImage:[UIImage imageNamed:@"camera-icon.png"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadAction:)forControlEvents:UIControlEventTouchUpInside];
    uploadButton.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width)-40, 0, 40, 40);
    
    [_scrollView addSubview:uploadButton];
}

-(IBAction)uploadAction:(id)sender {
    
    [_textView resignFirstResponder];
    
    UIActionSheet *achtSt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Last Photo",@"Take Photo",@"Photo Library", nil];
    [achtSt showInView:[[UIApplication sharedApplication] keyWindow]];
    
}

#pragma mark - UIActionSheet delegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
            {
                NSMutableArray *contentArray = [NSMutableArray new];
                for (int i =0; i<[_imageArray count]; i++) {
                    UIImage *img = [UIImage imageWithData:[_imageArray objectAtIndex:i]];
                    NSData *imgData = UIImageJPEGRepresentation(img,0.5);
                    [contentArray addObject:imgData];
                }
                _imageArray = [contentArray mutableCopy];
                
                [self readyToSent];
            }
                break;
            case 1:
            {
                NSMutableArray *contentArray = [NSMutableArray new];
                for (int i =0; i<[_imageArray count]; i++) {
                    UIImage *img = [UIImage imageWithData:[_imageArray objectAtIndex:i]];
                    NSData *imgData = UIImageJPEGRepresentation(img,0.8);
                    [contentArray addObject:imgData];
                }
                _imageArray = [contentArray mutableCopy];
                [self readyToSent];
            }
                break;
            case 2:
            {
                NSMutableArray *contentArray = [NSMutableArray new];
                for (int i =0; i<[_imageArray count]; i++) {
                    UIImage *img = [UIImage imageWithData:[_imageArray objectAtIndex:i]];
                    NSData *imgData = UIImageJPEGRepresentation(img,1);
                    [contentArray addObject:imgData];
                    
                }
                _imageArray = [contentArray mutableCopy];
                [self readyToSent];
            }
                break;
            case 3:
            {
                [self readyToSent];
            }
                break;
            default:
                break;
        }
        
    } else {
        switch (buttonIndex) {
            case 0:
                [self gettingLastPhoto];
                break;
                
            case 1:{
                
                BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
                if(isCamera)
                {
                    [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
                    
                }
                else
                {
                    UIAlertView *CameraAlert=[[UIAlertView alloc]initWithTitle:@"Mailable" message:@"Sorry your device does not support camera option" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [CameraAlert show];
                }
                
                
            }
                
                break;
                
            case 2:
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.modalPresentationStyle=UIModalPresentationFormSheet;
                [self presentViewController:picker animated:YES completion:nil];
                break;
                
            default:
                break;
        }
    }
    
}
-(void)showcamera {
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [picker setShowsCameraControls:NO];
        [self presentViewController:picker animated:YES completion:^{
            [picker setShowsCameraControls:YES];
        }];
    } else {
        [picker setShowsCameraControls:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)gettingLastPhoto{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        //Check that the group has more than one picture
        if ([group numberOfAssets] > 0)
            {
                // Chooses the photo at the last index
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                    
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset)
                       {
                            ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                            UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                           
                           
                           
                           float actualHeight = latestPhoto.size.height;
                           float actualWidth = latestPhoto.size.width;
                           float imgRatio = actualWidth/actualHeight;
                           float maxRatio = 320.0/480.0;
                           
                           if(imgRatio!= maxRatio)
                           {
                               if(imgRatio < maxRatio)
                               {
                                   imgRatio = 240.0 / actualHeight;
                                   actualWidth = imgRatio * actualWidth;
                                   actualHeight = 240.0;
                               }
                               else
                               {
                                   imgRatio = 160.0 / actualWidth;
                                   actualHeight = imgRatio * actualHeight;
                                   actualWidth = 160.0;
                               }
                           }
                           
                           CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
                           UIGraphicsBeginImageContext(rect.size);
                           [latestPhoto drawInRect:rect];
                           UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
                           UIGraphicsEndImageContext();
                           
                           NSData *imgData = UIImagePNGRepresentation(finalImage);
                           
                           //    //NSLog(@"Small %f MB", (CGFloat)imgData.length / (CGFloat) 1048576);
                           
                           CGFloat datalength = (CGFloat)imgData.length / (CGFloat) 1048576;
                           
                           totalSize = totalSize + datalength;
                           
                           if (totalSize <= 20.0) {
                               [_imageArray addObject:imgData];
                               
                               NSString *numberStr = nil;
                               
                               if ([_imageNameArray count]) {
                                   
                                   NSArray *strArray = [[NSString stringWithFormat:@"%@",[_imageNameArray lastObject]]componentsSeparatedByString:@" "];
                                   int lastObj = [[strArray objectAtIndex:1] intValue];
                                   lastObj = lastObj+1;
                                   
                                   numberStr = [NSString stringWithFormat:@"Image %d",lastObj];
                                   
                               }
                               else{
                                   numberStr = @"Image 1";
                               }
                               
                               [_imageNameArray addObject:numberStr];
                               
                               [_tableView reloadData];
                               
                           }
                           else{
                               
                               totalSize = totalSize - datalength;
                               
                               [self performSelector:@selector(showAlert) withObject:finalImage afterDelay:0.05];
                           }

                           
                            }
                    }];
                }
        else
           {
                //Handle this special case
                }
        [self resizeViews];
        } failureBlock: ^(NSError *error) {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"No groups");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No data available" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            }];
}

#pragma mark - UIImagePickerController Delegate method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    float actualHeight = pickedImage.size.height;
    float actualWidth = pickedImage.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 320.0/480.0;
    
    if(imgRatio!= maxRatio)
    {
        if(imgRatio < maxRatio)
        {
            imgRatio = 240.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 240.0;
        }
        else
        {
            imgRatio = 160.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 160.0;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [pickedImage drawInRect:rect];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imgData = UIImagePNGRepresentation(finalImage);
    
    
    CGFloat datalength = (CGFloat)imgData.length / (CGFloat) 1048576;
    
    totalSize = totalSize + datalength;
    
    if (totalSize <= 20.0) {
        [_imageArray addObject:imgData];
        
        NSString *numberStr = nil;
        
        if ([_imageNameArray count]) {
            
            NSArray *strArray = [[NSString stringWithFormat:@"%@",[_imageNameArray lastObject]]componentsSeparatedByString:@" "];
            int lastObj = [[strArray objectAtIndex:1] intValue];
            lastObj = lastObj+1;
            
            numberStr = [NSString stringWithFormat:@"Image %d",lastObj];
            
        }
        else{
            numberStr = @"Image 1";
        }
        
        [_imageNameArray addObject:numberStr];
        
        [_tableView reloadData];
        
    }
    else{
        
        totalSize = totalSize - datalength;
        
        [self performSelector:@selector(showAlert) withObject:finalImage afterDelay:0.05];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resizeViews];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //     picker = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resizeViews];
}

-(void)showAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry! photo can't be uploaded" message:@"Attachment size exceeded size limit of 20 MB" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
    
}

#pragma mark -UITextView Delegate Method



#pragma mark - Other Methods




-(void)removeLoader{
    
}

-(void)stopSpinner{
    
//     self.view.userInteractionEnabled = YES;
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

//Modified by 3E ------END------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    totalSize = 0.0;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)readyToSent
{
    NSString *subject = _headerView.subjectField.text;
    
    NSString *text = _textView.text;
    
    NSDictionary *messageDict = [[NSDictionary alloc] initWithObjects:@[text,subject,_imageArray] forKeys:@[@"text",@"subject",@"attachements"]];
    
    NSMutableArray *toArray = [NSMutableArray new];
    for (TIToken * token in tokenFieldView.tokenField.tokens){
        Address *to = [Address addressWithEmail:token.title name:nil];
        [toArray addObject:to.mcoAddress];
    }
    NSMutableArray *ccArray = [NSMutableArray new];
    for (TIToken * token in tokenFieldView.tokenFieldCC.tokens){
        Address *to = [Address addressWithEmail:token.title name:nil];
        [ccArray addObject:to.mcoAddress];
    }
    NSMutableArray *bccArray = [NSMutableArray new];
    for (TIToken * token in tokenFieldView.tokenFieldBCC.tokens){
        Address *to = [Address addressWithEmail:token.title name:nil];
        [bccArray addObject:to.mcoAddress];
    }
    [[MMailManager sharedManager] sendMessageTo:[toArray copy] Cc:[ccArray copy] Bcc:[bccArray copy] dataDict:messageDict];
    
    
    if (_originalMessage) {
        
        _originalMessage.replied = YES;
        _originalMessage.processed = YES;
        [[MDataManager sharedManager] saveContextAsync];
    }
    
    [self cancel:nil];
}
- (IBAction)send:(id)sender
{
    [tokenFieldView.tokenField endEditing:YES];
    [_headerView.subjectField endEditing:YES];
    
    if (totalSize>0.1) {
        NSString *title = [NSString stringWithFormat:@"This message is %f Mb. You can reduce message size by scaling images to one of the sizes below.",totalSize];
        CGFloat smallsize = 0;
        CGFloat mediumsize = 0;
        CGFloat lagersize = 0;
        for (int i =0; i<[_imageArray count]; i++) {
            UIImage *img = [UIImage imageWithData:[_imageArray objectAtIndex:i]];
            NSData *imgData = UIImageJPEGRepresentation(img,0.5);
            smallsize+=imgData.length/(CGFloat) 1024;
            imgData = UIImageJPEGRepresentation(img,.8);
            mediumsize+=imgData.length/(CGFloat) 1024;
            imgData = UIImageJPEGRepresentation(img,1);
            lagersize+=imgData.length/(CGFloat) 1024;
        }

        
        
        UIActionSheet *achtSt = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                 [NSString stringWithFormat:@"Small(%0.1f KB)" ,smallsize] ,
                                 [NSString stringWithFormat:@"Medium(%0.1f KB)" ,mediumsize] ,
                                 [NSString stringWithFormat:@"Large(%0.1f KB)" ,lagersize] ,
                                [NSString stringWithFormat:@"Original(%f MB)" ,totalSize] ,
                                 nil];
        achtSt.tag = 100;
        [achtSt showInView:[[UIApplication sharedApplication] keyWindow]];
    } else {
        [self readyToSent];
    }
}

- (void) updateHeaderFromOriginalMessage
{
//    if (_headerView && _originalMessage) {
    
        if (  _originalMessage) {
        
        NSString *subject = _originalMessage.subject;
        if (subject == nil || subject.length == 0) {
            subject = @"(No Subject)";
        }
//        _headerView.subjectField.text = [NSString stringWithFormat:@"Re: %@", subject];
        
        NSString *toEmail = _originalMessage.from.email;
        //NSLog(@"toEmail 111= %@",toEmail);
        
        
        if (_originalMessage.replyTo.count > 0) {
            Address *replyToAdress = _originalMessage.replyTo.firstObject;
            toEmail = replyToAdress.email;
        }
            
        [tokenFieldView.tokenField addTokenWithTitle:toEmail];
        
        tokenFieldView.tokenField.text = toEmail;
            
    }
}

-(void)uddateHeaderForReplyAll{
    
//    if (_headerView && _originalMessage) {
    
         if (_originalMessage) {
        NSString *subject = _originalMessage.subject;
        
        if (subject == nil || subject.length == 0) {
            subject = @"(No Subject)";
        }
        
        NSString *toEmail = _originalMessage.from.email;
        
        if (_originalMessage.replyTo.count > 0) {
           
            _summaryStr = _originalMessage.summary;
            
            NSMutableArray *resultArray = [self stringsBetweenString:@"(" andString:@")"];
            
            if ([resultArray count]) {
                
                toEmail = @"";
                
                for (int i=0; i<[resultArray count]; i++) {
                    
                    
                    NSString *arrayObj = [resultArray objectAtIndex:i];
                    arrayObj = [arrayObj stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
                    
                    [tokenFieldView.tokenField addTokenWithTitle:arrayObj];
                    
                    switch (i) {
                        case 0:
                            toEmail = arrayObj;
                            break;
                            
                        default:
                            toEmail = [NSString stringWithFormat:@"%@ , %@",toEmail,arrayObj];
                            break;
                    }
                }
            }
        }
        tokenFieldView.tokenField.text = toEmail;
    }

}

#pragma mark - stringBetweenString

-(NSMutableArray*)stringsBetweenString:(NSString*)start andString:(NSString*)end
{
    NSMutableArray* strings = [NSMutableArray arrayWithCapacity:0];
    
    NSRange startRange = [_summaryStr rangeOfString:start];
    
    for( ;; )
    {
        if (startRange.location != NSNotFound)
        {
            
            NSRange targetRange;
            
            targetRange.location = startRange.location + startRange.length;
            targetRange.length = [_summaryStr length] - targetRange.location;
            
            NSRange endRange = [_summaryStr rangeOfString:end options:0 range:targetRange];
            
            if (endRange.location != NSNotFound)
            {
                targetRange.length = endRange.location - targetRange.location;
                
                if (![strings containsObject:[_summaryStr substringWithRange:targetRange]]) {
                     [strings addObject:[_summaryStr substringWithRange:targetRange]];
                }
                
                NSRange restOfString;
                
                restOfString.location = endRange.location + endRange.length;
                restOfString.length = [_summaryStr length] - restOfString.location;
                
                startRange = [_summaryStr rangeOfString:start options:0 range:restOfString];
                
            }
            else
            {
                break;
            }
            
        }
        else
        {
            break;
        }
        
    }
    return strings;
    
}


-(void)uddateHeaderForForward{
    
    if ( _originalMessage) {
//         if (_headerView && _originalMessage) {
        NSString *subject = _originalMessage.subject;
        if (subject == nil || subject.length == 0) {
            subject = @"(No Subject)";
            subject = [subject stringByReplacingOccurrencesOfString:@"Fwd:" withString:@""];
            
        }
        
//        _headerView.subjectField.text = [NSString stringWithFormat:@"Fwd: %@", subject];
        
//        _headerView.toField.text = @"";
        
        tokenFieldView.tokenField.text = @"";
    }
    
   
//     _headerView.toField.userInteractionEnabled = YES;
}

- (void) setOriginalMessage:(Message *)originalMessage
{
    _originalMessage = originalMessage;
    [self updateHeaderFromOriginalMessage];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == tokenFieldView.tokenField) {
        
        [textField resignFirstResponder];
        
    } else if (textField == _headerView.subjectField) {
        [_textView becomeFirstResponder];
        
    }
    return NO;
}

- (void) quoteOriginalMessageContent
{
    
    if (_textPart) {
        
        NSString *text = [[_textPart decodedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSString *combined = [lines componentsJoinedByString:@"\n> "];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        NSString *timeText = [dateFormatter stringFromDate:_originalMessage.receivedDate];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSString *dateText = [dateFormatter stringFromDate:_originalMessage.receivedDate];
        
        NSString *signatureStr = @"";

        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
        
        if (delegate.locationStr) {
            signatureStr = [NSString stringWithFormat:@"Sent with Mailable from %@",delegate.locationStr];
        } else {
            signatureStr = @"Sent with Mailable on mobile";
        }
        
        NSString *contextLine = [NSString stringWithFormat:@"On %@ at %@, %@ wrote:", dateText, timeText, _originalMessage.from.pathString];
        
        NSString *newlines = @"\n\n";
        NSString *final = [NSString stringWithFormat:@"\n\n%@%@%@\n\n> %@\n", signatureStr,newlines, contextLine, combined];
        
        NSDictionary *originalAttributes = [_textView.typingAttributes copy];
        NSMutableDictionary *attDict = [originalAttributes mutableCopy];
        [attDict setObject:self.view.tintColor forKey:NSForegroundColorAttributeName];
        
        NSParagraphStyle *originalParaStyle = [[attDict objectForKey:NSParagraphStyleAttributeName] copy];
        NSMutableParagraphStyle *paraStyle = [originalParaStyle mutableCopy];
        paraStyle.firstLineHeadIndent = paraStyle.headIndent = REPLY_INDENT;
        [attDict setObject:paraStyle forKey:NSParagraphStyleAttributeName];

        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:final attributes:attDict];
        
        //3e start
        
//        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:signatureStr];
        NSDictionary *originalAttributes2 = [_textView.typingAttributes copy];
        NSMutableDictionary *attDict2 = [originalAttributes2 mutableCopy];
        [attDict2 setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        
        [attString setAttributes:originalAttributes2 range:NSMakeRange(0, signatureStr.length)];
        
        [attString setAttributes:originalAttributes range:NSMakeRange(signatureStr.length, newlines.length)];
        
         //3e end
        
//        //NSLog(@"attString= %@",attString);
        
        //_textView.text = final;
        _textView.attributedText = attString;
        
        UITextRange *textRange = [_textView textRangeFromPosition:0 toPosition:0];
        [_textView setSelectedTextRange:textRange];
        

    }

    
}

//Modified by 3E ------START------

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _tableView) {
        return [_imageArray count];
    }
    
    return [tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
    }
    
    if (tableView == _tableView) {
        
    // Configure the cell...
//    cell.textLabel.text = [NSString stringWithFormat:@"Image%d",indexPath.row+1];
        
    UILabel *imageLbl = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 200,40 )];
    imageLbl.text = [_imageNameArray objectAtIndex:indexPath.row];
    imageLbl.font=[UIFont systemFontOfSize:13.0];
    imageLbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:imageLbl];
        
    UIButton *deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBut.tag = indexPath.row;
    deleteBut.frame = CGRectMake(cell.contentView.frame.size.width-60, (cell.contentView.frame.size.height/2)-10, 20, 20);
    [deleteBut addTarget:self action:@selector(deleteAttachment:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBut setImage:[UIImage imageNamed:@"close_iconX.png"] forState:UIControlStateNormal];
    
    [cell.contentView addSubview:deleteBut];
        
        
    UIImageView *imgVw = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    imgVw.image = [UIImage imageWithData:[_imageArray objectAtIndex:indexPath.row]];
    imgVw.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:imgVw];
        
        
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height+10, cell.contentView.frame.size.width, 0.5)];
    seperatorView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:seperatorView];
        
    }
    else{
        
        cell.textLabel.text = [tableDataArray objectAtIndex:indexPath.row];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

#pragma mark - UITableview Delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView != _tableView) {
        
        toStr =  tokenFieldView.tokenField.text;
    
    NSString *truncatedString;

    truncatedString = [toStr substringToIndex:[toStr length]-removeStrLength];
    
    truncatedString= [truncatedString stringByAppendingFormat:@"%@,",[tableDataArray objectAtIndex:[indexPath row]]];
    
        tokenFieldView.tokenField.text = truncatedString;
        
    tableViewEmail.hidden = YES;
        
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((tableView ==_tableView)&&([_imageArray count])) {
        if ([_imageArray count]>1) {
            return @"Attachments";
        }
        return @"Attachment";
    }
    
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((tableView ==_tableView)&&([_imageArray count])) {
         return 60.0f;
    }
    
    return 44.0f;
}


-(IBAction)deleteAttachment:(id)sender{
    
    UIButton *but = (UIButton *)sender;
    NSInteger tag = but.tag;
    
    [_imageArray removeObjectAtIndex:tag];
    [_imageNameArray removeObjectAtIndex:tag];
    
    
    [_tableView reloadData];
    
}

//Modified by 3E ------END------

@end
