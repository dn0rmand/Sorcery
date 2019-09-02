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

@class Wizard;
@class InformationPanel;
@class Room;
@class Door;
@class Character;
@class StaticObject;

@interface GameEngine : NSObject

@property Room*				room;
@property InformationPanel*	informationPanel;
@property Wizard*			wizard;
@property float				energy;
@property StaticObjectType	carrying;
@property int				score;

-(instancetype)initWithRoom:(int)roomIndex;
+(instancetype)createWithRoom:(int)roomIndex;

-(void)goThroughDoor:(Door*)door withScene:(SKScene*)scene andCallback:(void (^)(void))block;

-(void)addToScene:(SKScene*) scene;
-(void)removeFromScene:(SKScene*) scene;
-(void)update:(CFTimeInterval)currentTime;
-(void)pick:(StaticObject*)object;
-(void)kill:(Character*)character withScore:(int)score;

@end
