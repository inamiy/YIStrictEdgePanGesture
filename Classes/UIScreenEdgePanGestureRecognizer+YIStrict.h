//
//  UIScreenEdgePanGestureRecognizer+YIStrict.h
//  YIStrictEdgePanGesture
//
//  Created by Yasuhiro Inami on 2014/03/15.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIScreenEdgePanGestureRecognizer (YIStrict)

@property (nonatomic) BOOL usesStrictMode;                  // default = YES

// maximum allowed distance for panning alongside the edges
@property (nonatomic) CGFloat maximumParallelTranslation;   // default = 64pt

@end