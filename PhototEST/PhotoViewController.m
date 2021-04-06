//
//  PhotoViewController.m
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import "PhotoViewController.h"
#import "UIView+Layout.h"
#import "TZPhotoPreviewCell.h"
#import "TZAssetModel.h"
#import "LFCollectionViewFlowTrandformLayout.h"
#import "IndexCollectionCell.h"
#import "UIImageView+WebCache.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define Is_IPhoneX ((kScreenWidth >=375.0f && kScreenHeight >=812.0f )||(kScreenWidth >=812.0f && kScreenHeight >=375.0f )  ? YES : NO)

static NSString * const ID = @"cell";


@interface PhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
{
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_indexLabel;
    UIButton *_deleteButton;
    
    
    UIView *_toolBar;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    
    UIBarButtonItem *_previousButton, *_nextButton, *_actionButton;
    
    
}

/** 大海报 */
@property (nonatomic, strong) UICollectionView *previewCollectionView;

/** 海报 */
@property (nonatomic, strong) UICollectionView *thumbCollectionView;

@property (nonatomic, strong) NSIndexPath* thumbSelectedIndexPath;
@property (nonatomic, assign) CGPoint tmpThumbCenterOffset;

//@property (nonatomic, assign) int currentIndex;

@property(nonatomic, strong) NSArray *imageModelArray;

@property (nonatomic, assign) NSInteger m_dragStartX ;
@property (nonatomic, assign) NSInteger m_dragEndX  ;
@property (nonatomic, assign) NSInteger m_currentIndex;

@property(nonatomic, strong) NSLock *lock;

@property (nonatomic, assign) BOOL isHideNaviBar;


@end

@implementation PhotoViewController


-(UICollectionView *)previewCollectionView
{
    if (!_previewCollectionView ) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

        layout.itemSize = self.view.bounds.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        // 水平滑动
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
     //   layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
   
        _previewCollectionView= [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _previewCollectionView.backgroundColor = [UIColor orangeColor];
        _previewCollectionView.showsVerticalScrollIndicator = NO;
        // 分页效果
        _previewCollectionView.pagingEnabled = YES;
        _previewCollectionView.dataSource = self;
        _previewCollectionView.delegate = self;
        _previewCollectionView.showsHorizontalScrollIndicator = NO;
        // 注册
        [_previewCollectionView registerClass:[TZPhotoPreviewCell class] forCellWithReuseIdentifier:@"TZPhotoPreviewCell"];
        
      //  [_previewCollectionView registerNib:[UINib nibWithNibName:@"BigImageCell" bundle:nil] forCellWithReuseIdentifier:@"BigImageCell"];
        
        //_previewCollectionView =posterView;
        
        
        
    }
    return _previewCollectionView;
}
-(UICollectionView *)thumbCollectionView
{
    if (!_thumbCollectionView ) {
        LFCollectionViewFlowTrandformLayout *layout = [[LFCollectionViewFlowTrandformLayout alloc] init];

        layout.itemSize = CGSizeMake(70, 70);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        // 水平滑动
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGFloat margin = (kScreenWidth - 70) * 0.5;
        layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
        
       // layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
   
        CGFloat toolBarHeight = [self tz_isIPhoneX] ? 44 + (83 - 49) : 44;
        CGFloat toolBarTop = self.view.tz_height - toolBarHeight-90;
        
        
        _thumbCollectionView= [[UICollectionView alloc] initWithFrame:CGRectMake(0, toolBarTop, kScreenWidth, 90) collectionViewLayout:layout];
        _thumbCollectionView.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
        _thumbCollectionView.showsVerticalScrollIndicator = NO;
        // 分页效果
       // posterView.pagingEnabled = YES;
        _thumbCollectionView.dataSource = self;
        _thumbCollectionView.delegate = self;
        _thumbCollectionView.showsHorizontalScrollIndicator = NO;
        _thumbCollectionView.alwaysBounceHorizontal = YES;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
       // longPress.delegate = self;
        [_thumbCollectionView addGestureRecognizer:longPress];
        
        
        // 注册
     //   [_thumbCollectionView registerClass:[IndexCollectionCell class] forCellWithReuseIdentifier:@"IndexCollectionCell"];
        
        [_thumbCollectionView registerNib:[UINib nibWithNibName:@"IndexCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"IndexCollectionCell"];
        
       // _thumbCollectionView =posterView;
    }
    return _thumbCollectionView;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    
    CGPoint location = [longPress locationInView:self.thumbCollectionView];

    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath * indexPath = [self.thumbCollectionView indexPathForItemAtPoint:location];
        IndexCollectionCell *cell =(IndexCollectionCell *)[self.thumbCollectionView cellForItemAtIndexPath:indexPath];
        if (cell == nil) {
            return;
        }
        [self thumbCollectionViewCellDidSelected:indexPath];
        _tmpThumbCenterOffset = CGPointMake(cell.center.x - location.x, cell.center.y - location.y);
        [self.thumbCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
  
    }else if(longPress.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint targetlocation = CGPointMake(_tmpThumbCenterOffset.x,_tmpThumbCenterOffset.y);
        [self.thumbCollectionView updateInteractiveMovementTargetPosition:targetlocation];
        
    }else if(longPress.state == UIGestureRecognizerStateEnded){
        [self.thumbCollectionView endInteractiveMovement];
    }else{
        [self.thumbCollectionView cancelInteractiveMovement];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *data = [NSMutableArray array];
    _lock = [[NSLock alloc]init];
    
    
    NSArray *imageModelArray = @[@"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=0403008e8035965aae391e8aab2622db&src=http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc492d491153ddbb6fd52663328.jpg", @"http://img.tupianzj.com/uploads/allimg/160809/9-160P9225136.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=aa2a3126db931f9cb960475cfaa4fcaf&src=http://e.hiphotos.baidu.com/image/pic/item/14ce36d3d539b600be63e95eed50352ac75cb7ae.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812886&di=88cf9cd68db0cea47f888766691edafa&src=http://c.hiphotos.baidu.com/image/pic/item/2fdda3cc7cd98d10533d1de3253fb80e7aec9072.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=4600fd83ccadfb9c68cd41b68dc1b076&src=http://h.hiphotos.baidu.com/image/pic/item/43a7d933c895d143b233160576f082025aaf074a.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=7db76377055d28378580017fdd6d32ca&src=http://h.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11dd1855cebd12c8fcc2ce2db5.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=f976cc8b76b58298bf05d4ebbea0e0c2&src=http://d.hiphotos.baidu.com/image/pic/item/562c11dfa9ec8a13f075f10cf303918fa1ecc0eb.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=73ef06f6a34435481c5c2976d982ca77&src=http://a.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11daf25f19bc12c8fcc3ce2d46.jpg",@"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=0403008e8035965aae391e8aab2622db&src=http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc492d491153ddbb6fd52663328.jpg", @"http://img.tupianzj.com/uploads/allimg/160809/9-160P9225136.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=aa2a3126db931f9cb960475cfaa4fcaf&src=http://e.hiphotos.baidu.com/image/pic/item/14ce36d3d539b600be63e95eed50352ac75cb7ae.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812886&di=88cf9cd68db0cea47f888766691edafa&src=http://c.hiphotos.baidu.com/image/pic/item/2fdda3cc7cd98d10533d1de3253fb80e7aec9072.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470812555&di=4600fd83ccadfb9c68cd41b68dc1b076&src=http://h.hiphotos.baidu.com/image/pic/item/43a7d933c895d143b233160576f082025aaf074a.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=7db76377055d28378580017fdd6d32ca&src=http://h.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11dd1855cebd12c8fcc2ce2db5.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=f976cc8b76b58298bf05d4ebbea0e0c2&src=http://d.hiphotos.baidu.com/image/pic/item/562c11dfa9ec8a13f075f10cf303918fa1ecc0eb.jpg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1470907473&di=73ef06f6a34435481c5c2976d982ca77&src=http://a.hiphotos.baidu.com/image/pic/item/f9dcd100baa1cd11daf25f19bc12c8fcc3ce2d46.jpg"];
    
    for (int i=0; i<16; i++) {
        TZAssetModel *mode = [[TZAssetModel alloc]init];
        mode.imgurl = imageModelArray[i];
        [data addObject:mode];
    }
    
    self.models = data;
    
    
   //  [self.view addSubview:_thumbCollectionView];
  
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.previewCollectionView];
    [self.view addSubview:self.thumbCollectionView];
    [_previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    
    [self.previewCollectionView reloadData];
    [self.thumbCollectionView reloadData];
 
    
    [self configCustomNaviBar];
    [self configBottomToolBar];
    self.view.clipsToBounds = YES;
    
    
    [self.view bringSubviewToFront:_naviBar];
    [self.view bringSubviewToFront:_toolBar];
    
    

}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self refreshNaviBarAndBottomBarState];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}
- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)configCustomNaviBar {
    
    _naviBar = [[UIView alloc] initWithFrame:CGRectZero];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_backButton setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.adjustsFontSizeToFitWidth = YES;
    _indexLabel.font = [UIFont systemFontOfSize:14];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_deleteButton setImage:[UIImage imageNamed:@"delete_photo"] forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [_naviBar addSubview:_indexLabel];
    [_naviBar addSubview:_backButton];
    [_naviBar addSubview:_deleteButton];
    [self.view addSubview:_naviBar];
    
}



- (void)deleteButtonClick
{
   // [self.models removeObjectAtIndex:_currentIndex];
    
    int count= self.models.count;
    
    [self.models removeObjectAtIndex:_currentIndex];
    
    int count2 = self.models.count;
    NSLog(@"--%d--%d",count,count2);
    
    [self.thumbCollectionView reloadData];
    [self.previewCollectionView reloadData];
    
}
- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    
   // UIToolbar
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
   // [_doneButton setTitle:@"test" forState:UIControlStateNormal];
    
   // square.and.arrow.up
    if (@available(iOS 13.0, *)) {
        [_doneButton setImage:[UIImage systemImageNamed:@"square.and.arrow.up"] forState:UIControlStateNormal];
        _doneButton.tintColor = [UIColor whiteColor];
        
    } else {
        // Fallback on earlier versions
        [_doneButton setTitle:@"share" forState:UIControlStateNormal];
    }
    
    [_doneButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_toolBar addSubview:_doneButton];
    
    
  
    
    
    
    [self.view addSubview:_toolBar];
}
- (void)doneButtonClick
{
    NSLog(@"点击了toolbar的按钮");
}

- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar;
    _thumbCollectionView.hidden = self.isHideNaviBar;
}
- (BOOL)tz_isIPhoneX {
    return Is_IPhoneX;
}

- (CGFloat)tz_statusBarHeight {
    return [self tz_isIPhoneX] ? 44 : 20;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    BOOL isFullScreen = self.view.tz_height == [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = isFullScreen ? [self tz_statusBarHeight] : 0;
    CGFloat statusBarHeightInterval = isFullScreen ? (statusBarHeight - 20) : 0;
    CGFloat naviBarHeight = statusBarHeight + 64;
    _naviBar.frame = CGRectMake(0, 0, self.view.tz_width, naviBarHeight);
    _backButton.frame = CGRectMake(10, 10 + statusBarHeightInterval, 44, 44);
    _deleteButton.frame = CGRectMake(self.view.tz_width -10-60, 10 + statusBarHeightInterval, 60, 60);
    //_selectButton.frame = CGRectMake(self.view.tz_width - 56, 10 + statusBarHeightInterval, 44, 44);
    _indexLabel.frame = CGRectMake(self.view.tz_width / 2 -50, 10 + statusBarHeightInterval, 100, 44);
    
    CGFloat toolBarHeight = [self tz_isIPhoneX] ? 44 + (83 - 49) : 44;
    CGFloat toolBarTop = self.view.tz_height - toolBarHeight;
    _toolBar.frame = CGRectMake(0, toolBarTop, self.view.tz_width, toolBarHeight);
    
    
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.tz_width - 60 - 12, 0, 60, 60);
    
    
    
}
- (void)refreshNaviBarAndBottomBarState {
    NSString *index = [NSString stringWithFormat:@"%d", (int)(_currentIndex+ 1)];
    _indexLabel.text = index;
    _indexLabel.hidden = NO;
}
-(void)thumbCollectionViewCellDidSelected:(NSIndexPath *)indexpath
{
    if (_thumbSelectedIndexPath != nil) {
        IndexCollectionCell *beforecell =(IndexCollectionCell *)[self.thumbCollectionView cellForItemAtIndexPath:_thumbSelectedIndexPath];
        beforecell.layer.borderColor = [UIColor clearColor].CGColor;
        beforecell.layer.borderWidth = 0;
    }else{
        [self.thumbCollectionView reloadData ];
    }
    _thumbSelectedIndexPath = indexpath;
    IndexCollectionCell *cell =(IndexCollectionCell *)[self.thumbCollectionView cellForItemAtIndexPath:indexpath];
    cell.layer.borderColor = [UIColor redColor].CGColor;
    cell.layer.borderWidth = 2;
    /// 滚动到正确的位置
    [self.thumbCollectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [self refreshNaviBarAndBottomBarState];
    
}


#pragma mark - 数据源<UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return  self.models.count;
    /*if (collectionView == _previewCollectionView) {
        return self.imageModelArray.count;
    }else{
        return self.imageModelArray.count;
    }*/
    
    
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _previewCollectionView) {
        static NSString *identify = @"cell";
       // BigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
        
        TZPhotoPreviewCell *cell = (TZPhotoPreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TZPhotoPreviewCell class]) forIndexPath:indexPath];
        TZAssetModel *mode =self.models[indexPath.row];
        cell.model = mode;
     
        __weak typeof(self) weakSelf = self;
        
        [cell setSingleTapGestureBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf didTapPreviewCell];
        }];
        
        return cell;
        
    }else{
     //   IndexCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IndexCollectionCell" forIndexPath:indexPath];
        
        IndexCollectionCell *cell = (IndexCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([IndexCollectionCell class]) forIndexPath:indexPath];
        TZAssetModel *mode =self.models[indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:mode.imgurl]];
        
        if (_currentIndex == indexPath.row) {
            cell.layer.borderColor = [UIColor redColor].CGColor;
            cell.layer.borderWidth = 2;
        }else{
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 0;
        }
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _thumbCollectionView) {
        return CGSizeMake(70,70);
    }else{
        return CGSizeMake(kScreenWidth, kScreenHeight);
    }
   
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
   
    if (collectionView == _thumbCollectionView) {
        
        CGFloat margin = (kScreenWidth - 70) * 0.5;
       // layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
        return UIEdgeInsetsMake(0,margin, 0, margin);
    }else{
        return UIEdgeInsetsMake(0,0, 0, 0);
    }
    //自定义item的UIEdgeInsets
   
}

//横向间距
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
//纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
// 选择
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _thumbCollectionView) {
        [_lock lock];
        
        [self  thumbCollectionViewCellDidSelected:indexPath];
        [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [_lock unlock];
    }else{
        
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _thumbCollectionView) {
        IndexCollectionCell *cell =(IndexCollectionCell *)[self.thumbCollectionView cellForItemAtIndexPath:indexPath];
        if (cell !=nil) {
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 0;
        }else{
            [self.thumbCollectionView reloadData];
        }
        
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _thumbCollectionView) {
        return YES;
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (collectionView == _thumbCollectionView) {
        
        NSLog(@"moveItemAtIndexPath---%ld",destinationIndexPath.row);
        
    }else{
        
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _previewCollectionView) {
        int wid = scrollView.bounds.size.width;
        _currentIndex = (int)(round(scrollView.contentOffset.x / wid));
        if (_currentIndex >= _models.count) {
            _currentIndex = _models.count - 1;
        }else if(_currentIndex < 0 ){
            _currentIndex = 0;
        }
        
        [self refreshNaviBarAndBottomBarState];
        
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:_currentIndex inSection:0];
        

        
        
        if (indexPath != nil) {
            [self  thumbCollectionViewCellDidSelected:indexPath];
        }else{
            if (_thumbSelectedIndexPath != nil) {
                [self  thumbCollectionViewCellDidSelected:_thumbSelectedIndexPath];
            }
        }
 
    }
}

//手指拖动开始
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.m_dragStartX = scrollView.contentOffset.x;
}
//手指拖动停止
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.m_dragEndX = scrollView.contentOffset.x;
    
    NSInteger newIndex = scrollView.contentOffset.x/kScreenWidth;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
       // [self fixCellToCenter];
    });
    
    if (scrollView == _thumbCollectionView) {
        [_lock lock];
        _currentIndex=(int)scrollView.contentOffset.x/70+0.5;
        NSLog(@"--第几个--%d",_currentIndex);
        
        if (_currentIndex >= _models.count) {
            _currentIndex = _models.count - 1;
        }else if(_currentIndex < 0 ){
            _currentIndex = 0;
        }
        

        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:_currentIndex inSection:0];
        if (indexPath != nil && indexPath !=_thumbSelectedIndexPath) {
            [self  thumbCollectionViewCellDidSelected:indexPath];
            [self.previewCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        [_lock unlock];
    }
   
    
    
}
/*
//配置cell居中
- (void)fixCellToCenter {
    //最小滚动距离
    float dragMiniDistance = self.view.bounds.size.width/20.0f;
    if (self.m_dragStartX -  self.m_dragEndX >= dragMiniDistance) {
        self.m_currentIndex -= 1;//向右
    }else if(self.m_dragEndX -  self.m_dragStartX >= dragMiniDistance){
        self.m_currentIndex += 1;//向左
    }
    NSInteger maxIndex = [_thumbCollectionView numberOfItemsInSection:0] - 1;
    
    
    self.m_currentIndex = self.m_currentIndex <= 0 ? 0 : self.m_currentIndex;
    self.m_currentIndex = self.m_currentIndex >= maxIndex ? maxIndex : self.m_currentIndex;
    
    
    [_thumbCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.m_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.m_currentIndex == [self.imageModelArray count]/4*3) {
        NSIndexPath *path  = [NSIndexPath indexPathForItem:[self.imageModelArray count]/2 inSection:0];
        [self.thumbCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.m_currentIndex = [self.imageModelArray count]/2;
    }
    else if(self.m_currentIndex == [self.imageModelArray count]/4){
        NSIndexPath *path = [NSIndexPath indexPathForItem:[self.imageModelArray count]/2 inSection:0];
      //  [self  thumbCollectionViewCellDidSelected:path];
        
        [self.thumbCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.m_currentIndex = [self.imageModelArray count]/2;
    }
}
*/

@end
