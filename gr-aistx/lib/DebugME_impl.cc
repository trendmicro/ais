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

#include <gnuradio/io_signature.h>
#include "DebugME_impl.h"
#include <stdio.h>

namespace gr {
  namespace AISTX {

    DebugME::sptr
    DebugME::make(size_t itemsize)
    {
      return gnuradio::get_initial_sptr
        (new DebugME_impl(itemsize));
    }

    /*
     * The private constructor
     */
    DebugME_impl::DebugME_impl(size_t itemsize)
      : gr::block("DebugME",
		      gr::io_signature::make(1, 1, itemsize),
		      gr::io_signature::make(0, 0, 0)),
		      d_itemsize(itemsize)
    {}

    /*
     * Our virtual destructor.
     */
    DebugME_impl::~DebugME_impl()
    {
    }

    void
    DebugME_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
        /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
    }

    int
    DebugME_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {

		// char / byte
		if (d_itemsize == 1) {
			const unsigned char *in = (const unsigned char *) input_items[0];
	    	for(int i = 0; i<ninput_items[0]; ++i)
				printf ("\\x%.2X", in[i]);
			}
		// float
		else if (d_itemsize == 4) {
			const float *in = (const float *) input_items[0];
			for(int i = 0; i<ninput_items[0]; ++i)
				printf ("\\%.0f", in[i]);
			}
		// complex
		else
			printf ("Complexes not supported yet!");
			
	    std::cout << std::endl;

        // Do <+signal processing+>
        // Tell runtime system how many input items we consumed on
        // each input stream.
        consume_each (noutput_items);

        // Tell runtime system how many output items we produced.
        return 0;
    }

  } /* namespace AISTX */
} /* namespace gr */

