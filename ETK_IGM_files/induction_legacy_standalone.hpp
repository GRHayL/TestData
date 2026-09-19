#ifndef GRHAYL_INDUCTION_LEGACY_STANDALONE_HPP
#define GRHAYL_INDUCTION_LEGACY_STANDALONE_HPP

#include <cstdio>
#include <cstdlib>

typedef double CCTK_REAL;
struct cGH {};

#define CCTK_ARGUMENTS void
#define DECLARE_CCTK_ARGUMENTS
#define DECLARE_CCTK_PARAMETERS const double damp_lorenz = 0.1
#define CCTK_GFINDEX3D(cctkGH, i, j, k) ((i) + 21 * ((j) + 21 * (k)))
#define CCTK_VERROR(...) do { std::fprintf(stderr, __VA_ARGS__); std::exit(EXIT_FAILURE); } while(0)
#define CCTK_VINFO(...) do { std::printf(__VA_ARGS__); std::printf("\n"); } while(0)

#define MINUS2 0
#define MINUS1 1
#define PLUS0  2
#define PLUS1  3
#define PLUS2  4
#define MAXNUMINDICES 5

static const int SHIFTXI=0, SHIFTYI=1, SHIFTZI=2,
  GUPXXI=3, GUPXYI=4, GUPXZI=5, GUPYYI=6, GUPYZI=7, GUPZZI=8,
  PSII=9, LAPM1I=10, A_XI=11, A_YI=12, A_ZI=13,
  LAPSE_PSI2I=14, LAPSE_OVER_PSI6I=15, MAXNUMINTERP=16;

#define SET_INDEX_ARRAYS_3DBLOCK(IJKLOHI)                              \
  int max_shift=(MAXNUMINDICES/2);                                     \
  int index_arr_3DB[MAXNUMINDICES][MAXNUMINDICES][MAXNUMINDICES];      \
  for(int idx_k=IJKLOHI[4]; idx_k<=IJKLOHI[5]; idx_k++)                \
    for(int idx_j=IJKLOHI[2]; idx_j<=IJKLOHI[3]; idx_j++)              \
      for(int idx_i=IJKLOHI[0]; idx_i<=IJKLOHI[1]; idx_i++)            \
        index_arr_3DB[idx_k+max_shift][idx_j+max_shift][idx_i+max_shift] = \
          CCTK_GFINDEX3D(cctkGH, i+idx_i, j+idx_j, k+idx_k)

#endif
