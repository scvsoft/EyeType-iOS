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

@implementation ETEmailSender

/*
 * Uses Amazon SES http://aws.amazon.com/ses/
 * API: SendEmail http://docs.amazonwebservices.com/ses/latest/APIReference/API_SendEmail.html
 */
+(BOOL)sendEmailTo:(NSArray *)recipients replyTo:(NSString *)replyTo subject:(NSString *)subject body:(NSString *)body {

    SESContent *subjectText = [[SESContent alloc] init];
    subjectText.data = subject;

    SESContent *messageBody = [[SESContent alloc] init];
    messageBody.data = body;
    
    SESBody *bodyText = [[SESBody alloc] init];
    bodyText.text = messageBody;
    
    SESMessage *message = [[SESMessage alloc] init];
    message.subject = subjectText;
    message.body = bodyText;
    
    SESDestination *destination = [[SESDestination alloc] init];
    for (NSString *recipient in recipients) {
        [destination.toAddresses addObject:recipient];
    }

    NSMutableArray *replyToAdresses = [NSMutableArray arrayWithObjects: (replyTo.length > 0) ? replyTo : VERIFIED_EMAIL, nil];
    
    SESSendEmailRequest *ser = [[SESSendEmailRequest alloc] init];
    ser.source = VERIFIED_EMAIL;
    ser.destination = destination;
    ser.replyToAddresses = replyToAdresses;
    ser.message = message;
    
    SESSendEmailResponse *response = [[AmazonClientManager ses] sendEmail:ser];
    if(response.error != nil) {
        NSLog(@"Error: %@", response.error);
        return NO;
    }
    
    NSLog(@"Message sent, id %@", response.messageId);
    return YES;
}



@end
