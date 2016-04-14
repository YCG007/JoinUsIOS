//
//  CoreAnimationViewController.m
//  JoinUs
//
//  Created by Liang Qian on 14/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CoreAnimationViewController.h"
#import "GMDCircleLoader.h"

@interface CoreAnimationViewController ()
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myViewTop;

@end

@implementation CoreAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)a1ButtonPressed:(id)sender {
    

//    [UIView animateWithDuration:1.0f animations:^{
////        self.myView.frame = CGRectMake(100, 300, 200, 200);
//        self.myView.alpha = 0.0f;
//        self.myViewTop.constant = 100;
//        [self.view layoutIfNeeded];
//    }];
    
//    [UIView animateWithDuration:1.0f animations:^{
//        self.myViewTop.constant = 100;
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        NSLog(@"Animaiton finished!");
//    }];
//    
//    [UIView animateWithDuration:1.0f delay:1.0f options:UIViewAnimationOptionAutoreverse animations:^{
//        self.myViewTop.constant = 347;
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        //
//    }];
    
//    for (NSLayoutConstraint* co in self.view.constraints) {
//        if ([co.identifier isEqualToString:@"myViewTop"]) {
//            co.constant = 100;
//        }
//    }
//    
//    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.2f initialSpringVelocity:10.0f options:0 animations:^{
////        self.myViewTop.constant = 100;
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        //
//    }];
    
//    UIBezierPath* path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(10, 50)];
//    [path addLineToPoint:CGPointMake(90, 50)];
//    
//    CAShapeLayer* shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = path.CGPath;
//    shapeLayer.fillColor = [UIColor clearColor].CGColor;
//    shapeLayer.strokeColor = [UIColor redColor].CGColor;
//    shapeLayer.lineWidth = 3;
//    shapeLayer.lineCap = kCALineCapRound;
//    
//    [self.myView.layer addSublayer:shapeLayer];
//    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    animation.duration = 1.5f;
//    animation.fromValue = @0.0f;
//    animation.toValue = @1.0f;
////    animation.repeatCount = HUGE_VALF;
////    animation.autoreverses = YES;
//    [shapeLayer addAnimation:animation forKey:@"strokeEnd"];
//    
//    float popUpSize = 100;
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(popUpSize/2, popUpSize/2) radius:popUpSize/2 - 10 startAngle:0 endAngle:M_PI*2 clockwise:YES];
//    
//
//    
//    [path moveToPoint:CGPointMake(popUpSize/4, popUpSize/2)];
//    CGPoint p1 = CGPointMake(popUpSize/4+10, popUpSize/2+10);
//    [path addLineToPoint:p1];
//    
//    CGPoint p2 = CGPointMake(popUpSize/4*3, popUpSize/4);
//    [path addLineToPoint:p2];
//    
//    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//    layer.fillColor = [UIColor clearColor].CGColor;
//    layer.strokeColor = [UIColor greenColor].CGColor;
//    layer.lineWidth = 5;
//    layer.lineCap = kCALineCapRound;
//    layer.lineJoin = kCALineCapRound;
//    layer.path = path.CGPath;
//    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
//    animation.fromValue = @0;
//    animation.toValue = @1.0;
//    animation.duration = 0.5;
//    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
//
//    [_myView.layer addSublayer:layer];
    
    [GMDCircleLoader setOnView:self.view withTitle:@"Loading..." animated:YES];
}

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
