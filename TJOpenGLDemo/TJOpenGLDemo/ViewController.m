//
//  ViewController.m
//  TJOpenGLDemo
//
//  Created by 李琼 on 2017/9/9.
//  Copyright © 2017年 Town. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

#define POINTCOUNT 300

typedef struct {
    GLKVector3  positionCoords;
}
SceneVertex;

// Define vertex data for a triangle to use in example
SceneVertex vertices[POINTCOUNT * 3];
//=
//{
//    {{-0.5f, -0.5f, 0.0}}, // lower left corner
//    {{ 0.5f, -0.5f, 0.0}}, // lower right corner
//    {{-0.5f,  0.5f, 0.0}}  // upper left corner
//};


@interface ViewController (){
    GLuint currentProgram;
    GLfloat targetRadius;
    GLfloat tempRadius;
    GLfloat dividNum;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super setCustomDrawView: self.drawView];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configContext];
    [self prepareData];
}

- (void)configContext{
    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    AGLKView *view = (AGLKView *)self.drawView;
    NSAssert([view isKindOfClass:[AGLKView class]],
             @"View controller's view is not a AGLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [view setBackgroundColor:[UIColor clearColor]];
    view.layer.opaque = false;
    // Make the new context current
    [EAGLContext setCurrentContext:view.context];
    
}
- (void)prepareData{
    targetRadius = 1.0;
    dividNum = 0.0;
    
    [self productData];
    
    // Set the background color stored in the current context
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // background color
    
    // Generate, bind, and initialize contents of a buffer to be
    // stored in GPU memory
    glGenBuffers(1,                // STEP 1
                 &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 vertexBufferID);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 sizeof(vertices), // Number of bytes to copy
                 vertices,         // Address of bytes to copy
                 GL_STATIC_DRAW);  // Hint: cache in GPU memory

    GLuint program = [self linkProgram];
    currentProgram = program;
    
    
    glEnable(GL_BLEND);
    glBlendFunc( GL_SRC_ALPHA , GL_ONE_MINUS_SRC_ALPHA );
    // Enable use of positions from bound vertex buffer
    glEnableVertexAttribArray(      // STEP 4
                              GLKVertexAttribPosition);
    
    glVertexAttribPointer(          // STEP 5
                          GLKVertexAttribPosition,
                          3,                   // three components per vertex
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          sizeof(SceneVertex), // no gaps in data
                          NULL);               // NULL tells GPU to start at
    // beginning of bound buffer
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:true block:^(NSTimer * _Nonnull timer) {
        GLfloat tmpR = (arc4random() % 55) / 100.0 + 0.4;
        if (tmpR < tempRadius) {
//            dividNum = -(tempRadius - tmpR) / 30.0;
            dividNum = -0.01;
        }else if( tmpR == tempRadius){
//            dividNum = ;
        }else{
//            dividNum = (tmpR - tempRadius) / 30.0;
            dividNum = 0.01;
        }
//        tempRadius = tmpR;
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    NSTimer *dividTimer = [NSTimer timerWithTimeInterval:0.5 / 30.0 repeats:true block:^(NSTimer * _Nonnull timer) {
        tempRadius += dividNum;
    }];
    [[NSRunLoop currentRunLoop] addTimer:dividTimer forMode:NSDefaultRunLoopMode];

}

- (void)productData{
    GLfloat de = M_PI * 2.0 / POINTCOUNT;
    GLfloat radius = self.drawView.drawableWidth * 1.5 - 30;
    GLfloat rate = (GLfloat)self.drawView.drawableWidth / self.drawView.drawableHeight;
    for (int i=0; i < POINTCOUNT; i++) {
        GLfloat xTmp = self.drawView.drawableWidth + radius * cos(de * i);
        GLfloat yTmp = -self.drawView.drawableHeight + radius * sin(de * i);

        GLfloat x = xTmp / self.drawView.drawableWidth;
        GLfloat y = (yTmp  / self.drawView.drawableWidth) * rate;
        
        SceneVertex point = {x,y,0.0};
        vertices[i] = point;
    }
    
}


- (GLuint)linkProgram{
    NSString *vStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:nil] ;
    const char *vShaderStr = [vStr cStringUsingEncoding:NSUTF8StringEncoding];

    NSString *fStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:nil] ;
    const char *fShaderStr = [fStr cStringUsingEncoding:NSUTF8StringEncoding];
    
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint programObject;
    GLint linked;
    
    // Load the vertex/fragment shaders
    vertexShader = LoadShader ( GL_VERTEX_SHADER, vShaderStr );
    fragmentShader = LoadShader ( GL_FRAGMENT_SHADER, fShaderStr );
    
    // Create the program object
    programObject = glCreateProgram ( );
    
    if ( programObject == 0 )
    {
        return 0;
    }
    
    glAttachShader ( programObject, vertexShader );
    glAttachShader ( programObject, fragmentShader );
    
    // Link the program
    glLinkProgram ( programObject );
    
    // Check the link status
    glGetProgramiv ( programObject, GL_LINK_STATUS, &linked );
    
    if ( !linked )
    {
        GLint infoLen = 0;
        
        glGetProgramiv ( programObject, GL_INFO_LOG_LENGTH, &infoLen );
        
        if ( infoLen > 1 )
        {
            char *infoLog = malloc ( sizeof ( char ) * infoLen );
            
            glGetProgramInfoLog ( programObject, infoLen, NULL, infoLog );
            printf ( "Error linking program:\n%s\n", infoLog );
            
            free ( infoLog );
        }
        
        glDeleteProgram ( programObject );
        return FALSE;
    }
    
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    return programObject;
}

GLuint LoadShader ( GLenum type, const char *shaderSrc )
{
    GLuint shader;
    GLint compiled;
    
    // Create the shader object
    shader = glCreateShader ( type );
    
    if ( shader == 0 )
    {
        return 0;
    }
    
    // Load the shader source
    glShaderSource ( shader, 1, &shaderSrc, NULL );
    
    // Compile the shader
    glCompileShader ( shader );
    
    // Check the compile status
    glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );
    
    if ( !compiled )
    {
        GLint infoLen = 0;
        
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if ( infoLen > 1 )
        {
            char *infoLog = malloc ( sizeof ( char ) * infoLen );
            
            glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
            printf ( "Error compiling shader:\n%s\n", infoLog );
            
            free ( infoLog );
        }
        
        glDeleteShader ( shader );
        return 0;
    }
    
    return shader;
    
}
/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect
{

    
    // Clear back frame buffer (erase previous drawing)
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(currentProgram);
    
    GLint widthLoc = glGetUniformLocation(currentProgram, "screenWidth");
    glUniform1f(widthLoc, ((AGLKView *)self.drawView).drawableWidth);
    GLint heightLoc = glGetUniformLocation(currentProgram, "screenHeight");
    glUniform1f(heightLoc, ((AGLKView *)self.drawView).drawableHeight);
    
    GLint radiusLoc = glGetUniformLocation(currentProgram, "radius");
    glUniform1f(radiusLoc, tempRadius);
    
  
    // Draw triangles using the first three vertices in the
    // currently bound vertex buffer
    glDrawArrays(GL_TRIANGLE_FAN,      // STEP 6
                 0,  // Start with first vertex in currently bound buffer
                 POINTCOUNT); // Use three vertices from currently bound buffer
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Delete buffers that aren't needed when view is unloaded
    if (0 != vertexBufferID)
    {
        glDeleteBuffers (1,          // STEP 7
                         &vertexBufferID);
        vertexBufferID = 0;
    }
    
    // Stop using the context created in -viewDidLoad
    ((AGLKView *)self.drawView).context = nil;
    [EAGLContext setCurrentContext:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
