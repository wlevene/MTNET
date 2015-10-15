//
//  MTLogger.h
//  mcf
//
//  Created by Gang.Wang on 13-1-8.
//  Copyright (c) 2013年. All rights reserved.
//

#ifndef mcf_YLogger_h
#define mcf_YLogger_h

#ifndef __OPTIMIZE__


#   define LOG(s, ...)      NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#   define LOG_LINE         LOG(@"---------------");
#   define LOG_BREAK        { for (int i = 0; i < 2; i++) LOG(@" "); }
#   define LOG_METHOD       NSLog(@"%s line %d", __func__, __LINE__)
#   define LOG_RETAIN(obj)  LOG(@"%s retainCount=%d", #obj, (int)CFGetRetainCount((__bridge CFTypeRef)obj))
#   define LOG_OBJECT(obj)  LOG(@"%s=%@", #obj, obj)
#   define LOG_DATE(date)   LOG(@"%s=%@", #date, [date descriptionWithLocale:[NSLocale currentLocale]])
#   define LOG_INT(i)       LOG(@"%s=%d", #i, i)
#   define LOG_FLOAT(f)     LOG(@"%s=%f", #f, f)
#   define LOG_RECT(rect)   LOG(@"%s x=%.2f, y=%.2f, w=%.2f, h=%.2f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#   define LOG_POINT(pt)    LOG(@"%s x=%.2f, y=%.2f", #pt, pt.x, pt.y)
#   define LOG_SIZE(size)   LOG(@"%s w=%.2f, h=%.2f", #size, size.width, size.height)
#   define LOG_RANGE(range) LOG(@"%s loc=%d, len=%d", #range, range.location, range.length)
#   define LOG_TRANSFORM(transform)     LOG(@"%s = %@", #transform, NSStringFromCGAffineTransform(transform));
#   define LOG_TRANSFORM3D(transform3D) LOG(@"%s =\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n\n",#transform3D,transform3D.m11,transform3D.m12,transform3D.m13,transform3D.m14,transform3D.m21,transform3D.m22,transform3D.m23,transform3D.m24,transform3D.m31,transform3D.m32,transform3D.m33,transform3D.m34,transform3D.m41,transform3D.m42,transform3D.m43,transform3D.m44);

#   define LOG_THREAD       LOG(@"thread=%@", [NSThread currentThread])
#   define LOG_STACK        LOG(@"%@", [NSThread callStackSymbols])

#   define LOG_SUPERVIEWS(_VIEW)    { for (UIView* view = _VIEW; view; view = view.superview) { NSLog(@"%@", view); } }
#   define LOG_SUBVIEWS(_VIEW)      LOG(@"%@", [_VIEW performSelector:@selector(recursiveDescription)])

#   define LOG_START(name)  CFAbsoluteTime name##_startTime = CFAbsoluteTimeGetCurrent();
#   define LOG_STOP(name)   LOG(@"%s time=%f sec",#name, CFAbsoluteTimeGetCurrent() - name##_startTime);
#   define LOG_IMAGE(image) \
        if ([image isKindOfClass:[UIImage class]]) { \
            LOG(CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage),UIImagePNGRepresentation(image)); \
        }

#else


#   define LOG(s, ...)      ;
#   define LOG_LINE         ;
#   define LOG_BREAK        ;
#   define LOG_METHOD       ;

#   define LOG_RETAIN(obj)  ;
#   define LOG_OBJECT(obj)  ;
#   define LOG_DATE(date)   ;
#   define LOG_INT(i)       ;
#   define LOG_FLOAT(f)     ;
#   define LOG_RECT(rect)   ;
#   define LOG_POINT(pt)    ;
#   define LOG_SIZE(size)   ;
#   define LOG_RANGE(range) ;
#   define LOG_TRANSFORM(transform)     ;
#   define LOG_TRANSFORM3D(transform3D) ;

#   define LOG_SUPERVIEWS(_VIEW)        ;
#   define LOG_SUBVIEWS(_VIEW)          ;

#   define LOG_THREAD       ;
#   define LOG_STACK        ;

#   define LOG_START(name)  ;
#   define LOG_STOP(name)   ;
#   define LOG_IMAGE(image) ;

#endif

#endif

