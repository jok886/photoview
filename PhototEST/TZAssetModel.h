//
//  TZAssetModel.h
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface TZAssetModel : NSObject


@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSString *imgurl;
@property (nonatomic, assign) NSUInteger selectedCount;
@property (nonatomic, assign) BOOL isCameraRoll;


@end

NS_ASSUME_NONNULL_END
