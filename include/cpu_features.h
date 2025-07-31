/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef HC_CPU_FEATURES_H
#define HC_CPU_FEATURES_H

#include <stdio.h>

#if defined(__x86_64__) || defined(_M_X64)
#include <cpuid.h>
#endif

// SIMD detection

int cpu_supports_sse2 ();
int cpu_supports_ssse3 ();
int cpu_supports_xop ();
int cpu_supports_avx2 ();
int cpu_supports_avx512f ();
int cpu_chipset_test ();

#endif // HC_CPU_FEATURES_H
