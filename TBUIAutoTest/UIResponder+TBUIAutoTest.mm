//
//  UIResponder+TBUIAutoTest.m
//  TBUIAutoTestDemo
//
//  Created by 杨萧玉 on 16/3/3.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIResponder+TBUIAutoTest.h"
#import <objc/runtime.h>

union tb_isa_t
{
    tb_isa_t() { }
    tb_isa_t(uintptr_t value) : bits(value) { }
    
    Class cls;
    uintptr_t bits;
    
#if SUPPORT_PACKED_ISA
    
    // extra_rc must be the MSB-most field (so it matches carry/overflow flags)
    // nonpointer must be the LSB (fixme or get rid of it)
    // shiftcls must occupy the same bits that a real class pointer would
    // bits + RC_ONE is equivalent to extra_rc + 1
    // RC_HALF is the high bit of extra_rc (i.e. half of its range)
    
    // future expansion:
    // uintptr_t fast_rr : 1;     // no r/r overrides
    // uintptr_t lock : 2;        // lock for atomic property, @synch
    // uintptr_t extraBytes : 1;  // allocated with extra bytes
    
# if __arm64__
#   define ISA_MASK        0x0000000ffffffff8ULL
#   define ISA_MAGIC_MASK  0x000003f000000001ULL
#   define ISA_MAGIC_VALUE 0x000001a000000001ULL
    struct {
        uintptr_t nonpointer        : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 19;
#       define RC_ONE   (1ULL<<45)
#       define RC_HALF  (1ULL<<18)
    };
    
# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
#   define ISA_MAGIC_MASK  0x001f800000000001ULL
#   define ISA_MAGIC_VALUE 0x001d800000000001ULL
    struct {
        uintptr_t nonpointer        : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 8;
#       define RC_ONE   (1ULL<<56)
#       define RC_HALF  (1ULL<<7)
    };
    
# else
#   error unknown architecture for packed isa
# endif
    
    // SUPPORT_PACKED_ISA
#endif
    
    
#if SUPPORT_INDEXED_ISA
    
# if  __ARM_ARCH_7K__ >= 2
    
#   define ISA_INDEX_IS_NPI      1
#   define ISA_INDEX_MASK        0x0001FFFC
#   define ISA_INDEX_SHIFT       2
#   define ISA_INDEX_BITS        15
#   define ISA_INDEX_COUNT       (1 << ISA_INDEX_BITS)
#   define ISA_INDEX_MAGIC_MASK  0x001E0001
#   define ISA_INDEX_MAGIC_VALUE 0x001C0001
    struct {
        uintptr_t nonpointer        : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t indexcls          : 15;
        uintptr_t magic             : 4;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 7;
#       define RC_ONE   (1ULL<<25)
#       define RC_HALF  (1ULL<<6)
    };
    
# else
#   error unknown architecture for indexed isa
# endif
    
    // SUPPORT_INDEXED_ISA
#endif
    
};

struct tb_objc_object {
    tb_isa_t isa;
};

#if __LP64__
typedef uint32_t tb_mask_t;  // x86_64 & arm64 asm are less efficient with 16-bits
#else
typedef uint16_t tb_mask_t;
#endif
typedef uintptr_t tb_cache_key_t;

struct tb_bucket_t {
    tb_cache_key_t _key;
    IMP _imp;
};

struct tb_cache_t {
    struct tb_bucket_t *_buckets;
    tb_mask_t _mask;
    tb_mask_t _occupied;
};

// class is a Swift class
#define FAST_IS_SWIFT         (1UL<<0)

struct tb_class_data_bits_t {
    // Values are the FAST_ flags above.
    uintptr_t bits;
    bool getBit(uintptr_t bit)
    {
        return bits & bit;
    }
    bool isSwift() {
        return getBit(FAST_IS_SWIFT);
    }
};

struct tb_objc_class : tb_objc_object {
    // Class ISA;
    Class superclass;
    tb_cache_t cache;             // formerly cache pointer and vtable
    tb_class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
};

@implementation UIResponder (TBUIAutoTest)

- (NSString *)nameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([self class], &numIvars);
//    struct tb_objc_class *cls = (__bridge struct tb_objc_class *)[self class];
//    bool isSwift = cls->bits.isSwift();
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {//此处 crash 不要慌！
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

- (NSString *)findNameWithInstance:(UIView *)instance
{
    id nextResponder = [self nextResponder];
    NSString *name = [self nameWithInstance:instance];
    if (!name) {
        return [nextResponder findNameWithInstance:instance];
    }
    if ([name hasPrefix:@"_"]) {  //去掉变量名的下划线前缀
        name = [name substringFromIndex:1];
    }
    return name;
}

@end
