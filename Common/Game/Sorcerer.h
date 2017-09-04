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
@class Door;

@interface Wizard : NSObject

@property CGPoint           position;
@property DirectionType		direction;
@property StaticObjectType	carrying;
@property float				energy;
@property SKSpriteNode*     sprite;

-(instancetype)initWithPosition:(CGPoint)position;
+(instancetype)createWithPosition:(CGPoint)position;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;
-(void)moveTo:(CGPoint)location;
-(void)moveByX:(CGFloat)x andY:(CGFloat)y;
-(BOOL)canGoThroughDoor:(Door*)door;
-(void)update:(CFTimeInterval)currentTime withGame:(GameEngine*)game;

-(void)doPlouf:(void (^)())block;
-(void)die:(void (^)())block;

@end
