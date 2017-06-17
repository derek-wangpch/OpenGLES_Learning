//
//  OpenGLESView.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 15/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "OpenGLESView.h"
#import "ShaderUtil.h"
#import "BaseStructs.h"
#import <GLKit/GLKit.h>

@interface OpenGLESView() {
    CAEAGLLayer     *_eaglLayer;
    EAGLContext     *_context;
}

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic) GLRender* glRender;

@end

@implementation OpenGLESView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame render:(GLRender *)render{
    if (self = [super initWithFrame:frame]) {
        self.glRender = render;
        [self setupLayer];
        [self setupContext];
        [_glRender bindEAGLContext:_context drawable:_eaglLayer];
        [_glRender setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [_glRender resizeFromLayer:(CAEAGLLayer *)self.layer];
    [self render];
}

- (void)startAnimating {
    if (!_isAnimating) {
        self.isAnimating = YES;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
        self.displayLink.paused = YES;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = NO;
    }
}
- (void)stopAnimating {
    if (_isAnimating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = @{
                                      kEAGLDrawablePropertyRetainedBacking : @(NO),
                                      kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                      };
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            NSLog(@"Failed to initialize OpenGLES 2.0 context");
            exit(1);
        }
    }

    // 将当前上下文设置为我们创建的上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)render {
    [EAGLContext setCurrentContext:_context];
    [_glRender render];
}

- (void)dealloc {
    [self stopAnimating];
    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
}


@end
