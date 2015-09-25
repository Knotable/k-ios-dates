//
//  Created by Dimitris Doukas on 25/03/2011.
//  Copyright 2011 doukasd.com. All rights reserved.
//

#import "DialController.h"
#import "GlowLabel.h"
#import "CUtil.h"

#define NUM_ROWS            500000
#define ROW_HEIGHT          30


@interface DialController (PrivateMethods)
- (void)snap;
- (NSInteger)indexOfString:(NSString *)string;
@end


@implementation DialController

@synthesize tableView, strings, selectedString;
@synthesize isSpinning;
@synthesize delegate;

static NSString *CellIdentifier = @"DialCell";
static const int kGlowLabelTag = 2011;
static const int kGlowBGLabelTag = 2012;

- (void)dealloc
{
    self.tableView = nil;
    self.strings = nil;
    self.selectedString = nil;
    [super dealloc];
}

- (id)initWithDialFrame:(CGRect)frame strings:(NSArray *)dialStrings {
    self = [super init];
    if (self) {
        self.isSpinning = NO;
        isAnimating = NO;
        
        //validate the data
        //check if the strings are more than 0. If they are not, create a default array
        if (dialStrings == nil || [dialStrings count] == 0) {
            dialStrings = [NSArray arrayWithObjects:@"0", nil];
        }
        //check if the strings contain duplicates
        //...
        
        self.strings = dialStrings;
        
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = ROW_HEIGHT;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.separatorColor = [UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:88.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0];
        [self addSubview:self.tableView];
        
        //INIT
        //select a row in the middle
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(int)(NUM_ROWS * .5) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self snap];
        
        //select random value
        //[self spinToRandomValue];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)spinToString:(NSString *)string {
    isAnimating = NO;
    self.isSpinning = NO;
    if ([[self.tableView visibleCells] count] == 0) {
        return;
    }
    //take any visible cell, find it's value's index, compute the difference to the index of the new value and scroll to that cell
    UITableViewCell *cell = [[self.tableView visibleCells] objectAtIndex:0];
    GlowLabel *label = (GlowLabel *)[cell viewWithTag:kGlowLabelTag];
    int difference = (int)[self indexOfString:string] - (int)[self indexOfString:label.text];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView indexPathForCell:cell].row + difference inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)snap {
    if (isAnimating) return;
    isAnimating = YES;
    
    self.isSpinning = NO;
    
    //calculate vertical padding
    double verticalPadding = (self.tableView.frame.size.height - self.tableView.rowHeight) * .5;
    
    //for each cell, check if it is in view and set it to selected accordingly
    for (int i=0; i<[[self.tableView visibleCells] count]; i++) {
        UITableViewCell *cell = [[self.tableView visibleCells] objectAtIndex:i];
        GlowLabel *label = (GlowLabel *)[cell viewWithTag:kGlowLabelTag];
        BOOL selected = CGRectContainsPoint(CGRectMake(0, self.tableView.contentOffset.y + verticalPadding, self.tableView.frame.size.width, self.tableView.rowHeight), cell.center);
        [label setSelected:selected];
        if (selected) {
            isAnimating = YES;
            self.isSpinning = NO;
            //self.selectedValue = [self.values objectAtIndex:[label.text intValue]];
            self.selectedString = label.text;
            [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            //check if snappin will not result in an animation. in that case, call the delegate here
            if ([self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:cell]].origin.y == self.tableView.contentOffset.y + (self.tableView.frame.size.height - ROW_HEIGHT) * .5) {
                NSLog(@"snap will not animate!");
                
                [self.delegate dialController:self didSnapToString:self.selectedString];
                isAnimating = NO;
            }
        }
    }
}

/*
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/

#pragma mark UITableViewDataSource methods
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 22;
//}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int cellNumber = (int)(indexPath.row % [self.strings count]);
    
    UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //make the cell unselectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //add the glow label
        GlowLabel *label = [[GlowLabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, ROW_HEIGHT)];
        label.textAlignment = NSTextAlignmentRight;
        
        NSString* strVersion = [[UIDevice currentDevice] systemVersion];
        float version = [strVersion floatValue];
        if (version > 6.1) {
            label.unselectedColor = [UIColor darkGrayColor];
            label.selectedColor = NSColorFromRGB(0x88B6DB);
//            [UIColor blackColor];
        }else {
            label.unselectedColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
        }
        label.text = [NSString stringWithFormat:@"%@", [self.strings objectAtIndex:cellNumber]];
        label.tag = kGlowLabelTag;
        
        //add a background label
        UILabel *bgLabel = [[UILabel alloc] initWithFrame:label.frame];
        bgLabel.textAlignment = NSTextAlignmentRight;
        bgLabel.text =@"88";        
        bgLabel.tag = kGlowBGLabelTag;
        bgLabel.textAlignment = label.textAlignment;
        bgLabel.font = label.font;
        bgLabel.backgroundColor = label.backgroundColor;
        if (version > 6.1) {
            bgLabel.textColor = [UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:0.1];
        } else {
            bgLabel.textColor = [UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:0.5];
        }
        
        [cell addSubview:bgLabel];
        [bgLabel release];
        
        [cell addSubview:label];
        [label release];
    }
    else {
        //if a cell was dequeued, populate it with the relevant info and set is as unselected
        GlowLabel *label = (GlowLabel *)[cell viewWithTag:kGlowLabelTag];
        label.text = [NSString stringWithFormat:@"%@", [self.strings objectAtIndex:cellNumber]];

        [label setSelected:NO];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUM_ROWS;
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {    
    self.isSpinning = YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIScrollView *s =(UIScrollView *)[[[[self superview] superview] superview] superview];
    if ([s isKindOfClass:[UIScrollView class]]) {
        s.scrollEnabled = NO;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isSpinning = NO;
        isAnimating = NO;
        [self snap];
    }
    UIScrollView *s =(UIScrollView *)[[[[self superview] superview] superview] superview];
    if ([s isKindOfClass:[UIScrollView class]]) {
        s.scrollEnabled = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isSpinning = NO;
    isAnimating = NO;
    [self snap];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (isAnimating) {
        isAnimating = NO;
        self.isSpinning = NO;
        [self.delegate dialController:self didSnapToString:self.selectedString];
    }
    else {
        [self snap];
    }
}

#pragma mark Custom getter

- (NSInteger)selectedStringIndex {
    return [self indexOfString:self.selectedString];
}

#pragma mark Helper methods

//return the index of a string in the values
- (NSInteger)indexOfString:(NSString *)string {
    if (self.strings != nil) {
        for (NSInteger i=0; i<[self.strings count]; i++) {
            if ([(NSString *)[self.strings objectAtIndex:i] isEqualToString:string]) {
                return i;
            }
        }
    }
    return -1;
}

@end
