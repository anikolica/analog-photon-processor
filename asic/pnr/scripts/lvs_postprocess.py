#!/usr/bin/python
#
###################################################
##
## Created on Nov  1  2013
## by Sandro Bonacini
## CERN PH/ESE/ME
##
###################################################

import re
import sys

s=sys.stdin.read()

s= re.sub("endmodule\s*\Z","	\n\
	assign \VSS! 	=	VSS;	\n\
	assign \VDD! 	=	VDD;	\n\
endmodule\n",s)

if (len(sys.argv)>=1):
	if (sys.argv[1]=="CHIP"):
		s= re.sub("endmodule\s*\Z","	\n\
	assign \VSSPST! = 	VSSPST;	\n\
	assign \VDDPST! =	VDDPST;	\n\
endmodule\n",s)


print s

