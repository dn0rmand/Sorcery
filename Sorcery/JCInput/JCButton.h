//
//  JCButton.h
//  TestSpriteKit01
//
//  Created by Juan Carlos Sedano Salas on 18/09/13.
//  Copyright (c) 2013 Juan Carlos Sedano Salas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface JCImageButton : SKSpriteNode

-(BOOL)wasPressed;

-(id)initWithNormalImage:(NSString *)name
			pressedImage:(NSString *)pressedImage
				 isTurbo:(BOOL)isTurbo;

@end
