//
//  UIScreenEdgePanGestureRecognizer+YIStrict.m
//  YIStrictEdgePanGesture
//
//  Created by Yasuhiro Inami on 2014/03/15.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

#import "UIScreenEdgePanGestureRecognizer+YIStrict.h"
#import <objc/runtime.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "JRSwizzle.h"

static const char __usesStrictModeKey;
static const char __maximumParallelTranslationKey;
static const char __touchBeganLocationKey;


@implementation UIScreenEdgePanGestureRecognizer (YIStrict)

+ (void)load
{
    [UIScreenEdgePanGestureRecognizer jr_swizzleMethod:@selector(setState:)
                                            withMethod:@selector(YIStrict_setState:)
                                                 error:NULL];
    
    [UIScreenEdgePanGestureRecognizer jr_swizzleMethod:@selector(touchesBegan:withEvent:)
                                            withMethod:@selector(YIStrict_touchesBegan:withEvent:)
                                                 error:NULL];
    
    [UIScreenEdgePanGestureRecognizer jr_swizzleMethod:@selector(touchesMoved:withEvent:)
                                            withMethod:@selector(YIStrict_touchesMoved:withEvent:)
                                                 error:NULL];
}

#pragma mark -

#pragma mark Accessors

- (BOOL)usesStrictMode
{
    NSNumber* number = objc_getAssociatedObject(self, &__usesStrictModeKey);
    if (!number) {
        return YES;
    }
    
    return [number boolValue];
}

- (void)setUsesStrictMode:(BOOL)usesStrictMode
{
    objc_setAssociatedObject(self, &__usesStrictModeKey, @(usesStrictMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)maximumParallelTranslation
{
    NSNumber* number = objc_getAssociatedObject(self, &__maximumParallelTranslationKey);
    if (!number) {
        return 64;  // NOTE: default=44pt is still short for human thumb
    }
    
    return [number doubleValue];
}

- (void)setMaximumParallelTranslation:(CGFloat)maximumTranslation
{
    objc_setAssociatedObject(self, &__maximumParallelTranslationKey, @(maximumTranslation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

#pragma mark Private

- (CGPoint)touchBeganLocation
{
    CGPoint touchBeganLocation = [objc_getAssociatedObject(self, &__touchBeganLocationKey) CGPointValue];
    return touchBeganLocation;
}

- (void)setTouchBeganLocation:(CGPoint)touchBeganLocation
{
    objc_setAssociatedObject(self, &__touchBeganLocationKey, [NSValue valueWithCGPoint:touchBeganLocation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIRectEdge)_estimatedRectEdgeOnTouchBegan
{
    const CGFloat inset = 30;
    CGRect edgeFrame;
    
    // left edge
    edgeFrame = self.view.bounds;
    edgeFrame.size.width = inset;
    if (CGRectContainsPoint(edgeFrame, self.touchBeganLocation)) {
        return UIRectEdgeLeft;
    }
    
    // right edge
    edgeFrame = self.view.bounds;
    edgeFrame.size.width = inset;
    edgeFrame.origin.x = self.view.bounds.size.width-inset;
    if (CGRectContainsPoint(edgeFrame, self.touchBeganLocation)) {
        return UIRectEdgeRight;
    }
    
    // bottom edge
    edgeFrame = self.view.bounds;
    edgeFrame.size.height = inset;
    edgeFrame.origin.y = self.view.bounds.size.height-inset;
    if (CGRectContainsPoint(edgeFrame, self.touchBeganLocation)) {
        return UIRectEdgeBottom;
    }
    
    // top edge
    edgeFrame = self.view.bounds;
    edgeFrame.size.height = inset;
    if (CGRectContainsPoint(edgeFrame, self.touchBeganLocation)) {
        return UIRectEdgeTop;
    }
    
    return UIRectEdgeNone;
}

- (BOOL)_isHorizontalPanning
{
    // NOTE: don't trust self.edges, since UINavigationController's interactivePopGestureRecognizer.edges returns 0 in iOS7.1
    BOOL isFromLeft = (self._estimatedRectEdgeOnTouchBegan & UIRectEdgeLeft);
    BOOL isFromRight = (self._estimatedRectEdgeOnTouchBegan & UIRectEdgeRight);
    
    return (isFromLeft || isFromRight);
}

- (BOOL)_isVerticalPanning
{
    BOOL isFromTop = (self._estimatedRectEdgeOnTouchBegan & UIRectEdgeTop);
    BOOL isFromBottom = (self._estimatedRectEdgeOnTouchBegan & UIRectEdgeBottom);
    
    return (isFromTop || isFromBottom);
}

#pragma mark -

#pragma mark Swizzling Methods

- (void)YIStrict_setState:(UIGestureRecognizerState)state
{
    CGPoint location = [self locationInView:self.view];
    CGFloat deltaX = fabs(location.x-self.touchBeganLocation.x);
    CGFloat deltaY = fabs(location.y-self.touchBeganLocation.y);
    
    // swap gesture.state from 'began' to 'failed' if needed, without calling self.state=began
    if (self.usesStrictMode && state == UIGestureRecognizerStateBegan) {
        
        // NOTE: delta may have (0, 0) on quick-swiping, so don't fail it
        if ((self._isHorizontalPanning && deltaX < deltaY) ||
            (self._isVerticalPanning && deltaX > deltaY)) {
            
            state = UIGestureRecognizerStateFailed;
        }
    }
    
    [self YIStrict_setState:state];
}

- (void)YIStrict_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // update touchBeganLocation on first touchesBegan
    if (self.usesStrictMode && touches.count == [event touchesForGestureRecognizer:self].count) {
        UITouch* touch = touches.anyObject;
        self.touchBeganLocation = [touch locationInView:touch.view.window];
    }

    [self YIStrict_touchesBegan:touches withEvent:event];
}

- (void)YIStrict_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self YIStrict_touchesMoved:touches withEvent:event];
    
    // force-cancel gesture on touchesMoved instead of setState,
    // since setState with state=changed is called only once per recognition
    if (self.usesStrictMode && self.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [self translationInView:self.view];
        CGFloat deltaX = fabs(translation.x);
        CGFloat deltaY = fabs(translation.y);
        
        if (self._isHorizontalPanning) {
            if (deltaX > deltaY && deltaY > self.maximumParallelTranslation) {
                self.state = UIGestureRecognizerStateCancelled;
            }
        }
        else if (self._isVerticalPanning) {
            if (deltaX < deltaY && deltaX > self.maximumParallelTranslation) {
                self.state = UIGestureRecognizerStateCancelled;
            }
        }
        
    }
}

@end