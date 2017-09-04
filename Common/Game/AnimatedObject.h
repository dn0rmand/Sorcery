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

@interface AnimatedObject : NSObject

@property int					id;
@property CGPoint				position;
@property AnimatedObjectType	type;
@property SKSpriteNode*			sprite;
@property BOOL					evil;

-(instancetype)initWithType:(AnimatedObjectType)type andPosition:(CGPoint)position;
+(instancetype)createWithType:(NSString*)type andPosition:(CGPoint)position;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;
-(void)removeFromScene:(SKScene*)scene;
-(void)unload;

-(NSDictionary*)serialize;
+(instancetype)deserialize:(NSDictionary*)dict;

@end
