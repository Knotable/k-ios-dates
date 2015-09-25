//
//  BaseViewController.m
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import "BaseViewController.h"

#import "Constant.h"
#import "AppDelegate.h"
#import "UIImage+Retina4.h"

#import "FileInfo.h"
#import "ServerConfig.h"
#import "DataManager.h"

#import "MCAWSS3Client.h"
#import "CTAssetsPickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define SUPPORT_MULTI_SELECT_PHOTES     1
#define K_MAX_UPLOAD_COUNT              5

#define kMaxUploadAlertMessage          [NSString stringWithFormat:@"You can only attach %d photos at once for now.", K_MAX_UPLOAD_COUNT]

@interface BaseViewController ()
<
UIActionSheetDelegate,
CTAssetsPickerControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
{
    NSInteger cameraIdx, photoLibIdx, savedPhotosIdx, lastPhotoIdx;
}
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) BOOL imageIsPNG;
@property (nonatomic, strong) UIAlertView *titleAlert;
@end

@implementation BaseViewController

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
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
#endif
    
    if (!_contentView)
    {
        self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:self.contentView];
    }
    
    [self performSelector:@selector(requestAccessToCalendarEvents) withObject:nil afterDelay:0.4];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onKeynoteClicked:(BOOL)bSelected
{

}

#pragma mark -
#pragma mark - Access Calendar

- (void)requestAccessToCalendarEvents {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.calendarEventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent
        completion:^(BOOL granted, NSError *error) {
            if (!error && granted) {
                appDelegate.calendarEventManager.eventsAccessGranted = granted;
                [appDelegate.calendarEventManager getNextEvent];
            } else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
     ];
}

#pragma mark -
#pragma mark - Access Photo Library

-(void)onAddPicture:(id)obj
{
    NSLog(@"onAddPicture");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    cameraIdx = photoLibIdx = savedPhotosIdx = lastPhotoIdx = -1;

    lastPhotoIdx = [actionSheet addButtonWithTitle:@"Use Last Photo"];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        cameraIdx = [actionSheet addButtonWithTitle:@"Take Photo"];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        photoLibIdx = [actionSheet addButtonWithTitle:@"Photo Library"];
    }
    
    NSUInteger idx = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet setCancelButtonIndex:idx];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d camera index: %d photo library index: %d saved photos index: %d", (int)buttonIndex, (int)cameraIdx, (int)photoLibIdx, (int)savedPhotosIdx);

    UIImagePickerControllerSourceType sourceType;
    
    BOOL useLastPhoto = NO;
    
    if(buttonIndex == lastPhotoIdx)
    {
        useLastPhoto = YES;
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if(buttonIndex == cameraIdx)
    {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if(buttonIndex == photoLibIdx)
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if(buttonIndex == savedPhotosIdx)
    {
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    else
    {
        return;
    }

    if(useLastPhoto)
    {
        if (IMAGELIMITATION)
        {
            if ([self.cNewNote.imageArray count] < K_MAX_UPLOAD_COUNT)
            {
                [self grabLastPhoto];
                
                return;
            }
            else
            {
                [[AppDelegate sharedDelegate] HideAlert:@"Alert" messageContent:kMaxUploadAlertMessage withDelay:2.0f];
                
                return;
            }
        }
        else
        {
            [self grabLastPhoto];
            
            return;
        }
    }


#if SUPPORT_MULTI_SELECT_PHOTES
    
    NSLog(@"support multiple photo selection");
    
    if (buttonIndex == photoLibIdx
        || buttonIndex == savedPhotosIdx)
    {
        NSLog(@"presenting CTAssetsPickerController");
        
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.assetsFilter = [ALAssetsFilter allAssets];
        picker.delegate = self;

        if (IMAGELIMITATION)
        {
            if ([self.cNewNote.imageArray count] < K_MAX_UPLOAD_COUNT)
            {
                [self presentViewController:picker animated:YES completion:NULL];
                
                return;
            }
            else
            {
                [[AppDelegate sharedDelegate] HideAlert:@"Alert" messageContent:kMaxUploadAlertMessage withDelay:2.0f];
                
                return;
            }
        }
        else
        {
            [self presentViewController:picker animated:YES completion:NULL];
            
            return;
        }
    }
    else
    {
        NSLog(@"not presenting CTAssetsPickerController");
    }
#endif

    NSLog(@"presenting UIImagePickerController");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    if (IMAGELIMITATION)
    {
        if ([self.cNewNote.imageArray count] < K_MAX_UPLOAD_COUNT)
        {
            [self presentViewController:picker animated:YES completion:Nil];
            
            return;
        }
        else
        {
            [[AppDelegate sharedDelegate] HideAlert:@"Alert" messageContent:kMaxUploadAlertMessage withDelay:2.0f];
            
            return;
        }
    }
    else
    {
        [self presentViewController:picker animated:YES completion:^{
            NSLog(@"done presenting image picker");
        }];
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"didFinishPickingMedia info: %@", info);
    __block FileInfo *fInfo = [[FileInfo alloc] init];
    fInfo.image = info[UIImagePickerControllerOriginalImage];
    
    //NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    
    NSDictionary *mediaMetadata = info[UIImagePickerControllerMediaMetadata];
    if (mediaMetadata) {
        //image is from the camera
        
        NSString *filename = [NSString stringWithFormat:@"%lld.jpg", (long long)[[NSDate date] timeIntervalSince1970]];
        NSLog(@"filename %@", filename);
        
        fInfo.imageName = [filename lowercaseString];
        fInfo.isPNG = NO;
        fInfo.imageOrientation = ((NSNumber *)mediaMetadata[@"Orientation"]).intValue;
    }
    
    if (IMAGELIMITATION)
    {
        if ([self.cNewNote.imageArray count] < K_MAX_UPLOAD_COUNT)
        {
            [FileManager beginUploadingFile:fInfo];
            
            [self.cNewNote addImageInfo:fInfo];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else
        {
            [picker dismissViewControllerAnimated:YES completion:^{
                [[AppDelegate sharedDelegate] HideAlert:@"Alert" messageContent:kMaxUploadAlertMessage withDelay:2.0f];
            }];
            
            return;
        }
    }
    else
    {
        [FileManager beginUploadingFile:fInfo];
        
        [self.cNewNote addImageInfo:fInfo];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    BOOL    retVal = YES;
    
    NSLog(@"Image count : %lu", (unsigned long)[picker.selectedAssets count]);
    
    if (IMAGELIMITATION)
    {
        if ([picker.selectedAssets count] >= K_MAX_UPLOAD_COUNT)
        {
            retVal = NO;
            
            [[AppDelegate sharedDelegate] HideAlert:@"Alert" messageContent:kMaxUploadAlertMessage withDelay:2.0f];
        }
    }
    else
    {
        retVal = YES;
    }
    
    return  retVal;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectAsset:(ALAsset *)asset
{
    
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    __block NSArray *bloackAssertsArr = assets;
    
    double delayInSeconds = 0.1f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSMutableArray *fInfoArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (ALAsset *asset in bloackAssertsArr)
        {
            FileInfo *fInfo = [FileInfo fileInfoForAsset:asset];
            [fInfoArray addObject:fInfo];
            [FileManager beginUploadingFile:fInfo];
            //    [representation fullScreenImage];
        }
        [self.currentView addImageInfos:fInfoArray];
    });
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)grabLastPhoto
{
    ALAssetsLibrary *library = [DataManager sharedInstance].assetsLibrary;
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(!group) return;
        
        BOOL isSavedPhotos = ((NSNumber *)[group valueForProperty:ALAssetsGroupPropertyType]).integerValue == ALAssetsGroupSavedPhotos;
        
        if(!isSavedPhotos) return;
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        NSInteger count = [group numberOfAssets];
        
        if(count < 1) return;
        
        NSUInteger lastIndex = (NSUInteger)(count - 1);
        
        [group enumerateAssetsAtIndexes:[[NSIndexSet alloc] initWithIndex:lastIndex] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
            if(!result) return;
            FileInfo *fInfo = [FileInfo fileInfoForAsset:result];
            [FileManager beginUploadingFile:fInfo];
            [self.cNewNote addImageInfo:fInfo];

            *innerStop = YES;
        }];
        
        *stop = YES;
    } failureBlock:^(NSError *error) {
        NSLog(@"Failure getting last photo: %@", error);
        
    }];
}

#pragma mark ComposeNewNoteDelegate
-(void)infoItemTaped:(NSString *)userName sender:(id)sender
{
    //
}
-(void)infoItemTaped:(id)obj
{
    //
}
@end
