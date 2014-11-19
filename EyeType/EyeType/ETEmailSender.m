/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "ETEmailSender.h"
#import "AmazonClientManager.h"
#import <BFTask.h>

@implementation ETEmailSender

/*
 * Uses Amazon SES http://aws.amazon.com/ses/
 * API: SendEmail http://docs.amazonwebservices.com/ses/latest/APIReference/API_SendEmail.html
 */
+(BOOL)sendEmailTo:(NSArray *)recipients replyTo:(NSString *)replyTo subject:(NSString *)subject body:(NSString *)body {

    AWSSESContent *subjectText = [[AWSSESContent alloc] init];
    subjectText.data = subject;

    AWSSESContent *messageBody = [[AWSSESContent alloc] init];
    messageBody.data = body;
    
    AWSSESBody *bodyText = [[AWSSESBody alloc] init];
    bodyText.text = messageBody;
    
    AWSSESMessage *message = [[AWSSESMessage alloc] init];
    message.subject = subjectText;
    message.body = bodyText;
    
    AWSSESDestination *destination = [[AWSSESDestination alloc] init];
    NSMutableArray *toAddresses = [NSMutableArray array];
    for (NSString *recipient in recipients) {
        [toAddresses addObject:recipient];
    }
    destination.toAddresses = toAddresses;

    NSMutableArray *replyToAdresses = [NSMutableArray arrayWithObjects: (replyTo.length > 0) ? replyTo : VERIFIED_EMAIL, nil];
    
    AWSSESSendEmailRequest *ser = [[AWSSESSendEmailRequest alloc] init];
    ser.source = VERIFIED_EMAIL;
    ser.destination = destination;
    ser.replyToAddresses = replyToAdresses;
    ser.message = message;
    
    BFTask *task = [[AmazonClientManager ses] sendEmail:ser];
    [task waitUntilFinished];
    AWSSESSendEmailResponse *response = task.result;
    if (task.error != nil) {
        NSLog(@"Error: %@", task.error);
        return NO;
    }
    
    NSLog(@"Message sent, id %@", response.messageId);
    return YES;
}

@end
