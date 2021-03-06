//
//  TTTCellRoundRect.m
//  TTT
//
//  Created by Hans Yelek on 6/13/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import "TTTCellRoundRect.h"
#import "ThemeConstants.h"
#import "CAMediaTimingFunction+Names.h"

#define CORNER_RADIUS               10.0f
#define BORDER_WIDTH                2.0f     // border width for self.markerLayer
#define BORDER_WIDTH_THICK          3.0f     // border width for pond layers
#define BORDER_WIDTH_WIN            5.0f
#define BORDER_WIDTH_PLACEHOLDER    5.0f

@implementation TTTCellRoundRect

- (id)initWithTheme:(TTTTheme *)theme
{
    if (self = [super initWithTheme:theme])
    {
        [self setupMarkerLayer];
        [self setupPondlayer1];
        [self setupPondlayer2];
    }
    
    return self;
}


- (void)setupMarkerLayer
{
    self.markerLayer.cornerRadius = CORNER_RADIUS;
    self.markerLayer.borderWidth = 2.0f;
}

- (void)setupPondlayer1
{
    _pondlayer1 = [CALayer layer];
    _pondlayer1.cornerRadius = CORNER_RADIUS;
    _pondlayer1.borderWidth = BORDER_WIDTH_THICK;
    _pondlayer1.opacity = 0.0f;
    
    [self standardizeLayer:_pondlayer1];
    [self.layer addSublayer:_pondlayer1];
}

- (void)setupPondlayer2
{
    _pondLayer2 = [CALayer layer];
    _pondLayer2.cornerRadius = CORNER_RADIUS;
    _pondLayer2.borderWidth = BORDER_WIDTH;
    _pondLayer2.borderColor = kPurpleColor_ThemeBrown.CGColor;
    _pondLayer2.opacity = 0.0f;
    
    [self standardizeLayer:_pondLayer2];
    [self.layer addSublayer:_pondLayer2];
}

- (void)standardizeLayer:(CALayer *)layer
{
    if (! layer) { NSLog(@"Error: layer not initialized!"); return; }
    
    layer.frame = CGRectMake(0.0f, 0.0f, CELL_SIZE, CELL_SIZE);
    layer.contentsScale = [UIScreen mainScreen].scale;
}

#pragma mark - Overridden Animation Methods

- (void)animateFromPlaceholderToMarker
{
    [super animateFromPlaceholderToMarker];
    
    
    self.markerLayer.borderWidth = BORDER_WIDTH;
    
    [UIView animateWithDuration:0.3f
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         self.baseView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)animateFromMarkerToPlaceholder:(NSNumber *)readyPlayer1
{
    [super animateFromMarkerToPlaceholder:readyPlayer1];
    
    
    [self.markerLayer removeAllAnimations];
    
    self.isP1Cell = [readyPlayer1 boolValue];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.markerLayer.borderWidth = BORDER_WIDTH_PLACEHOLDER;
        self.markerLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    [CATransaction commit];
    
    [UIView animateWithDuration:1.0f
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5
                        options:0
                     animations:^{
                         self.baseView.transform = CGAffineTransformMakeScale(0.25, 0.25);
                     }
                     completion:nil];
}

- (void)animateTwoinRow
{
    [super animateTwoinRow];
    
    
    [_pondlayer1 addAnimation:[self animFadeWithDuration:1.8] forKey:nil];
    [_pondlayer1 addAnimation:[self animPondTouchCenter] forKey:nil];
    
    [_pondLayer2 addAnimation:[self animFadeWithDuration:0.8] forKey:nil];
    [_pondLayer2 addAnimation:[self animPondTouchPerimeter] forKey:nil];
}

- (void)animateWin
{
    [super animateWin];
    
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0f];
    if (self.isP1Cell)
    {
        self.markerLayer.borderWidth = BORDER_WIDTH_WIN;
    }
    else
    {
        self.markerLayer.borderWidth = BORDER_WIDTH_WIN;
    }
    [CATransaction commit];
    
    [self.markerLayer addAnimation:[self animRotate] forKey:nil];
    [self.markerLayer addAnimation:[self animPop] forKey:nil];
    
    // also perform two-in-row animation
    [self animateTwoinRow];
}

- (void)animateDraw
{
    
}

#pragma mark - Animations

- (CABasicAnimation *)animFadeWithDuration:(CGFloat)duration
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.duration = duration;
    
    return animation;
}

- (CABasicAnimation *)animPondTouchCenter
{
    CAMediaTimingFunction * easeOut = [CAMediaTimingFunction easeOut];
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = @0;
    animation.toValue = @1.15;
    animation.duration = 1.8;
    animation.timingFunction = easeOut;
    
    return animation;
}

- (CABasicAnimation *)animPondTouchPerimeter
{
    CAMediaTimingFunction * easeOut = [CAMediaTimingFunction easeOut];
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = @1;
    animation.toValue = @1.15;
    animation.duration = 0.8;
    animation.timingFunction = easeOut;
    
    return animation;
}

- (CABasicAnimation *)animRotate
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    animation.byValue = @(2*M_PI);
    animation.duration = 8.0f;
    animation.repeatCount = HUGE_VAL;
    
    return animation;
}

- (CAKeyframeAnimation *)animPop
{
    CAMediaTimingFunction * easeIn  = [CAMediaTimingFunction easeIn];
    CAMediaTimingFunction * easeOut = [CAMediaTimingFunction easeOut];
    CAMediaTimingFunction * linear = [CAMediaTimingFunction linear];
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.values = @[@1, @0.85, @1.1, @0.9, @1.1, @1, @1];
    animation.keyTimes = @[@0, @0.08, @0.16, @0.28, @0.38, @0.5, @1];
    animation.timingFunctions = @[easeOut, easeIn, easeOut, easeIn, easeOut, linear];
    animation.duration = 2.0f;
    animation.repeatCount = HUGE_VAL;
    
    
    return animation;
}

#pragma mark - Color Saturation Override

- (void)fadeOut
{
    CGFloat h, s, b, a;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.5f];
    if ( self.isP1Cell )
    {
        [kP1MarkerColor_ThemeBrown getHue:&h saturation:&s brightness:&b alpha:&a];
        self.markerLayer.borderColor = [[UIColor alloc] initWithHue:h saturation:(0.7f * s) brightness:b alpha:a].CGColor;
    }
    else
    {
        [kP2MarkerColor_ThemeBrown getHue:&h saturation:&s brightness:&b alpha:&a];
        self.markerLayer.borderColor = [[UIColor alloc] initWithHue:h saturation:(0.7f * s) brightness:b alpha:a].CGColor;
    }
    [CATransaction commit];
}

#pragma mark - Accessors

- (void)setIsP1Cell:(BOOL)isP1Cell
{
    super.isP1Cell = isP1Cell;
    
    // set markerLayer borderColor property here
    if (isP1Cell)
    {
        self.markerLayer.borderColor = kP1MarkerColor_ThemeBrown.CGColor;
        _pondlayer1.borderColor = kP1MarkerColor_ThemeBrown.CGColor;
        _pondLayer2.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        self.markerLayer.borderColor = kP2MarkerColor_ThemeBrown.CGColor;
        _pondlayer1.borderColor = kP2MarkerColor_ThemeBrown.CGColor;
        _pondLayer2.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (CAShapeLayer *)p1MarkerLayerThumbnail
{
    self.markerLayer.affineTransform = CGAffineTransformMakeScale(THUMBNAIL_SIZE / (1.0 * CELL_SIZE), THUMBNAIL_SIZE / (1.0 * CELL_SIZE));
    self.isP1Cell = YES;
    
    return self.markerLayer;
}

- (CAShapeLayer *)p2MarkerLayerThumbnail
{
    self.markerLayer.affineTransform = CGAffineTransformMakeScale(THUMBNAIL_SIZE / (1.0 * CELL_SIZE), THUMBNAIL_SIZE / (1.0 * CELL_SIZE));
    self.isP1Cell = NO;
    
    return self.markerLayer;
}

@end
