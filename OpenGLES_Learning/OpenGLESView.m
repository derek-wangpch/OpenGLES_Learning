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
    [EAGLContext setCurrentContext:_context];

    [_glRender resizeWithWidth:self.bounds.size.width height:self.bounds.size.height];
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
    [_glRender render];
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    [self stopAnimating];
}


@end
