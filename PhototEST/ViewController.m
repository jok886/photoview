//
//  ViewController.m
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import "ViewController.h"
#import "PhotoViewController.h"


@interface ViewController ()

@end

@implementation ViewController
- (IBAction)openphoto:(id)sender {
    PhotoViewController *previewVc = [[PhotoViewController alloc]init];
    //previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
    previewVc.currentIndex = 3;
    
    [self.navigationController pushViewController:previewVc animated:YES];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  
    
    
    
}

@end
