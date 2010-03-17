/*
 *  mo_log.mm
 *  mopho
 *
 *  Created by Spencer Salazar on 11/27/09.
 *  Copyright 2009 Spencer Salazar. All rights reserved.
 *
 */

#include "mo_log.h"

#include <stdarg.h>
#import <Foundation/Foundation.h>

void mo_log(const char *s, ...)
{
    va_list ap;
    va_start(ap, s);
    
    NSString *str = [[NSString alloc] initWithCString:s];
    
    NSLogv(str, ap);
    
    [str release];
    
    va_end(ap);
}
