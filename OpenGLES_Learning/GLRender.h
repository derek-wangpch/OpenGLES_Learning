//
//  GLRender.h
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>

@interface GLRender : NSObject

@property (nonatomic, weak) EAGLContext *context;
@property (nonatomic, readonly) GLint renderWidth;
@property (nonatomic, readonly) GLint renderHeight;
@property (nonatomic, readonly) GLuint defaultFBO;

- (void)bindEAGLContext:(EAGLContext *)context drawable:(id<EAGLDrawable>)drawable;
- (void)setup;
- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)renderContent; // For subclass to override, render content only
- (void)destroyVAO:(GLuint) vaoName;
-(void) destroyFBO:(GLuint)fboName;

@end
