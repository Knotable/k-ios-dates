//
//  ComposeNewNote.h
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import <UIKit/UIKit.h>
#import "ComposeView.h"
#import "ImageCollectionViewCell.h"
#import "RKRichTextView.h"
#import "KnotesRichTextController.h"

@interface ComposeNewNote : ComposeView

@property (nonatomic, strong) NSMutableArray*   userIds;
@property (nonatomic, strong) UITextView*       textView;
@property (nonatomic, strong) UITextField*      titleTextField;
@property (nonatomic) BOOL                      formatHTML;
//@property (nonatomic, strong) RKRichTextView*   richTextView;

//@Malik
@property (nonatomic, strong) KnotableRichTextController*   richTextView;

- (void)endEditor;
- (void)onAddImage:(id)sender;
- (void)keyboardWillShowOrHide:(NSNotification *)notification;
- (NSString *) getBody;
- (void) setBody : (NSString*)b;

- (NSMutableArray *)getUsertags;
-(void)hideToolBar;

@end
