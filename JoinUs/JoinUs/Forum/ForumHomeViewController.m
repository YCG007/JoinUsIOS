//
//  ForumHomeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 25/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "ForumHomeViewController.h"

@interface ForumHomeViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ForumHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)segmentValueChanged:(id)sender {
//    NSLog(@"segment index: %ld", (long)self.segment.selectedSegmentIndex);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.scrollView.contentOffset = CGPointMake(self.segment.selectedSegmentIndex * self.view.bounds.size.width, 0);
    }];
//    [self onScreenViewControllerChangedToIndex:self.segment.selectedSegmentIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"offset x: %f", scrollView.contentOffset.x);
    float offset = scrollView.contentOffset.x;
    float screenWidth = self.view.bounds.size.width;
    
    int index =  (int)roundf(offset / screenWidth);
    self.segment.selectedSegmentIndex = index;
//    [self onScreenViewControllerChangedToIndex:index];
}

//- (void)onScreenViewControllerChangedToIndex:(int)index {
//    for (int i = 0; i < self.childViewControllers.count; i++) {
//        if (i == index) {
//            id childViewController = [self.childViewControllers objectAtIndex:index];
//            if ([childViewController respondsToSelector:@selector(isOnScreen)]) {
//                [childViewController performSelector:@selector(isOnScreen)];
//            }
//        } else {
//            
//        }
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
