//
//  UIView+Constraints.h
//  RoundedRect
//
//  Created by Hans Yelek on 3/4/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraints)

// Turn off autoresizing
- (void)prepareForConstraints;

// Constrain to parent edges
- (void)constrainToParentEdgeTop;
- (void)constrainToParentEdgeBottom;
- (void)constrainToParentEdgeLeft;
- (void)constrainToParentEdgeRight;

- (void)constrainToParentEdges;

// Constrain to parent edge centers
- (void)constrainToParentEdgeTopCenter;
- (void)constrainToParentEdgeBottomCenter;
- (void)constrainToParentEdgeLeftCenter;
- (void)constrainToParentEdgeRightCenter;

// Constrain to parent corners
- (void)constrainToParentCornerTopLeft;
- (void)constrainToParentCornerTopRight;
- (void)constrainToParentCornerBottomLeft;
- (void)constrainToParentCornerBottomRight;

//
// Not yet implemented: possible problems with adding two of the same constraints
// with these calls: (ex: two top edge constraints)
// Should see if layout constraints can be tested for equality before adding
//- (void)constrainToParentCornersTop;
//- (void)constrainToParentCornersBottom;
//- (void)constrainToParentCornersLeft;
//- (void)constrainToParentCornersRight;

// Centering to parent bounds
- (void)centerHorizontallyInParent;
- (void)centerVerticallyInParent;
- (void)centerInParent;

// Constrain size
- (void)constrainWidth:(CGFloat)aWidth;
- (void)constrainHeight:(CGFloat)aHeight;
- (void)constrainSize:(CGSize)aSize;

// General attribute constraints
- (void)setAttribute:(NSLayoutAttribute)anAttribute equalToParentAttribute:(NSLayoutAttribute)parentAttribute;
- (void)setAttribute:(NSLayoutAttribute)anAttribute equalToParentAttribute:(NSLayoutAttribute)parentAttribute times:(CGFloat)multiplier plus:(CGFloat)constant;

// Not yet implemented
//- (void)setAttribute:(NSLayoutAttribute)anAttribute lessThanOrEqualToParentAttribute:(NSLayoutAttribute)parentAttribute;
//- (void)setAttribute:(NSLayoutAttribute)anAttribute greaterThanOrEqualToParentAttribute:(NSLayoutAttribute)parentAttribute;
//
//
//- (void)setAttribute:(NSLayoutAttribute)anAttribute lessThanOrEqualToParentAttribute:(NSLayoutAttribute)parentAttribute times:(CGFloat)multiplier plus:(CGFloat)constant;
//- (void)setAttribute:(NSLayoutAttribute)anAttribute greaterThanOrEqualToParentAttribute:(NSLayoutAttribute)parentAttribute times:(CGFloat)multiplier plus:(CGFloat)constant;
/////
@end