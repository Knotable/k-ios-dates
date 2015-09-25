//
//  PeopleSelectViewController.h
//  Knotable
//
//  Created by liwu on 13-12-12.
//
//

#import <UIKit/UIKit.h>
#import "SHMenuItem.h"
typedef void (^PeopleSelectViewControllerDoneBlock)(NSArray*);


@interface PeopleSelectViewController : UIViewController
{
    CGPoint dragStartPt;
    bool dragging;
    
    NSMutableDictionary *selectedIdx;
}
@property (weak, nonatomic) IBOutlet UIButton *deselectBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (strong, nonatomic) NSArray *itemArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, copy) PeopleSelectViewControllerDoneBlock doneBlock;

@end
