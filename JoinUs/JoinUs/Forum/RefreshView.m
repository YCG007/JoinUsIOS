//
//  RefreshView.m
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "RefreshView.h"

@implementation RefreshView {
    float _progress;
    BOOL _isRefreshing;
    UIImageView* _background;
    UIImageView* _backgroundBlack;
    UIImageView* _bomb;
    CAEmitterLayer* _emitterLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _progress = 0;
    _isRefreshing = NO;
    
    _backgroundBlack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_background_black"]];
    [self addSubview:_backgroundBlack];
    _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_background"]];
    [self addSubview:_background];
    _bomb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_bomb"]];
    [self addSubview:_bomb];
    
    _emitterLayer = [CAEmitterLayer layer];
    _emitterLayer.emitterPosition = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + 20);
    _emitterLayer.emitterSize = CGSizeMake(self.bounds.size.width, 80);
    _emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    
    _emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
    CAEmitterCell *emitterCell1 = [CAEmitterCell emitterCell];
    emitterCell1.birthRate = 50;
    emitterCell1.lifetime = 2.0;
    emitterCell1.lifetimeRange = 1.0;
    
    emitterCell1.scale = 0.5;
    emitterCell1.scaleRange = 0.5;
    emitterCell1.scaleSpeed = -1.0;
    
    emitterCell1.alphaSpeed = -1.0;
    emitterCell1.alphaRange = 0.2;
    
    emitterCell1.spin = 0.5;
    emitterCell1.spinRange = 1;
    
    emitterCell1.contents =  (id)[[UIImage imageNamed:@"refresh_explosion_2"] CGImage];
    
    CAEmitterCell *emitterCell2 = [CAEmitterCell emitterCell];
    emitterCell2.birthRate = 30;
    emitterCell2.lifetime = 1.0;
    emitterCell2.lifetimeRange = 1.0;
    
    emitterCell2.scale = 0.5;
    emitterCell2.scaleRange = 0.5;
    emitterCell2.scaleSpeed = -1.0;
    
    emitterCell2.alphaSpeed = -1.0;
    emitterCell2.alphaRange = 0.2;
    
    emitterCell2.spin = 2;
    emitterCell2.spinRange = 2;
    
    emitterCell2.contents =  (id)[[UIImage imageNamed:@"refresh_explosion_3"] CGImage];
    
    _emitterLayer.emitterCells = @[emitterCell1, emitterCell2];
    
}

- (void)setVisibleHeight:(float)visibleHeight {
    if (!_isRefreshing) {
        _progress = MIN(1, visibleHeight / kRefreshViewHeight);
        _progress = MAX(0, _progress);
    } else {
        _progress = 1.0f;
    }
//    NSLog(@"progress: %f", _progress);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0 - _progress];
    _background.frame = CGRectMake(0, 160 - _progress * 160, _background.frame.size.width, _background.frame.size.height);
    _backgroundBlack.frame = CGRectMake(0, 160 - _progress * 160, _backgroundBlack.frame.size.width, _backgroundBlack.frame.size.height);
    _bomb.center = CGPointMake(self.frame.size.width / 2, 87 - 480 + _progress * 480);
}

- (void)beginRefreshing {
    _isRefreshing = YES;
    _bomb.hidden = YES;
    [self.layer addSublayer:_emitterLayer];
    [UIView animateWithDuration:1.0f animations:^{
        _background.alpha = 0.0f;
    }];
}

- (void)endRefreshing {
    [_emitterLayer removeFromSuperlayer];
}

- (void)reset {
    _isRefreshing = NO;
    _bomb.hidden = NO;
    _background.alpha = 1.0f;
}


@end
