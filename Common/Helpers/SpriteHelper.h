//
//  SKSpriteNode_AnimatedSprite.h
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKTexture (SpriteHelper)
+(SKTexture*)textureWithName:(NSString*)name andAtlas:(NSString*)atlas;
@end

@interface SKSpriteNode (SpriteHelper)

+(SKAction*)getAnimation:(NSString*)animation withAtlas:(NSString*)atlas speed:(float)speed andRestore:(BOOL)restore;

+(NSArray*)getTextures:(NSString*)animation withAtlas:(NSString*)atlas;

+(SKSpriteNode*)createAnimatedSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key;
+(SKSpriteNode*)createAnimatedSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key andSpeed:(float)speed;

-(void)animateSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key;
-(void)animateSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key andSpeed:(float)speed;

-(void)setPhysicsBodyForCategory:(int)category contactMask:(int)contactMask andCollisionMask:(int)collisionMask;
-(void)setPhysicsBodyForCategory:(int)category withSize:(CGSize)size andCenter:(CGPoint)point;
-(void)setPhysicsBodyForCategory:(int)category;

-(SKPhysicsBody*)createPhysicsBodyForCategory:(int)category withSize:(CGSize)size andCenter:(CGPoint)point;

-(void)setRoomConstraint:(BOOL)isPriest;

@end

@interface SKNode (NodeHelper)

+(SKNode*)createLabel:(NSString*)text;
+(SKNode*)createLabel:(NSString*)text withColor:(SKColor*)color;

@end
