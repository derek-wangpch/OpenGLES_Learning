//
//  OpenGLESView.h
//  OpenGLES_Learning
//
//  Created by Derek Wang on 15/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLRender.h"

@interface OpenGLESView : UIView

- (instancetype)initWithFrame:(CGRect)frame render:(GLRender *)render;

@property (nonatomic) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end
