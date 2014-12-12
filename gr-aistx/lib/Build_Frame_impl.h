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
 
#ifndef INCLUDED_AISTX_BUILD_FRAME_IMPL_H
#define INCLUDED_AISTX_BUILD_FRAME_IMPL_H

#include <AISTX/Build_Frame.h>

#define __VERSION 0.3

namespace gr {
  namespace AISTX {

    class Build_Frame_impl : public Build_Frame
    {
     private:
		bool d_repeat;
		bool d_enable_NRZI;
		//char * d_sentence;
		char *payload;	// [the 01 rapresentation of the sentence as taken from input]
		unsigned short LEN_SENTENCE;
		unsigned short LEN_PAYLOAD;
		
     public:
        Build_Frame_impl(const char *sentence, bool repeat, bool enable_NRZI);
        ~Build_Frame_impl();

		void dump_buffer(const char *b, int buffer_size);
		char * int2bin(int a, char *buffer, int buf_size);      
		int stuff (const char *in, char *out, int l_in);
		void pack (int orig_ascii, char *ret, int bits_per_byte);
		void nrz_to_nrzi(char *data, int length);
		void reverse_bit_order(char *data, int length);
		unsigned long unpack(char *buffer, int start, int length);
		void compute_crc(char *buffer, char *ret, unsigned int len);
		void byte_packing(char *input_frame, unsigned char *out_byte, unsigned int len);

      // Where all the action really happens
      int work(int noutput_items,
	       gr_vector_const_void_star &input_items,
	       gr_vector_void_star &output_items);
    };

  } // namespace AISTX
} // namespace gr

#endif /* INCLUDED_AISTX_BUILD_FRAME_IMPL_H */

