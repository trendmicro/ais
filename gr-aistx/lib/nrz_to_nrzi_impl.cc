/* -*- c++ -*- */
/* 
 * Copyright 2013 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gr_io_signature.h>
#include "nrz_to_nrzi_impl.h"
#include <stdio.h>

namespace gr {
  namespace AISTX {

    nrz_to_nrzi::sptr
    nrz_to_nrzi::make()
    {
      return gnuradio::get_initial_sptr
        (new nrz_to_nrzi_impl());
    }

    /*
     * The private constructor
     */
    nrz_to_nrzi_impl::nrz_to_nrzi_impl()
      : gr_block("nrz_to_nrzi",
		      gr_make_io_signature(1, 1, sizeof(unsigned char)),
		      gr_make_io_signature(1, 1, sizeof(unsigned char)))
    {}

    /*
     * Our virtual destructor.
     */
    nrz_to_nrzi_impl::~nrz_to_nrzi_impl()
    {
    }

    void
    nrz_to_nrzi_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
        /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
    }

    int
    nrz_to_nrzi_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
        const unsigned char *in = (const unsigned char *) input_items[0];
        unsigned char *out = (unsigned char *) output_items[0];
        unsigned char        nrzi_bit;
        unsigned char        nrz_bit;
        unsigned char        d_prev_nrzi_bit = 0;

	  	for(int i = 0;i<noutput_items;++i)
			printf("%d", in[i]);
	  	printf("\n");	

        for (int i = 0; i < noutput_items; i++)
        {     
            nrz_bit = in[i];

            if(nrz_bit == 0)
              {
                nrzi_bit = d_prev_nrzi_bit ^ 1;
              }
            else
              {
                nrzi_bit = d_prev_nrzi_bit;
              }
            out[i] = nrzi_bit;
            d_prev_nrzi_bit = nrzi_bit;

        }

	  	for(int i = 0;i<noutput_items;++i)
			printf("%d", out[i]);
	  	printf("\n");	

        // Tell runtime system how many input items we consumed on
        // each input stream.
        consume_each (noutput_items);

        // Tell runtime system how many output items we produced.
        return noutput_items;
    }

  } /* namespace AISTX */
} /* namespace gr */

