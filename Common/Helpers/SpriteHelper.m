//
//  SKSpriteNode_AnimatedSprite.h
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SpriteHelper.h"

@implementation SKTextureAtlas (SpriteHelper)

NSMutableDictionary*	_atlases = nil;

+(SKTextureAtlas*)atlasWithName:(NSString*)name
{
	if (_atlases == nil)
		_atlases = [NSMutableDictionary dictionary];
	
	SKTextureAtlas* atlas = (SKTextureAtlas*)[_atlases objectForKey:name];
	if (atlas == nil)
	{
		atlas = [SKTextureAtlas atlasNamed:name];
		[_atlases setObject:atlas forKey:name];
	}
	return atlas;
}

@end

@implementation SKTexture (SpriteHelper)

+(SKTexture*)textureWithName:(NSString*)name andAtlas:(NSString*)atlas
{
	SKTextureAtlas* atlasTextures	= [SKTextureAtlas atlasWithName:atlas];
	
	SKTexture* texture = [atlasTextures textureNamed:name];
	
	[texture setFilteringMode:SKTextureFilteringNearest];
	
	return texture;
}

@end

@implementation SKSpriteNode (SpriteHelper)

+(NSArray*)getTextures:(NSString*)animation withAtlas:(NSString*)atlas
{
	SKTextureAtlas* animations	= [SKTextureAtlas atlasWithName:atlas];
	NSMutableArray* textures	= [NSMutableArray array];
	NSArray*        names		= animations.textureNames;
	NSString*       prefix		= [NSString stringWithFormat:@"%@-", animation];
	
	NSPredicate* filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		NSString* name = (NSString*)evaluatedObject;
		return [name hasPrefix:prefix];
	}];
	
	names = [names filteredArrayUsingPredicate:filter];
	names = [names sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [(NSString*)obj1 compare:(NSString*)obj2];
	}];
	
	for (NSString* name in names)
	{
		SKTexture* texture = [animations textureNamed:name];
		[texture setFilteringMode:SKTextureFilteringNearest];
		[textures addObject:texture];
	}

	return textures;
}

+(SKAction*)getAnimation:(NSString*)animation withAtlas:(NSString*)atlas speed:(float)speed andRestore:(BOOL)restore
{
	NSArray* textures = [SKSpriteNode getTextures:animation withAtlas:atlas];
	if (textures.count == 0)
	{
		NSLog(@"Animation %@ not found in %@", animation, atlas);
		return nil;
	}
	
	return [SKAction animateWithTextures:textures timePerFrame:speed resize:NO restore:restore];
}

-(void)animateSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key andSpeed:(float)speed
{
	NSArray* textures = [SKSpriteNode getTextures:animation withAtlas:atlas];
	if (textures.count == 0)
	{
		NSLog(@"Animation %@ not found in %@", animation, atlas);
		return;
	}
	
	SKAction* animate = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:speed resize:NO restore:YES]];
	
	[self runAction:animate withKey:key];
}

-(void)animateSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key
{
	[self animateSprite:animation withAtlas:atlas andKey:key andSpeed:0.1f];
}

+(SKSpriteNode*)createAnimatedSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key andSpeed:(float)speed
{
	NSArray* textures = [SKSpriteNode getTextures:animation withAtlas:atlas];
	if (textures.count == 0)
	{
		NSLog(@"Animation %@ not found in %@", animation, atlas);
		return nil;
	}
    SKSpriteNode*   sprite  = [SKSpriteNode spriteNodeWithTexture:textures[0]];
    SKAction*       animate = [SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:speed resize:NO restore:YES]];
    
    [sprite runAction:animate withKey:key];
    
    return sprite;
}

+(SKSpriteNode*)createAnimatedSprite:(NSString*)animation withAtlas:(NSString*)atlas andKey:(NSString*)key
{
	return [SKSpriteNode createAnimatedSprite:animation withAtlas:atlas andKey:key andSpeed:0.1f];
}

-(void)setPhysicsBodyForCategory:(int)category contactMask:(int)contactMask andCollisionMask:(int)collisionMask
{
	SKPhysicsBody* body = [self createPhysicsBodyForCategory:category withSize:self.size andCenter:CGPointMake(0, 0)];
	
	body.contactTestBitMask = contactMask;
	body.collisionBitMask	= collisionMask;
	
	self.physicsBody = body;
}

-(void)setPhysicsBodyForCategory:(int)category
{
	[self setPhysicsBodyForCategory:category contactMask:0 andCollisionMask:0];
}

-(SKPhysicsBody*)createPhysicsBodyForCategory:(int)category withSize:(CGSize)size andCenter:(CGPoint)center
{
	SKPhysicsBody* body = [SKPhysicsBody bodyWithRectangleOfSize:size center:center];
	
	body.restitution		= 0;
	body.friction			= 0;
	body.allowsRotation		= NO;
	body.affectedByGravity	= NO;
	body.dynamic			= NO;
	body.categoryBitMask	= category;
	body.contactTestBitMask = 0;
	body.collisionBitMask	= 0;
	
	return body;
}

-(void)setPhysicsBodyForCategory:(int)category withSize:(CGSize)size andCenter:(CGPoint)center
{
	SKPhysicsBody* body = [self createPhysicsBodyForCategory:category withSize:size andCenter:center];
	
	self.physicsBody = body;
}


// Constraint to make sure the sprite stays in the "screen"
-(void)setRoomConstraint:(BOOL)isPriest
{
	CGFloat xoffset = self.size.width / 2;
	CGFloat	yoffset = self.size.height / 2;
	
	SKRange*	xRange = [SKRange rangeWithLowerLimit:xoffset			upperLimit:320-xoffset];
	SKRange*	yRange;
 
	if (isPriest)
		yRange = [SKRange rangeWithLowerLimit:self.position.y	upperLimit:self.position.y];
	else
		yRange = [SKRange rangeWithLowerLimit:200-144+yoffset	upperLimit:200-yoffset];
	
	SKConstraint* constraint = [SKConstraint positionX:xRange Y:yRange];
	constraint.enabled = YES;
	
	if (self.constraints == nil)
		self.constraints = [NSArray arrayWithObject:constraint];
	else
		[self.constraints arrayByAddingObject:constraint];
}
@end

@implementation SKNode (NodeHelper)

+(SKNode*)createLabel:(NSString*)text
{
	return [SKNode createLabel:text withColor:nil];
}

#if TARGET_OS_IPHONE

#define CREATE_COLOR(red, green, blue)	[UIColor colorWithRed:0.84 green:0.38 blue:0.99 alpha:1]

#else

#define CREATE_COLOR(red, green, blue)	CGColorCreate(kCGColorSpaceModelRGB, [(float)(red), (float)(green), (float)(blue)])

#endif

+(SKNode*)createLabel:(NSString*)text withColor:(SKColor*)color
{
    SKNode*         node = [SKNode node];
    SKTextureAtlas* font = [SKTextureAtlas atlasWithName:@"Font"];
    
    float		x = 4;
	BOOL		colorFlag = NO;
	SKColor*	defaultColor = color;
	
    for (int i = 0 ; i < text.length ; i++)
    {
        int c = (int) [text characterAtIndex:i];
     
		if (colorFlag)
		{
			colorFlag = NO;
			switch (c)
			{
				case (int)'P': // Purple
					color = [SKColor colorWithRed:0.84 green:0.38 blue:0.99 alpha:1];
					break;
				case (int)'C': // Cyan
					color = [SKColor cyanColor];
					break ;
				case (int)'W': // White ( default so nil )
					color = nil;
					break;
				case (int)'R':
					color = [SKColor redColor];
					break;
				case (int)'Y':
					color = [SKColor yellowColor];
					break;
				case (int)'^':
					color = defaultColor;
					break;
			}
			continue;
		}
		
		if (c == (int)'^')
		{
			colorFlag = YES;
			continue;
		}
		
		if (c >= 0x41 && c <= 0x5A) // A - Z
			c += 0x20; // Convert to lowercase
		
		if (c < 32)
			continue; // Ignore non-ascii characters
		
        if (c != 32) // If it's a space, no need to add a sprite ( unless we're going to scroll !!! )
        {
            NSString* name = [NSString stringWithFormat:@"%d.png", c];
            
            SKTexture* letter = [font textureNamed:name];
			[letter setFilteringMode:SKTextureFilteringNearest];

            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:letter];
			if (color != nil)
			{
				sprite.color = color;
				sprite.colorBlendFactor = 1.0f;
			}
			
            sprite.position = CGPointMake(x, 4);
            [node addChild:sprite];
        }
        x += 8;
    }
    
    return node;
}

@end
