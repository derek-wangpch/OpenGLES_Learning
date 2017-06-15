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
    GLuint          _colorRenderBuffer;
    GLuint          _frameBuffer;

    GLuint          _program;
    GLuint          vao, vbo;
}

@end

@implementation OpenGLESView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupGLProgram];
    }
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];

    [self destoryRenderAndFrameBuffer];

    [self setupFrameAndRenderBuffer];

    [self render];
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
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }

    // 将当前上下文设置为我们创建的上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupGLProgram {
    const char *vshFile = [[[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *fshFile = [[[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    _program = loadShaders(vshFile, fshFile);
    glUseProgram(_program);
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

- (void)makeTriangle {
    Vertex attrArr[] =
    {
        {{-1, -1, 0}, {1, 0, 0, 1}, {0, 0}},  //左上
        {{1, -1, 0}, {0, 1, 0, 1}, {0, 0}},    //顶点
        {{0, 1, 0}, {0, 0, 1, 1}, {0, 0}}    //左下
    };

    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);

    // Generate buffer
    glGenBuffers(1, &vbo);
    // Bind buffer
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    // Copy Data from memory to GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);

    GLuint posSlot = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(posSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(posSlot);

    GLuint colorSlot = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    glEnableVertexAttribArray(colorSlot);

    glBindVertexArrayOES(0);
}

- (void)render {
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);

    GLuint projectionSlot = glGetUniformLocation(_program, "projectionMatrix");
    GLuint modelViewSlot = glGetUniformLocation(_program, "modelViewMatrix");
    glUniformMatrix4fv(projectionSlot, 1, GL_FALSE,projectionMatrix.m);
    glUniformMatrix4fv(modelViewSlot, 1, GL_FALSE, modelViewMatrix.m);

    [self makeTriangle];
    glBindVertexArrayOES(vao);
    //[self setupVertexData];
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
