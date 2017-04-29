/*
 * this file implements a bloch simulator in C, using the hard-pulse
 * approximation. this is called by bloch.m (if the mex file is available),
 * which formats the arguments, including setting default values for the
 * optional ones, and passes them to here.
 *
 * M = blochm(rf, g, p, dt, gam, m0, t1, t2, b0, b1)
 *
 * input:
 *   rf  : rf pulse (complex) (G)
 *   g   : gradient waveforms [gx gy gz] (G/cm)
 *   p   : a 2D array that specifies the positions to evaluate the response at:
 *         | xl xu nx |  xl and xu are the lower and upper limits along x,
 *         | yl yu ny |  and nx is the # of points along x (same with y and z).
 *         | zl zu nz |
 *   dt  : sample-time (ms)
 *   gam : gyromagnetic ratio (kHz/G)
 *   m0  : initial magnetization [nx ny nz 3]
 *   t1  : T1 map [nx ny nz] (ms)
 *   t2  : T2 map [nx ny nz] (ms)
 *   b0  : B0 map [nx ny nz] (Hz)
 *   b1  : B1 map [nx ny nz] (complex) (scale factor)
 *
 * output:
 *   M : final magnetization [nx ny nz 3], where the last dimension contains
 *       the Mx, My, and Mz magnetizations
 */

typedef char char16_t; /* hack */

#include "mex.h"
#include <math.h>

/* aliases for the arguments */
#define M    plhs[0]
#define RF   prhs[0]
#define G    prhs[1]
#define P    prhs[2]
#define DT   prhs[3]
#define GAM  prhs[4]
#define M0   prhs[5]
#define T1   prhs[6]
#define T2   prhs[7]
#define B0   prhs[8]
#define B1   prhs[9]
#define TIME prhs[10]

/* function macros */
#define LINSPACE(l,u,n,i) ((l)+((u)-(l))*(i)/(((n)==1)?1:((n)-1)))
#define ABS2(r,i) sqrt((r)*(r)+(i)*(i))
#define TP (2*M_PI)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* a lot of dummy variables */
  int i, ix, iy, iz, ir;
  double e, a, c, s;
  double x, y, z;
  double ux, uy, uz;
  long double m[3]; long double n[3];

  /* get pointers to raw data */
  double *rfr = mxGetPr(RF);
  double *rfi = mxGetPi(RF);
  double *g   = mxGetPr(G);
  double *p   = mxGetPr(P);
  double dt   = mxGetScalar(DT);
  double gam  = mxGetScalar(GAM);
  double *m0  = mxGetPr(M0);
  double *t1  = mxGetPr(T1);
  double *t2  = mxGetPr(T2);
  double *b0  = mxGetPr(B0);
  double *b1r = mxGetPr(B1);
  double *b1i = mxGetPi(B1);

  /* get rf pulse length and output array size */
  const mwSize *rsize = mxGetDimensions(RF);
  const mwSize *msize = mxGetDimensions(M0);
  int nr = rsize[0];
  int nx = msize[0];
  int ny = msize[1];
  int nz = msize[2];
  int nv = nx*ny*nz;
  
  int time = (int)(mxGetScalar(TIME));
  int nt = (time == 1) ? nr : 1;

  mwSize dims[5];
  for (i=0; i<4; i++)
    dims[i] = msize[i];
  dims[4] = nt;

  M = mxCreateNumericArray(5, dims, mxDOUBLE_CLASS, mxREAL);
  double *o = mxGetPr(M);

  double *gx = &(g[0]);
  double *gy = &(g[nr]);
  double *gz = &(g[2*nr]);

  /* loop over positions */
  for (ix=0; ix<nx; ix++){
    x = LINSPACE(p[0], p[3], nx, ix);
    for (iy=0; iy<ny; iy++){
      y = LINSPACE(p[1], p[4], ny, iy);
      for (iz=0; iz<nz; iz++){
        z = LINSPACE(p[2], p[5], nz, iz);

        /* linear index in 3D array */
        i = iz*nx*ny+iy*nx+ix;

        /* set initial magnetization */
        m[0] = m0[i];
        m[1] = m0[i+nv];
        m[2] = m0[i+2*nv];

        /* loop over rf pulse */
        for (ir=0; ir<nr; ir++){
          
          /* rf pulse rotation */
          e = atan2(rfi[ir],rfr[ir])+atan2(b1i[i],b1r[i]);
          a = TP*gam*dt*ABS2(rfr[ir],rfi[ir])*ABS2(b1r[i],b1i[i]);
          
          c = cos(a); s = sin(a);
          ux = -cos(e); uy = -sin(e); uz = 0.0;
          n[0] = m[0]; n[1] = m[1]; n[2] = m[2];
          m[0] = (c+ux*ux*(1-c))*n[0] + (ux*uy*(1-c)-uz*s)*n[1] + (ux*uz*(1-c)+uy*s)*n[2];
          m[1] = (uy*ux*(1-c)+uz*s)*n[0] + (c+uy*uy*(1-c))*n[1] + (uy*uz*(1-c)-ux*s)*n[2];
          m[2] = (uz*ux*(1-c)-uy*s)*n[0] + (uz*uy*(1-c)+ux*s)*n[1] + (c+uz*uz*(1-c))*n[2];
          
          /* free precession from applied gradients */
          a = TP*gam*dt*(gx[ir]*x+gy[ir]*y+gz[ir]*z)+TP*dt*b0[i]*1e-3;
          n[0] = m[0]; n[1] = m[1];
          m[0] = cos(a)*n[0]+sin(a)*n[1];
          m[1] = -sin(a)*n[0]+cos(a)*n[1];

          /* T1 relaxation and T2 decay */
          if (t2[i] != -1.0){
            m[0] *= exp(-dt/t2[i]);
            m[1] *= exp(-dt/t2[i]);
          }
          if (t1[i] != -1.0)
            m[2] += (1-m[2])*(1-exp(-dt/t1[i]));

          /* store magnetization for current time point */
          if (time == 1){
            o[i+3*nv*ir] = m[0];
            o[i+nv+3*nv*ir] = m[1];
            o[i+2*nv+3*nv*ir] = m[2];
          }

        }

        /* store final magnetization */
        if (time == 0){
          o[i] = m[0];
          o[i+nv] = m[1];
          o[i+2*nv] = m[2];
        }

      }
    }
  }

}

