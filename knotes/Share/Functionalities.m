//
//  Functionalities.m
//  Knotable
//
//  Created by Nicolas  on 25/5/15.
//
//

#import "Functionalities.h"

@implementation Functionalities

+ (NSString*)mongo_id_generator{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    int i = 0;
    
    char result[20] = {0};
    
    const char *str = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";
    
    for (i=0; i< 17; i++)
    {
        uint32_t bytes[4]={0x00};
        
        if (0 != SecRandomCopyBytes(0, 10, (uint8_t*)bytes))
        {
            return nil;
        }
        
        double_t index = bytes[0] * 2.3283064365386963e-10 * strlen(str);
        
        result[i] = str[ (int)floor(index) ];
    }
    
    NSString *retID = [[NSString alloc] initWithBytes:result length:strlen(result) encoding:NSASCIIStringEncoding];
    
    NSLog(@"Mongo_id_generator: %@ ", retID);
    
    return retID;
}

@end
