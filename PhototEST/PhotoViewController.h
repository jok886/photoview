//
//  PhotoViewController.h
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *models;                  ///< All photo models / 所有图片模型数组
@property (nonatomic, strong) NSMutableArray *photos;                  ///< All photos  / 所有图片数组
@property (nonatomic, assign) NSInteger currentIndex;           ///< Index of the photo user click / 用户点击的图片的索引
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;       ///< If YES,return original photo / 是否返回原图
@property (nonatomic, assign) BOOL isCropImage;


@end

NS_ASSUME_NONNULL_END
