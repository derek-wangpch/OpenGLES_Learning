//
//  GLRender.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "GLRender.h"

@interface GLRender() {
    GLuint          _colorRenderBuffer;
    GLuint          _frameBuffer;
}

@property (nonatomic, weak) id<EAGLDrawable> eaglLayer;

@end

@implementation GLRender

- (void)bindEAGLContext:(EAGLContext *)context drawable:(id<EAGLDrawable>)drawable {
    self.context = context;
    self.eaglLayer = drawable;
}

- (void)setup {
    NSLog(@"setup render");
}
- (void)render {
    NSLog(@"start render");
}

- (void)resizeWithWidth:(GLuint)width height:(GLuint)height {
    _renderWidth = width;
    _renderHeight = height;
    [self destoryRenderAndFrameBuffer];
    [self setupFrameAndRenderBuffer];
}

- (void)destoryRenderAndFrameBuffer {
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_colorRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
}

- (void)setupFrameAndRenderBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];

    //Attach _colorRenderBuffer to GL_COLOR_ATTACHMENT0 of _frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

@end
