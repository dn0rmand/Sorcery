//
//  GameContext.h
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "enums.h"

@class GameEngine;

@interface InformationPanel : NSObject

@property	NSString*			roomName;
@property	int					roomId;
@property	float				energy;
@property	int					score;
@property	StaticObjectType	carrying;

-(instancetype)init;
+(instancetype)create;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;

@end
