//
//  WebManager.h
//  WebTest
//
//  Created by ZhiXing Li on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONManager.h"

@protocol JSWebManagerDelegate <NSObject>
@required
-(void)WebManagerFailed:(NSError*)error;
-(void)ReceivedValue:(ASIHTTPRequest*)req;
@end

enum RequestActionName
{
    None
};

@interface JSWebManager : NSObject
{
    enum RequestActionName m_requestActionName;
    id<JSWebManagerDelegate> delegate;
@public
    JSONManager* m_jsonManager;
    NSString* m_url;
    BOOL                m_isAsync;
}

@property (nonatomic, retain) id   delegate;

-(id)initWithAsyncOption:(BOOL)isAsync;

-(void)CancelRequest;
-(NSData*)SubmitFeedback:(NSString*)text email:(NSString*)addr;
@end
