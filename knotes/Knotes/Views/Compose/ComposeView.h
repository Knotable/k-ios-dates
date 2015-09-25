//
//  ComposeView.h
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "CUtil.h"
#import "ThreadConst.h"
#import "ComposeProtocol.h"
#define kInputTitleH 36

@class HybridDocument;

@protocol ComposeNewNoteDelegate <NSObject>

- (void)onAddPicture:(id)obj;
- (void)onKeynoteClicked:(BOOL)bSelected;
- (void)infoItemTaped:(NSString *)userName sender:(id)sender;
- (void)infoItemTaped:(id)obj;

@end

@interface ComposeView : UIView<ComposeProtocol>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL showingKeyboard;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *userTagsArray;
@property (nonatomic, strong) UIImageView *imgLine;
@property (nonatomic, retain) UICollectionView *imageGridView;
@property (nonatomic, assign) CGFloat gridViewHeight;
@property(nonatomic, weak) id <ComposeNewNoteDelegate>delegate;
@property (nonatomic, assign) BOOL showsImageUploadButton;
@property (nonatomic, assign) BOOL showsContactAvatars;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, strong) HybridDocument *document;
@property (nonatomic, assign) ItemOpType opType;

- (void)addImageInfos:(NSArray *)imageInfoArray;
- (void)addImageInfo:(id)imageInfo;
- (void)setTitlePlaceHold:(NSString *)str;
- (void)setTitleContent:(NSString *)str;
- (void)setCotent:(id)content;
- (void)setUpCollectionView;
- (void)endEditor;

@end
