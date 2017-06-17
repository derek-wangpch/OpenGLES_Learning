//
//  GLRender.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "GLRender.h"

@interface GLRender() {
    GLuint          _depthRenderbuffer;
}

@property (nonatomic, weak) id<EAGLDrawable> eaglLayer;
@property (nonatomic, readonly) GLuint defaultColorRB;

@end

@implementation GLRender

- (void)bindEAGLContext:(EAGLContext *)context drawable:(id<EAGLDrawable>)drawable {
    self.context = context;
    self.eaglLayer = drawable;

    glGenFramebuffers(1, &_defaultFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFBO);
}

- (void)setup {
    NSLog(@"setup render");
}


- (void)render {
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFBO);

    [self renderContent];

//  Discard Unneeded Renderbuffers

//  A discard operation is a performance hint that tells OpenGL ES that the contents of one or more renderbuffers are no longer needed. By hinting to OpenGL ES that you do not need the contents of a renderbuffer, the data in the buffers can be discarded and expensive tasks to keep the contents of those buffers updated can be avoided.
//  At this stage in the rendering loop, your app has submitted all of its drawing commands for the frame. While your app needs the color renderbuffer to display to the screen, it probably does not need the depth buffer’s contents.
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFBO);
    glInvalidateFramebuffer(GL_FRAMEBUFFER,1,discards);

    glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorRB);

    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderContent {
    NSLog(@"start renderContent");
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
    if (_defaultColorRB != 0) {
        glDeleteRenderbuffers(1, &_defaultColorRB);
        _defaultColorRB = 0;
    }

    if (_depthRenderbuffer != 0) {
        glDeleteBuffers(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
    }

    glGenRenderbuffers(1, &_defaultColorRB);
    glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorRB);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _defaultColorRB);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);

    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }


    return YES;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_defaultFBO);
    glDeleteRenderbuffers(1, &_defaultColorRB);
    glDeleteBuffers(1, &_depthRenderbuffer);
}

@end
