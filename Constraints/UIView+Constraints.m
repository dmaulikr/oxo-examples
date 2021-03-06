//
//  UIView+Constraints.m
//  RoundedRect
//
//  Created by Hans Yelek on 3/4/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import "UIView+Constraints.h"

@implementation UIView (Constraints)

#pragma mark - Autoresize Disable

- (void)prepareForConstraints
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Edge Constraints

- (void)constrainToParentEdgeTop
{
    if ([self hasParent])
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainToParentEdgeBottom
{
    if ([self hasParent])
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainToParentEdgeLeft
{
    if ([self hasParent])
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainToParentEdgeRight
{
    if ([self hasParent])
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainToParentEdges
{
    if (! [self hasParent]) return;
    
    [self constrainToParentEdgeTop];
    [self constrainToParentEdgeBottom];
    [self constrainToParentEdgeLeft];
    [self constrainToParentEdgeRight];
}

#pragma mark - Edge Center Constraints

- (void)constrainToParentEdgeTopCenter
{
    [self constrainToParentEdgeTop];
    [self centerHorizontallyInParent];
}

- (void)constrainToParentEdgeBottomCenter
{
    [self constrainToParentEdgeBottom];
    [self centerHorizontallyInParent];
}

- (void)constrainToParentEdgeLeftCenter
{
    [self constrainToParentEdgeLeft];
    [self centerVerticallyInParent];
}

- (void)constrainToParentEdgeRightCenter
{
    [self constrainToParentEdgeRight];
    [self centerVerticallyInParent];
}

#pragma mark - Corner Constraints

- (void)constrainToParentCornerTopLeft
{
    if (! [self hasParent]) return;
    
    [self constrainToParentEdgeTop];
    [self constrainToParentEdgeLeft];
    
}

- (void)constrainToParentCornerTopRight
{
    if (! [self hasParent]) return;
    
    [self constrainToParentEdgeTop];
    [self constrainToParentEdgeRight];
}

- (void)constrainToParentCornerBottomLeft
{
    if (! [self hasParent]) return;
    
    [self constrainToParentEdgeBottom];
    [self constrainToParentEdgeLeft];
}

- (void)constrainToParentCornerBottomRight
{
    if (! [self hasParent]) return;
    
    [self constrainToParentEdgeBottom];
    [self constrainToParentEdgeRight];
}


#pragma mark - Centering

- (void)centerHorizontallyInParent
{
    if ([self hasParent])
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
}

- (void)centerVerticallyInParent
{
    if ([self hasParent])
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)centerInParent
{
    if (! [self hasParent]) return;
    
    [self centerHorizontallyInParent];
    [self centerVerticallyInParent];
}

#pragma mark - Size

- (void)constrainWidth:(CGFloat)aWidth
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(aWidth@1000)]" options:0 metrics:@{@"aWidth":@(aWidth)} views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainHeight:(CGFloat)aHeight
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(aHeight@1000)]" options:0 metrics:@{@"aHeight":@(aHeight)} views:NSDictionaryOfVariableBindings(self)]];
}

- (void)constrainSize:(CGSize)aSize
{
    [self constrainWidth:aSize.width];
    [self constrainHeight:aSize.height];
}

#pragma mark - General Attribute Constraints

- (void)setAttribute:(NSLayoutAttribute)anAttribute equalToParentAttribute:(NSLayoutAttribute)parentAttribute
{
    if (! [self hasParent]) return;
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:anAttribute relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:parentAttribute multiplier:1.0f constant:0.0f]];
}

- (void)setAttribute:(NSLayoutAttribute)anAttribute equalToParentAttribute:(NSLayoutAttribute)parentAttribute times:(CGFloat)multiplier plus:(CGFloat)constant;
{
    if (! [self hasParent]) return;
    
    [self setAttribute:anAttribute relation:NSLayoutRelationEqual parentAttribute:parentAttribute times:multiplier plus:constant];
}

#pragma mark - Helper Methods

- (BOOL)hasParent
{
    if (!self.superview)
        NSLog(@"Error: View has no parent to constrain to!\nVIEW DESCRIPTION:\n%@", [self description]);
    return self.superview ? YES : NO;
    // could just do
    // return self.superview, right?
}

- (void)setAttribute:(NSLayoutAttribute)anAttribute relation:(NSLayoutRelation)relation parentAttribute:(NSLayoutAttribute)parentAttribute times:(CGFloat)multiplier plus:(CGFloat)constant
{
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:anAttribute relatedBy:relation toItem:self.superview attribute:parentAttribute multiplier:multiplier constant:constant]];
}

@end