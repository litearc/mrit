/*

fills in grappa coefficients.

usage: k = grap2fillm(r, o, s, c)

input:
  r : complex zero-filled data.
  o : binary array specifying which entries to fill in (1 = fill in).
  s : kernel, with 0 = unsampled, 1 = sampled, 2 = kernel center.
  c : grappa coefficients (2D array [points_per_coil*#coils #coils])

output:
  k : filled-in data.

*/

#include "mex.h"
#include <math.h>
#include <cstring>

#define K plhs[0]
#define R prhs[0]
#define O prhs[1]
#define S prhs[2]
#define C prhs[3]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // get size of data
  const mwSize *datasz = mxGetDimensions(R);
  int np = datasz[0];   // # points in readout
  int nv = datasz[1];   // # views
  int nc = datasz[2];   // # coils
  int npc = np*nv;      // # points per coil
  int nptot = np*nv*nc; // total # points

  // the kernel is a 2D array, with possible entries denoting the following
  // 0 : unsampled data
  // 1 : sampled data
  // 2 : center of the kernel

  // calculate the index of the center of the kernel wrt top-left
  double *s = mxGetPr(S);
  const mwSize *ssz = mxGetDimensions(S);
  int nsx = ssz[0];
  int nsy = ssz[1];
  int i;
  for (i=0; i<nsx*nsy; i++)
    if (s[i] == 2) break;
  int isx = i%nsx;
  int isy = i/nsx;

  // fprintf(stderr, "np nv nc nsx nsy isx isy: %d %d %d %d %d %d %d\n",
  //     np, nv, nc, nsx, nsy, isx, isy);
  // return;

  // calculate # points to up, left, down, right of kernel center
  int nu = isx;
  int nl = isy;
  int nd = nsx-isx-1;
  int nr = nsy-isy-1;

  // fprintf(stderr, "nu nl nd nr: %d %d %d %d\n", nu, nl, nd, nr);
  // return;

  // calculate # 1s (sampled entries) in kernel
  int n1 = 0;
  for (i=0; i<nsx*nsy; i++)
    if (s[i] == 1)
      n1++;
  int n1s = n1*nc; // # sampled points across all coils

  // fprintf(stderr, "n1: %d\n", n1);
  // return;

  // for each 1 value in the kernel, we calculate the 'relative index' in the
  // data array wrt to the kernel center. e.g. how many spaces in the data (K),
  // which is stored as a 1D array in memory, do we need to move left or right
  // (wrt to the kernel center) to get to one of the sampled entries (within the
  // same coil). this is to speed up the dot product calculation later on.
  int j = 0;
  int *idxr = (int*)malloc(n1*sizeof(int)); // relative indices
  for (i=0; i<nsx*nsy; i++)
    if (s[i] == 1)
      idxr[j++] = (i/nsx-isy)*np+(i%nsx-isx);

  // get pointers to data in the matlab arrays
  mwSize dims[3];
  dims[0] = np; dims[1] = nv; dims[2] = nc;
  K = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);
  double *kr = mxGetPr(K); double *ki = mxGetPi(K);

  double *rr = mxGetPr(R); double *ri = mxGetPi(R);
  double *cr = mxGetPr(C); double *ci = mxGetPi(C);
  double *o = mxGetPr(O);

  // copy raw data to output
  memcpy(kr, rr, nptot*sizeof(double));
  memcpy(ki, ri, nptot*sizeof(double));

  int p; // index within a coil of point being filled in
  int q; // index in `r` of a sampled point
  double dotpr, dotpi; // dot products, real and imag

  // loop over data
  int ix, iy, ic1, ic2;
  int ii, jj; // used to store indices so they are not unnecessarily recomputed
  for (ix=isx; ix<np-nd; ix++){
    for (iy=isy; iy<nv-nr; iy++){
      p = iy*np+ix;
      if (o[p] == 1){ // 1 means we want to fill in the data
        // we need to fill in data for all the coils, but for each coil,
        // data from all the coils are needed to fill in a missing point,
        // so there are two coil loops.
        for (ic1=0; ic1<nc; ic1++){ // coil to fill in
          dotpr = 0.0;
          dotpi = 0.0;
          for (ic2=0; ic2<nc; ic2++){ // coil being used for filling in coil ic1
            ii = ic2*npc+p;
            jj = ic1*n1s+ic2*n1;
            for (j=0; j<n1; j++){ // sampled point
              q = ii+idxr[j]; 
              dotpr += rr[q]*cr[jj+j]-ri[q]*ci[jj+j];
              dotpi += rr[q]*ci[jj+j]+ri[q]*cr[jj+j];
            }
          }
          kr[p+ic1*npc] = dotpr;
          ki[p+ic1*npc] = dotpi;
        }
      }
    }
  }

  free(idxr);
}

