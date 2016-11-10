//
//  WaveWaterView.m
//  WaveWaterProgress
//
//  Created by my on 2016/11/9.
//  Copyright © 2016年 my. All rights reserved.
//

#import "MLMWaveWaterView.h"


@interface MLMWaveWaterView ()
{
    CAShapeLayer *topLayer;
    CAShapeLayer *bottomLayer;

    CGFloat _wave_offsety;//根据进度计算(波峰所在位置的y坐标)
    CGFloat _offsety_scale;//上升的速度
    
    CGFloat _wave_move_width;//移动的距离，配合速率设置
    
    CGFloat _wave_offsetx;//偏移,animation
    
    CADisplayLink *_waveDisplaylink;
    
}

@end

@implementation MLMWaveWaterView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        [self initView];
    }

    [self drowWave];
    return self;
}

#pragma mark - initView
- (void)initView {

    
    _wave_Amplitude = self.frame.size.width/20;
    _wave_Cycle = 2*M_PI/(self.frame.size.width * .9);
    
    
    _wave_distance = 2*M_PI/_wave_Cycle * .8;
    
    _wave_move_width = 0.5;
    
    _wave_scale = 0.5;
    
    _offsety_scale = 0.01;
    
    _topColor = [UIColor colorWithRed:79/255.0 green:240/255.0 blue:255/255.0 alpha:1];
    _bottomColor = [UIColor colorWithRed:79/255.0 green:240/255.0 blue:255/255.0 alpha:.3];
    
    _progress_animation = YES;
    _wave_offsety = (1-_progress) * (self.frame.size.height + 2* _wave_Amplitude);
    [self startWave];
}

#pragma mark - animation
- (void)changeoff {
    _wave_offsetx += _wave_move_width*_wave_scale;
    [self drowWave];
}

#pragma mark - draw layer
- (void)drawLayer:(CAShapeLayer *)layer offsetY:(CGFloat)offsetY {
    
    //波浪动画，所以进度的实际操作范围是，多加上两个振幅的高度,到达设置进度的位置y坐标
    CGFloat end_offY = (1-_progress) * (self.frame.size.height + 2* _wave_Amplitude);
    if (_progress_animation) {
        if (_wave_offsety != end_offY) {
            if (end_offY < _wave_offsety) {//上升
                _wave_offsety = MAX(_wave_offsety-=(_wave_offsety - end_offY)*_offsety_scale, end_offY);
            } else {
                _wave_offsety = MIN(_wave_offsety+=(end_offY-_wave_offsety)*_offsety_scale, end_offY);
            }
        }
    } else {
        _wave_offsety = end_offY;
    }

    CGMutablePathRef path = CGPathCreateMutable();
    for (float next_x= 0.f; next_x <= self.frame.size.width; next_x ++) {
        //正弦函数
        CGFloat next_y = _wave_Amplitude * sin(_wave_Cycle*next_x + _wave_offsetx + offsetY/200*2*M_PI) + _wave_offsety;
        if (next_x == 0) {
            CGPathMoveToPoint(path, nil, next_x, next_y - _wave_Amplitude);
        } else {
            CGPathAddLineToPoint(path, nil, next_x, next_y- _wave_Amplitude);
        }
    }
    
    CGPathAddLineToPoint(path, nil, self.frame.size.width, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    layer.path = path;
    CGPathRelease(path);
}

#pragma mark - after setter
- (void)drowWave {
    topLayer.fillColor = _topColor.CGColor;
    bottomLayer.fillColor = _bottomColor.CGColor;
    
    [self drawLayer:topLayer offsetY:0];
    [self drawLayer:bottomLayer offsetY:_wave_distance];
    
}



#pragma mark - setter
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self drowWave];
}

- (void)setWave_Amplitude:(CGFloat)wave_Amplitude {
    _wave_Amplitude = wave_Amplitude;
    [self drowWave];
}

- (void)setWave_Cycle:(CGFloat)wave_Cycle {
    _wave_Cycle = wave_Cycle;
    [self drowWave];
}

- (void)setWave_distance:(CGFloat)wave_distance {
    _wave_distance = wave_distance;
    [self drawLayer:bottomLayer offsetY:_wave_distance];
}

- (void)setWave_scale:(CGFloat)wave_scale {
    _wave_scale = wave_scale;
}

#pragma mark - reStart
- (void)startWave {
    if (!bottomLayer) {
        bottomLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:bottomLayer];
    }
    
    if (!topLayer) {
        topLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:topLayer];
    }
    
    if (!_waveDisplaylink) {
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeoff)];
        [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)dealloc {
    if (_waveDisplaylink) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
    }
    
    if (topLayer) {
        [topLayer removeFromSuperlayer];
        topLayer = nil;
    }
    if (bottomLayer) {
        [bottomLayer removeFromSuperlayer];
        bottomLayer = nil;
    }
}

@end