//
//  KnotableCellProtocal.h
//  Knotable
//
//  Created by backup on 14-2-26.
//
//
typedef enum _InfoType
{
    InfoOffline,
    InfoWarrning,
}InfoType;

@protocol KnotableCellProtocal
@property (nonatomic, assign) BOOL offline;
@required
@property (nonatomic, strong) UIActivityIndicatorView *processView;
@property (assign, assign) NSInteger processRetainCount;
- (void)showProcess;
- (void)stopProcess;
- (void)showInfo:(InfoType)type;
- (void)hiddenInfo;
@end