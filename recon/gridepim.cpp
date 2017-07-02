/*

grids 2d data for EPI reconstruction.

usage: m = gridepim(d, k, n)

input:
  d : complex data vector.
  k : complex k-space points.
  n : matrix size to grid.

output:
  m : gridded data.

*/

#include "mex.h"
#include <math.h>

#define M plhs[0]
#define D prhs[0]
#define K prhs[1]
#define N prhs[2]
#define FB prhs[3]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int osf = 3;    // grid oversampling factor
  float kw = 2.5; // kernel width +/-
  int ip, iv, ic, is;

  /* verify inputs. */
  if (nrhs != 4) mexErrMsgTxt("usage: m = gridepim(d, k, n, flyback)");
  if (!mxIsComplex(D)) mexErrMsgTxt("data must be complex!");

  size_t ndim = mxGetNumberOfDimensions(D);
  const mwSize *datasz = mxGetDimensions(D);
  int np = datasz[0]; // # points in readout
  int nv = datasz[1]; // # views
  int nc = ((int)ndim>2)?datasz[2]:1; // # coils
  int ns = ((int)ndim>3)?datasz[3]:1; // # slices
  int fb = (int)mxGetScalar(FB); // flyback epi?

  // output array dimensions
  int nx = mxGetScalar(N);
  int nxo = osf*nx;
  int ny = nv;

  // output array size
  mwSize outsz[4];
  outsz[0] = nxo;
  outsz[1] = ny;
  outsz[2] = nc;
  outsz[3] = ns;
  int nvox = nxo*ny*nc*ns;

  M = mxCreateNumericArray(ndim, outsz, mxDOUBLE_CLASS, mxCOMPLEX);
  double *mr = mxGetPr(M); double *mi = mxGetPi(M);
  double *dr = mxGetPr(D); double *di = mxGetPi(D);
  double *ko = mxGetPr(K);
  double *ke = (double*)malloc(np*sizeof(double));
  if (fb) /* flyback epi */
    for (ip=0; ip<np; ip++)
      ke[ip] = ko[ip];
  else
    for (ip=0; ip<np; ip++)
      ke[ip] = -ko[ip]+ko[0]+ko[np-1];

  /* density compensation */
  float *w = (float*)malloc(np*sizeof(float));
  for (ip=1; ip<np-1; ip++)
    w[ip] = fabs((ko[ip+1]-ko[ip-1])/2);
  w[0] = w[1];
  w[np-1] = w[np-2];

  /* zero output */
  for (ip=0; ip<nvox; ip++){
    mr[ip] = 0.0;
    mi[ip] = 0.0;
  }

  /* calculate matrix positions. */
  double *xo = (double*)malloc(np*sizeof(double));
  double *xe = (double*)malloc(np*sizeof(double));
  for (ip=0; ip<np; ip++){
    xo[ip] = (nxo-1)*(.5+ko[ip]);
    xe[ip] = (nxo-1)*(.5+ke[ip]);
  }

  int x, y, ivox, idat;
  float kx, xp, dx, ww, wt;

  for (is=0; is<ns; is++){
    for (ic=0; ic<nc; ic++){
      for (iv=0; iv<nv; iv++){
        for (ip=0; ip<np; ip++){
          for (kx=-kw; kx<=+kw; kx++){

            // calculate output array index
            xp = (iv%2)?xe[ip]:xo[ip];
            x = round(xp+kx);
            y = iv;
            ivox = is*(nc*nxo*ny)+ic*(nxo*ny)+y*nxo+x;

            // don't worry about data at the edge.
            if (x<=0 || x>=nxo-1) continue;

            // compute tri-linear kernel weighting.
            dx = fabs((x-xp)/kw);
            if (dx > 1) continue;
            wt = 1-dx;

            // density
            ww = (iv%2)?w[np-ip-1]:w[ip];

            idat = is*(nc*np*nv)+ic*(np*nv)+iv*np+ip;
            mr[ivox] += ww*wt*dr[idat];
            mi[ivox] += ww*wt*di[idat];
          }
        }
      }
    }
  }

  /* free memory. */
  free(ke);
  free(xo);
  free(xe);
}

