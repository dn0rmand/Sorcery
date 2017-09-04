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

@interface Room : NSObject

@property int				id;
@property NSMutableArray*	sprites;
@property NSString*			name;
@property NSMutableArray*	staticObjects;
@property NSMutableArray*	doors;
@property NSMutableArray*	animatedObjects;
@property NSMutableArray*	characters;
@property NSMutableArray*	tiles;
@property NSMutableArray*	hitmap;

-(instancetype)initWithId:(int)id andName:(NSString*)name;
+(instancetype)createWithId:(int)id andName:(NSString*)name;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;
-(void)removeFromScene:(SKScene*)scene;
-(void)unload;
-(id)objectForNode:(SKNode*)node;

-(CollisionType)hitmapAtRow:(int)row andColumn:(int)col;

-(NSDictionary*)serialize;
+(instancetype)deserialize:(int)id from:(NSDictionary*)dict;

@end
