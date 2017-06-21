//
//  GLRender.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "GLRender.h"
#import "GLUtils.h"

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
    glGenRenderbuffers(1, &_defaultColorRB);
    glGenRenderbuffers(1, &_depthRenderbuffer);
}

- (void)setup {
    ////////////////////////////////////////////////
    // Set up OpenGL state that will never change //
    ////////////////////////////////////////////////

    // Depth test will always be enabled
    glEnable(GL_DEPTH_TEST);

    // We will always cull back faces for better performance
    glEnable(GL_CULL_FACE);
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
    glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorRB);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _defaultColorRB);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);

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
    [self destroyFBO:_defaultFBO];
}

#pragma mark - Destroy VAO and associated VBOs
- (void)destroyVAO:(GLuint) vaoName
{
    GLuint index;
    GLuint bufName;

    // Bind the VAO so we can get data from it
    glBindVertexArray(vaoName);

    // For every possible attribute set in the VAO
    for(index = 0; index < 16; index++)
    {
        // Get the VBO set for that attibute
        glGetVertexAttribiv(index , GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint*)&bufName);

        // If there was a VBO set...
        if(bufName)
        {
            //...delete the VBO
            glDeleteBuffers(1, &bufName);
        }
    }

    // Get any element array VBO set in the VAO
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint*)&bufName);

    // If there was a element array VBO set in the VAO
    if(bufName)
    {
        //...delete the VBO
        glDeleteBuffers(1, &bufName);
    }
    
    // Finally, delete the VAO
    glDeleteVertexArrays(1, &vaoName);
    
    GetGLError();
}

#pragma mark - Destroy FrameBufferObject and associated buffers
- (void) destroyFBO:(GLuint)fboName
{
    if(0 == fboName)
    {
        return;
    }

    glBindFramebuffer(GL_FRAMEBUFFER, fboName);

    GLint maxColorAttachments = 1;


    // OpenGL ES 2.0 has only 1 attachment.
    // There are many possible attachments on OpenGL  os OSX so we query
    // how many below so that we can delete all attached renderbuffers
#if !TARGET_IOS
    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColorAttachments);
#endif

    GLint colorAttachment;

    // For every color buffer attached
    for(colorAttachment = 0; colorAttachment < maxColorAttachments; colorAttachment++)
    {
        // Delete the attachment
        [self deleteFBOAttachment:(GL_COLOR_ATTACHMENT0+colorAttachment)];
    }

    // Delete any depth or stencil buffer attached
    [self deleteFBOAttachment:GL_DEPTH_ATTACHMENT];

    [self deleteFBOAttachment:GL_STENCIL_ATTACHMENT];
    
    glDeleteFramebuffers(1,&fboName);
}

-(void) deleteFBOAttachment:(GLenum)attachment
{
    GLint param;
    GLuint objName;

    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment,
                                          GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
                                          &param);

    if(GL_RENDERBUFFER == param)
    {
        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment,
                                              GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                              &param);

        objName = ((GLuint*)(&param))[0];
        glDeleteRenderbuffers(1, &objName);
    }
    else if(GL_TEXTURE == param)
    {

        glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment,
                                              GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                              &param);

        objName = ((GLuint*)(&param))[0];
        glDeleteTextures(1, &objName);
    }
    
}


@end
