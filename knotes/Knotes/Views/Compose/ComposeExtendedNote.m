//
//  ComposeExtendedNote.m
//  Knotable
//
//  Created by Donald Pae on 1/26/14.
//
//

#import "ComposeExtendedNote.h"
#import "FileInfo.h"
#import "InputAccessViewManager.h"

@interface ComposeExtendedNote ()
@end
@implementation ComposeExtendedNote

@synthesize keynoteSelected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        keynoteSelected = NO;
        _showKeynote = NO;
    }
    return self;
}

- (void)onKeynote:(id) sender
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)sender;
    keynoteSelected = !keynoteSelected;
    
    UIImage *img = nil;
    
    if (self.keynoteSelected)
    {
        img = [UIImage imageNamed:@"keyknote-selected"];
    }
    else
    {
        img = [UIImage imageNamed:@"keyknote"];
    }
    
    [cell setShowImage:img withContentMode:UIViewContentModeCenter];

    [self.delegate onKeynoteClicked:keynoteSelected];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_showKeynote) {
        return [self.imageArray count] + 2;
    } else {
        return [self.imageArray count];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if ([indexPath row]==[self.imageArray count]) {
        [self onAddImage:cell];
    } else if ([indexPath row] == [self.imageArray count] + 1){
        [self onKeynote:cell];
    } else {
        if (self.opType == ItemAdd) {
            [self.delegate infoItemTaped:self.imageArray[indexPath.row]];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.hidden = NO;
    cell.tag = indexPath.row;
    
    UIImage *img = nil;
    
    if ([indexPath row]<[self.imageArray count])
    {
        FileInfo *fInfo = (FileInfo *)[self.imageArray objectAtIndex:[indexPath row]];
        
        img = fInfo.image;
        
        NSLog(@"Image Size : %@", NSStringFromCGSize(img.size));
        NSLog(@"Cell Size : %@", NSStringFromCGSize(cell.bounds.size));
        
        if (img.size.width > cell.bounds.size.width
            || img.size.height>cell.bounds.size.height)
        {
            [cell setShowImage:img withContentMode:UIViewContentModeScaleAspectFit];
        }
        else
        {
            [cell setShowImage:img withContentMode:UIViewContentModeScaleToFill];
        }
        
        cell.info = fInfo;
        fInfo.cell = cell;
        cell.showBoard = NO;
        if (self.opType == ItemAdd) {
            [cell setOperatorDelete];
        }
    }
    else if ([indexPath row] == [self.imageArray count])
    {
        img = [UIImage imageNamed:@"camera-icon-selected"];
        cell.showBoard = NO;
        [cell setShowImage:img withContentMode:UIViewContentModeCenter];
        cell.info = nil;
    }
    else
    {
        if (self.keynoteSelected)
        {
            img = [UIImage imageNamed:@"keyknote-selected"];
        }
        else
        {
            img = [UIImage imageNamed:@"keyknote"];
        }
        
        cell.showBoard = NO;
        
        [cell setShowImage:img withContentMode:UIViewContentModeCenter];
        
    }
    
    cell.selected = YES;
    
    return cell;
}

//-(BOOL)becomeFirstResponder
//{
//    [super becomeFirstResponder];
//    
//    if (self.titleTextField && self.titleTextField.hidden == NO)
//    {
//        [self.titleTextField becomeFirstResponder];
//    }
//    else
//    {
//        [self.richTextView becomeFirstResponder];
//    }
//    return [self.textView becomeFirstResponder];
//}

@end
