/* -*- c++ -*- */

#define AISTX_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "AISTX_swig_doc.i"

%{
#include "AISTX/nrz_to_nrzi.h"
#include "AISTX/Build_Frame.h"
#include "AISTX/DebugME.h"
%}


%include "AISTX/nrz_to_nrzi.h"
GR_SWIG_BLOCK_MAGIC2(AISTX, nrz_to_nrzi);

%include "AISTX/Build_Frame.h"
GR_SWIG_BLOCK_MAGIC2(AISTX, Build_Frame);

%include "AISTX/DebugME.h"
GR_SWIG_BLOCK_MAGIC2(AISTX, DebugME);
