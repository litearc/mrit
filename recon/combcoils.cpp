/*

combines coil images using sensitivity maps to retain phase.

usage: o = combcoils(m, s)

input:
  m : coil images. [x y z coils images]
  s : sensitivity maps. [x y z coils]

output:
  o : single combined image. [x y z]
 
*/ 

#include "mex.h"
#include <math.h>

#define X plhs[0]
#define M prhs[0]
#define S prhs[1]

// don't worry about dynamic memory allocation for now
#define MAXNC 64

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // get sizes
  const mwSize *msize = mxGetDimensions(M);
  size_t ndims = mxGetNumberOfDimensions(M);
  int nx = msize[0];
  int ny = msize[1];
  int nz = msize[2];
  int nc = msize[3];
  int ni = (ndims>4) ? msize[4] : 1;
  int nv = nx*ny*nz;
  
  // create output array
  mwSize outsz[4];
  outsz[0] = nx;
  outsz[1] = ny;
  outsz[2] = nz;
  outsz[3] = ni;
  X = mxCreateNumericArray(ndims-1, outsz, mxDOUBLE_CLASS, mxCOMPLEX);
  double *xr = mxGetPr(X); double *xi = mxGetPi(X);
      
  // get input data
  double *mr = mxGetPr(M); double *mi = mxGetPi(M); /* image data from coils */
  double *sr = mxGetPr(S); double *si = mxGetPi(S); /* senstivities */

  double stmr; // s' * m
  double stmi;
  double stsr; // s' * s
  double stsi;

  int ix, iy, iz, ic, ip, ii; // indices
  int io, co; // image and coil offsets
  int nvpf = nx*ny*nz*nc;

  for (ii=0; ii<ni; ii++){
    io = ii*nvpf;
    // voxel-wise recon ........................................................
    for (ix=0; ix<nx; ix++)
      for (iy=0; iy<ny; iy++)
        for (iz=0; iz<nz; iz++){
          ip = iz*nx*ny+iy*nx+ix;

          // performs a pseudo-inverse, i.e. Ax = b -> x = inv(A'A)*A'b
          // m = s x (x is a scalar)
          // x = (s'm)/(s's)
          stmr = 0.0;
          stmi = 0.0;
          stsr = 0.0;
          stsi = 0.0;
          for (ic=0; ic<nc; ic++){
            co = ic*nv;
            stmr += sr[ip+co]*mr[ip+co+io]+si[ip+co]*mi[ip+co+io];
            stmi += sr[ip+co]*mi[ip+co+io]-si[ip+co]*mr[ip+co+io];
            stsr += sr[ip+co]*sr[ip+co]+si[ip+co]*si[ip+co];
            // stsi is always zero
          } 
          xr[ip+ii*nv] = stmr/stsr;
          xi[ip+ii*nv] = stmi/stsr;
        }
    // ......................................................................... 
  }

}

