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

@interface Character : NSObject

@property int				id;
@property CGPoint           position;
@property CGPoint           startPosition;
@property CGPoint           defaultPosition;
@property int				speed;
@property StaticObjectType	killer;
@property CharacterType		type;
@property DirectionType		direction;
@property SKSpriteNode*     sprite;
@property BOOL				moveable;
@property BOOL				killed;

-(instancetype)initWithType:(CharacterType)type position:(CGPoint)position andStartPosition:(CGPoint)startPosition;
+(instancetype)createWithType:(NSString*)type position:(CGPoint)position andStartPosition:(CGPoint)startPosition;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;
-(void)removeFromScene:(SKScene*)scene;
-(void)update:(CFTimeInterval)currentTime withGame:(GameEngine*)game;
-(void)unload;
-(void)killWithScore:(int)score;

-(NSDictionary*)serialize;
+(instancetype)deserialize:(NSDictionary*)dict;

@end
