//
//  PeopleSelectViewController.m
//  Knotable
//
//  Created by liwu on 13-12-12.
//
//

#import "PeopleSelectViewController.h"
#define selectedTag 100
#define cellSize 52
#define textLabelHeight 20
#define cellAAcitve 1.0
#define cellADeactive 1.0
#define cellAHidden 0.0
#define defaultFontSize 8.0
#import "FWTPopoverView.h"
@interface PeopleSelectViewController ()
{
    NSIndexPath *lastAccessed;
}
@property (nonatomic, retain) FWTPopoverView *popoverView;

@end

@implementation PeopleSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedIdx = [[NSMutableDictionary alloc] init];
    self.deselectBtn.hidden = YES;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView setAllowsMultipleSelection:YES];
    
    UIBarButtonItem *btnReset = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetSelectedCells)];
    self.navigationItem.rightBarButtonItem = btnReset;
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.itemArray count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (![cell viewWithTag:selectedTag])
    {
        UILabel *selected = [[UILabel alloc] initWithFrame:CGRectMake(0, cellSize - textLabelHeight, cellSize, textLabelHeight)];
        selected.backgroundColor = [UIColor darkGrayColor];
        selected.textColor = [UIColor whiteColor];
        selected.text = @"SELECTED";
        selected.textAlignment = NSTextAlignmentCenter;
        selected.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:defaultFontSize]/*[UIFont systemFontOfSize:defaultFontSize]*/;
        selected.tag = selectedTag;
        selected.alpha = cellAHidden;
        
        [cell.contentView addSubview:selected];
    }
    SHMenuItem *item = [self.itemArray objectAtIndex:[indexPath row]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:item.image];
    [[cell viewWithTag:selectedTag] setAlpha:cellAHidden];
    cell.backgroundView.alpha = cellADeactive;
    
    cell.backgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.backgroundView.layer.borderWidth = 2;
    cell.backgroundView.layer.cornerRadius = 4;
    cell.backgroundView.clipsToBounds = YES;
    // You supposed to highlight the selected cell in here; This is an example
    bool cellSelected = [selectedIdx objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
    [self setCellSelection:cell selected:cellSelected];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellSize, cellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:YES];
    
    if (self.popoverView) {
        [self.popoverView dismissPopoverAnimated:NO];
        self.popoverView = nil;
    }

    SHMenuItem *item = [self.itemArray objectAtIndex:[indexPath row]];
    if (!self.popoverView )
    {
        self.popoverView = [[FWTPopoverView alloc] initwithText:item.name] ;
        __block typeof(self) myself = self;
        self.popoverView.didDismissBlock = ^(FWTPopoverView *av){
            myself.popoverView = nil;
        };
        CGColorRef fillColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"topic-bg"]].CGColor;
        self.popoverView.backgroundHelper.fillColor = fillColor;
        [self.popoverView presentFromRect:CGRectMake(cell.frame.origin.x+50, cell.frame.origin.y, 1.0f, 1.0f)
                                   inView:self.view
                  permittedArrowDirection:FWTPopoverArrowDirectionNone
                                 animated:YES];
    }
    
    [self.view bringSubviewToFront:self.popoverView];
    [UIView animateWithDuration :2.0 delay:3.0 options:UIViewAnimationOptionBeginFromCurrentState
                   animations			:^{
                       [self.popoverView dismissPopoverAnimated:YES];
                   }
                      completion:^(BOOL finished) {
                          if (finished)
                          {
                          }
                      }
     ];

    [selectedIdx setValue:@"1" forKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:NO];
    
    [selectedIdx removeObjectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
}

- (void) setCellSelection:(UICollectionViewCell *)cell selected:(bool)selected
{
    cell.backgroundView.alpha = selected ? cellAAcitve : cellADeactive;
    [cell viewWithTag:selectedTag].alpha = selected ? cellAAcitve : cellAHidden;
}

- (void) resetSelectedCells
{
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        [self deselectCellForCollectionView:self.collectionView atIndexPath:[self.collectionView indexPathForCell:cell]];
    }
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:self.collectionView].x;
    float pointerY = [gestureRecognizer locationInView:self.collectionView].y;
    
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [self.collectionView indexPathForCell:cell];
            
            if (lastAccessed != touchOver)
            {
                if (cell.selected)
                    [self deselectCellForCollectionView:self.collectionView atIndexPath:touchOver];
                else
                    [self selectCellForCollectionView:self.collectionView atIndexPath:touchOver];
            }
            
            lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        lastAccessed = nil;
        self.collectionView.scrollEnabled = YES;
    }
    
    
}


- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void) deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}
-(IBAction)onDeselectClick:(id)sender
{
    [self resetSelectedCells];
}
-(IBAction)onDoneClick:(id)sender
{
    NSMutableArray *selectedArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (NSNumber *key in [selectedIdx allKeys]) {
        NSString *str = [[self.itemArray objectAtIndex:[key integerValue]] email];
        [selectedArray addObject:str];
    }
    if (self.doneBlock) {
        self.doneBlock([selectedArray copy]);
    }
}

@end
