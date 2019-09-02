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
@class Wizard;

@interface Door : NSObject

@property int				id;
@property CGPoint           position;
@property StaticObjectType  type;
@property StaticObjectType  key;
@property NSInteger         nextDoor;
@property NSInteger         nextRoom;
@property BOOL              opened;
@property BOOL              animate;
@property SKSpriteNode*		sprite;

-(instancetype)initWithType:(StaticObjectType)type andPosition:(CGPoint)position;
+(instancetype)createWithType:(NSString*)type andPosition:(CGPoint)position;

-(void)addToScene:(SKScene*) scene withGame:(GameEngine*)game;
-(void)removeFromScene:(SKScene*)scene;
-(void)unload;

-(void)OpenAndMoveWizard:(Wizard*)wizard completion:(void (^)(void))block;
-(void)CloseAndMoveWizard:(Wizard*)wizard;
-(void)CloseDoor;
-(NSDictionary*)serialize;
+(instancetype)deserialize:(NSDictionary*)dict;

@end
