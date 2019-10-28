//
//  LLOscillogramView.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/15.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLOscillogramView.h"
#import "LLMacros.h"
#import "UIColor+LL_Utils.h"

@implementation LLPoint

@end

@interface LLOscillogramView()<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat kStartX;

@property (nonatomic, strong) NSMutableArray *pointList;
@property (nonatomic, strong) NSMutableArray *pointLayerList;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UILabel *lowValueLabel;
@property (nonatomic, strong) UILabel *highValueLabel;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) UILabel       *tipLabel;

@end

@implementation LLOscillogramView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _kStartX = kLLSizeFrom750_Landscape(52);
        
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.clipsToBounds = NO;
        
        _strokeColor = [UIColor orangeColor];
        _numberOfPoints = 12;
        _pointList = [NSMutableArray array];
        _pointLayerList = [NSMutableArray array];
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(_kStartX, self.frame.size.height-kLLSizeFrom750_Landscape(1), self.frame.size.width, kLLSizeFrom750_Landscape(1))];
        _bottomLine.backgroundColor = [UIColor ll_colorWithHex:0x999999 andAlpha:1.0];
        [self addSubview:_bottomLine];
        
        _lowValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kLLSizeFrom750_Landscape(28)/2, _kStartX, kLLSizeFrom750_Landscape(28))];
        _lowValueLabel.text = @"0";
        _lowValueLabel.textColor = [UIColor whiteColor];
        _lowValueLabel.textAlignment = NSTextAlignmentCenter;
        _lowValueLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_lowValueLabel];
        
        _highValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -kLLSizeFrom750_Landscape(28)/2, _kStartX, kLLSizeFrom750_Landscape(28))];
        _highValueLabel.text = @"100";
        _highValueLabel.textColor = [UIColor whiteColor];
        _highValueLabel.textAlignment = NSTextAlignmentCenter;
        _highValueLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_highValueLabel];
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor ll_colorWithHex:0x00DFDD andAlpha:1.0];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:kLLSizeFrom750_Landscape(20)];
        _tipLabel.lineBreakMode = NSLineBreakByClipping;
        [self addSubview:_tipLabel];
    }
    
    return self;
}

- (void)setLowValue:(NSString *)value{
    _lowValueLabel.text = value;
}

- (void)setHightValue:(NSString *)value{
    _highValueLabel.text = value;
}

- (void)addHeightValue:(CGFloat)showHeight andTipValue:(NSString *)tipValue{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat step = width / _numberOfPoints;
    if (_pointList.count == 0) {
        _x = _kStartX;
    }else{
        if (_x <= width-step) {
            _x += step;
        }
    }
    
    _y = fabs(MIN(height, showHeight));
    LLPoint *point = [[LLPoint alloc] init];
    point.x = _x;
    point.y = _y;
    [_pointList addObject:point];
    
    if (_pointList.count > _numberOfPoints) {
        NSMutableArray *oldList = [NSMutableArray array];
        
        for (LLPoint *point in _pointList) {
            point.x -= step;
            if (point.x < _kStartX) {
                [oldList addObject:point];
            }
        }
        
        [_pointList removeObjectsInArray:oldList];
    }
    
    [self drawLine];
    [self drawTipViewWithValue:tipValue point:point time:nil];
}

- (void)drawLine{
    if (_lineLayer) {
        [_lineLayer removeFromSuperlayer];
    }
    if (_pointLayerList.count>0) {
        for (CALayer *layer in _pointLayerList) {
            [layer removeFromSuperlayer];
        }
        _pointLayerList = [NSMutableArray array];
    }
    if (self.pointList.count==0) {
        return ;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    LLPoint *point = self.pointList[0];
    CGPoint p1 = CGPointMake(point.x, self.frame.size.height - point.y);
    [path moveToPoint:p1];
    [self addPointLayer:p1];
    
    for (int i=1; i<self.pointList.count; i++) {
        point = self.pointList[i];
        CGPoint p2 = CGPointMake(point.x, self.frame.size.height - point.y);
        [path addLineToPoint:p2];
        
        [self addPointLayer:p2];
    }
    
    path.lineWidth = 2.;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor ll_colorWithHex:0x00DFDD andAlpha:1.0].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    _lineLayer = layer;
    
    [self.layer addSublayer:layer];
    
    for (CALayer *layer in _pointLayerList) {
        [self.layer addSublayer:layer];
    }
}

- (void)addPointLayer:(CGPoint)point{
    CALayer *pointLayer = [CALayer layer];
    pointLayer.backgroundColor = [UIColor ll_colorWithHex:0x00DFDD andAlpha:1.0].CGColor;
    pointLayer.cornerRadius = 2;
    pointLayer.frame = CGRectMake(point.x-kLLSizeFrom750_Landscape(8)/2, point.y-kLLSizeFrom750_Landscape(8)/2, kLLSizeFrom750_Landscape(8), kLLSizeFrom750_Landscape(8));
    [_pointLayerList addObject:pointLayer];
}

- (void)drawTipViewWithValue:(NSString *)tip point:(LLPoint *)point time:(NSString *)time {
    if (_tipLabel.hidden) {
        _tipLabel.hidden = NO;
    }
    
    if (time) {
        _tipLabel.text = [NSString stringWithFormat:@"%@\n%@", tip, time];
        _tipLabel.numberOfLines = 2;
    } else {
        _tipLabel.text = tip;
        _tipLabel.numberOfLines = 1;
    }
    
    [_tipLabel sizeToFit];
    _tipLabel.frame = CGRectMake(point.x, self.frame.size.height-point.y-_tipLabel.frame.size.height, _tipLabel.frame.size.width, _tipLabel.frame.size.width);
}

- (void)clear {
    if (_pointLayerList.count>0) {
        for (CALayer *layer in _pointLayerList) {
            [layer removeFromSuperlayer];
        }
        _pointLayerList = [NSMutableArray array];
    }
    if (_lineLayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _pointList = [NSMutableArray array];
    _tipLabel.hidden = YES;
}



@end
