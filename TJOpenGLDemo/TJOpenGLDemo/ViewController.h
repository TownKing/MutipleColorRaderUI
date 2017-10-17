//
//  ViewController.h
//  TJOpenGLDemo
//
//  Created by 李琼 on 2017/9/9.
//  Copyright © 2017年 Town. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGLKViewController.h"

@interface ViewController : AGLKViewController
{
    GLuint vertexBufferID;
}
@property (weak, nonatomic) IBOutlet AGLKView *drawView;

@end

