//
//  TZPhotoPreviewCell.h
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TZAssetModel,TZProgressView,TZPhotoPreviewView;

@interface TZPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;



@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) TZPhotoPreviewView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL scaleAspectFillCrop;

- (void)recoverSubviews;


@end


@interface TZPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
//@property (nonatomic, strong) TZProgressView *progressView;
@property (nonatomic, strong) UIImageView *iCloudErrorIcon;
@property (nonatomic, strong) UILabel *iCloudErrorLabel;
@property (nonatomic, copy) void (^iCloudSyncFailedHandle)(id asset, BOOL isSyncFailed);


@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL scaleAspectFillCrop;
@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubviews;
@end


NS_ASSUME_NONNULL_END
