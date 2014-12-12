#!/usr/bin/env python
#
# This script is part of the AIS BlackToolkit.
# AiS_TX.py implements a software-based AIS transmitter accordingly to specifications (ITU-R M.1371-4).
#
# A fully functional GnuRadio installation is required, including our AIS Frame Builder block, namely gr-aistx.
#
# Tested on:
# GnuRadio 3.6.5.1
# Debian 7.1.0 wheezy
# GNU C++ version 4.7.3; Boost_104900 
# UHD_003.005.003-0-unknown
# Ettus USRP B100 Version 2)
# 
# Copyright 2013-2014 -- Embyte & Pastus
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Usage example: 
# $ ./AIVDM_Encoder.py --type=1 --mmsi=970010000 --lat=45.6910 --long=9.7235 | xargs -IX ./AiS_TX.py --payload=X --channel=A
#

from gnuradio import blocks
from gnuradio import digital
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.gr import firdes
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import AISTX
import time
import wx

class top_block(grc_wxgui.top_block_gui):

	def __init__(self, p, c, pw, ff, sr, br):
		grc_wxgui.top_block_gui.__init__(self, title="Top Block")
		_icon_path = "/usr/share/icons/hicolor/32x32/apps/gnuradio-grc.png"
		self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

		##################################################
		# Variables
		##################################################
		self.samp_rate = samp_rate = sr
		self.channel_select = channel_select = c
		self.bit_rate = bit_rate = br

		##################################################
		# Blocks
		##################################################
		self.uhd_usrp_sink_0 = uhd.usrp_sink(
			device_addr="",
			stream_args=uhd.stream_args(
				cpu_format="fc32",
				channels=range(1),
			),
		)
		self.uhd_usrp_sink_0.set_samp_rate(samp_rate)
		self.uhd_usrp_sink_0.set_center_freq(uhd.tune_request_t(161975000+50000*c,ff), 0)
		self.uhd_usrp_sink_0.set_gain(-10, 0)
		self.uhd_usrp_sink_0.set_antenna("TX/RX", 0)
		self.digital_gmsk_mod_0 = digital.gmsk_mod(
			samples_per_symbol=int(samp_rate/bit_rate),
			bt=0.4,
			verbose=False,
			log=False,
		)
		self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vcc((0.9, ))
		self.AISTX_Build_Frame_0 = AISTX.Build_Frame(p, False, True)

		##################################################
		# Connections
		##################################################
		self.connect((self.AISTX_Build_Frame_0, 0), (self.digital_gmsk_mod_0, 0))
		self.connect((self.digital_gmsk_mod_0, 0), (self.blocks_multiply_const_vxx_0, 0))
		self.connect((self.blocks_multiply_const_vxx_0, 0), (self.uhd_usrp_sink_0, 0))


	def get_samp_rate(self):
		return self.samp_rate

	def set_samp_rate(self, samp_rate):
		self.samp_rate = samp_rate
		self.uhd_usrp_sink_0.set_samp_rate(self.samp_rate)

	def get_channel_select(self):
		return self.channel_select

	def set_channel_select(self, channel_select):
		self.channel_select = channel_select
		self.analog_sig_source_x_0.set_frequency(-25000+50000*self.channel_select)

	def get_bit_rate(self):
		return self.bit_rate

	def set_bit_rate(self, bit_rate):
		self.bit_rate = bit_rate

if __name__ == '__main__':

	desc="""GnuRadio-Based AIS Transmitter. Copyright Embyte & Pastus 2013-2014."""

	parser = OptionParser(option_class=eng_option, usage="%prog: [options]", description=desc)
	
	parser.add_option("--payload", help="""Specify the message payload to transmit 
	                                    (e.g., crafted via AIVDM_Encoder)""")
	parser.add_option("--channel", help="""Specify the AIS channel:
	                                    - A: 161.975Mhz (87B)
	                                    - B: 162.025Mhz (88B)""")
	parser.add_option("--power", help="""Specify the transmisson power, between -12dB and +12dB (default is -10dB)""", type="int", default = -10)
	parser.add_option("--filter_frequency", help="""Specify the filter frequency (default is 19MHz)""", type="int", default = 19000000)
	parser.add_option("--sampling_rate", help="""Specify the sampling rate (default is 326.531KHz)""", type="int", default = 326531)
	parser.add_option("--bit_rate", help="""Specify the bit rate (default is 9600 baud)""", type="int", default = 9600)	
	
	(options, args) = parser.parse_args()
	
	if not options.payload:
		parser.error("Payload not specified: -h for help.")

	if not options.channel:
		parser.error("Channel not specified: -h for help.")
		
	if options.channel!="A" and options.channel!="B":
		parser.error("Channel accepts value A or B: -h for help")
	    
	channel_ID = 0 if options.channel=="A" else 1

	tb = top_block(p=options.payload, c=channel_ID, pw=options.power, ff=options.filter_frequency, sr=options.sampling_rate, br=options.bit_rate)
	tb.Run(True)

