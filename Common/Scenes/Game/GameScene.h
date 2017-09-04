//
//  GameScene.h
//  Sorcery
//

//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameEngine.h"
#import "JCButton.h"
#import "JCImageJoystick.h"
#import "SoundManager.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property	int					room;
@property	GameEngine*			game;
@property	Sound*				energySound;

#if TARGET_OS_IPHONE

@property	JCImageJoystick*	joystick;
@property	JCImageButton*		button;

#endif

-(instancetype)initWithSize:(CGSize)size;
-(instancetype)initWithEngine:(GameEngine*) game;
+(instancetype)sceneWithEngine:(GameEngine*) game;
@end
