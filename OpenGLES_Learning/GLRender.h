//
//  GLRender.h
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>

@interface GLRender : NSObject

@property (nonatomic, weak) EAGLContext *context;
@property (nonatomic, readonly) GLuint renderWidth;
@property (nonatomic, readonly) GLuint renderHeight;

- (void)bindEAGLContext:(EAGLContext *)context drawable:(id<EAGLDrawable>)drawable;
- (void)setup;
- (void)render;
- (void)resizeWithWidth:(GLuint)width height:(GLuint)height;

@end
