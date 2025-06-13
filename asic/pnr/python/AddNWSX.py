#!/usr/bin/python
#
###################################################
##
## Created on Nov  26  2009 
## by Sandro Bonacini
## CERN PH/ESE/ME
##
## Updated and extendend
## Krzysztof Swientek
## 18 Jul 2012
###################################################

import re
import sys
import string
from optparse import OptionParser


def convert_input_to_list(input_opt, name, debug=False):
   #Convert input string which is comma separated list to python list object 
   if input_opt=="":
      list_opt = []
   else:
      list_opt = string.split(input_opt,sep=',')
      i=0
      for elem in list_opt:
         list_opt[i]=string.strip(elem)
         i+=1
   if debug:
      sys.stderr.write("[DEBUG] "+name+" list after stripping: "+str(list_opt)+"\n")
   return list_opt


#Debug line may be very usefull
#sys.stderr.write(str(sys.argv))

parser = OptionParser(usage="%prog [options] [input_file [output_file]]",
   version="%prog 0.2")
parser.add_option("-m", "--modules", dest="modules", default='',
   help="Python regexp list (comma separated) describing nmodules to be excluded from SX() NW() connections")
parser.add_option("-H", "--hierarchical-names", dest="hierarchical_names", default='',
   help="List of signal to be added in entire Verilog hierarchy (comma separated)")
parser.add_option("-r", "--regexp-config-file", dest="regexp_config_file", default='',
      help="Substitution regular expressons two-column config file. First column regexp, second column substitution")
parser.add_option("-n", "--no-short-io", dest="no_short_io", action="store_true", 
   default=False, help="turn off short_io conversions")
parser.add_option("-v", "--verbose", dest="verbose", action="store_true", 
   default=False, help="show status of script")
parser.add_option("-d", "--debug", dest="debug", action="store_true", 
   default=False, help="show debug information")

(options, args) = parser.parse_args()
if options.debug:
   sys.stderr.write(str(sys.argv))
   sys.stderr.write("[DEBUG] Read options and arguments: "+str(options)+"\n"+str(args)+"\n")


#Reading additional module name which should not be connected to SX and NW
additional_modules = convert_input_to_list(options.modules,"modules",options.debug)

#Reading additional hierarchical signals which should be added in entire Verilog hierarchy 
add_in_hierarchy = convert_input_to_list(options.hierarchical_names,"hierarchical_names",options.debug)

#Read config file
regexp_list=[]
if options.regexp_config_file != "":
   file = open(options.regexp_config_file,'r')
   l=file.readline()
   while l!= "":
      ll=string.split(l[0:-1],sep=l[0])
      regexp_list.append([ll[1],ll[2]])
      l=file.readline()
   file.close()
if options.debug:
   sys.stderr.write("[DEBUG] regexp list: "+str(regexp_list)+"\n")

#Reading input code from files or standard input 
if (len(args) > 1):
   if options.verbose:
      sys.stderr.write("Reading from file: "+agrs[1]+"\n")
   INFILE = open(agrs[1],'r')
   s = INFILE.read()
   INFILE.close()
else:
   if options.verbose:
      sys.stderr.write("Reading from standard input\n")
   s=sys.stdin.read()


#Taking module names from code
if options.verbose:
   sys.stderr.write("Looking for module names\n")
findModule = re.compile('module +([A-Za-z]+\w*)')
modules=findModule.findall(s)

if additional_modules!=['']:
   modules.extend(additional_modules)

if options.debug:
   sys.stderr.write("[DEBUG] Modules list: "+str(modules)+"\n")


#Applying standard conversions:
# -- NW and SX added for all cells (necessary only for standard cells) 
# -- short_io pads have to be connected to supplies
if options.verbose:
   sys.stderr.write("Applying standard conversions\n")
s=re.sub("\.VDD\((\w+)\)",".VDD(\\1), .NW(\\1)",s)
s=re.sub("\.GND\((\w+)\)",".GND(\\1), .SX(\\1)",s)
#s=re.sub("(?s)(module [^;]+)([,(]\s*)GND(\s*[,)])([^;]*);","\\1\\2GND,NW,SX\\3\\4; inout NW,SX;",s)
if len(add_in_hierarchy) != 0:
   string_to_add=",".join(add_in_hierarchy)
   s=re.sub("(?s)(module [^;]+)([,(]\s*)GND(\s*[,)])([^;]*);","\\1\\2GND,"+string_to_add+"\\3\\4; inout "+string_to_add+";",s)
if not options.no_short_io:
   s=re.sub(".PAD\(",".VDD(VDD), .DVDD(DVDD), .DVSS(DVSS), .PAD(", s)
   s=re.sub("(?s)(SRAM\dD\w?\d+X\d+D\d+S\dM\d [^;]*),\s*\.SX\(\w+\)", "\\1" ,s)
   s=re.sub("(?s)(SRAM\dD\w?\d+X\d+D\d+S\dM\d [^;]*),\s*\.NW\(\w+\)", "\\1" ,s)
   s=re.sub("(?s)SIOBREAK([^;()]+_A) ([^;]+)\);", "SIOBREAK\\1 \\2.DVSS(DVSS), .DVDD(DVDD));" ,s)
   s=re.sub("(?s)SIOWIRE_NOESD([^;]+)\.VDD\(VDD\), \.DVDD\(DVDD\), \.DVSS\(DVSS\),?([^;]+);", "SIOWIRE_NOESD\\1 \\2;" ,s)
   s=re.sub("(?s)SIOWIRE_ESD([^;]+)\.VDD\(VDD\), \.DVDD\(DVDD\),?([^;]+);", "SIOWIRE_ESD\\1 \\2;" ,s)
   s=re.sub("(?s)SIODVDD ([^;()]+) [^;]*;", "SIODVDD \\1 (.DVSS(DVSS), .DVDD(DVDD));" ,s)
   s=re.sub("(?s)SIODVSS ([^;()]+) [^;]*;", "SIODVSS \\1 (.GND(GND), .DVSS(DVSS));" ,s)
   s=re.sub("(?s)SIOVDD ([^;()]+) [^;]*NW\((\w*)VDD(\w*)\)[^;]*;", "SIOVDD \\1 (.VDD(\\2VDD\\3), .GND(\\2GND\\3));" ,s)
   s=re.sub("(?s)SIOGND ([^;()]+) [^;]*GND\((\w+)\)[^;]*;", "SIOGND \\1 (.GND(\\2), .DVSS(DVSS));" ,s)
   s=re.sub("(?s)DVDD. .,\s*.DVSS. .,\s*.VDD.VDD., .NW.VDD., .SX.GND..;", "DVDD(DVDD),.DVSS(DVSS),.VDD(VDD));",s)


#Deleting SX and NW connections of modules and additional modules/cells
if options.verbose:
   sys.stderr.write("Deleting NW and SX connections from modules and adding hierarchical signals\n")

findLocalMod = re.compile("[\t ]+("+string.join(modules,"|")+") \\\\?[a-zA-Z0-9_\[\]]+")
if len(additional_modules)!=0:
   #Additional modules are exceptions they shouldn't have neither NW, SX connections nor hierarchical signals
   findAddMod = re.compile("[\t ]+("+string.join(additional_modules,"|")+") \\\\?[a-zA-Z0-9_\[\]]+")
else:
   findAddMod=None
findGndToDel=re.compile("\.GND\((\w+)\), \.SX\(\w+\)")
findVddToDel=re.compile("\.VDD\((\w+)\), \.NW\(\w+\)")
findEndInst=re.compile("\);")

ss = string.split(s,sep="\n")
inMod=False
special_mod=False
nss = []

string_to_add=""
if len(add_in_hierarchy) != 0:
   for l in add_in_hierarchy:
      string_to_add += ", ."+l+"("+l+")"

for line in ss:
   if not inMod:
      if findLocalMod.search(line) != None:
         inMod=True
         if findAddMod != None:
            if findAddMod.search(line) != None:
               special_mod=True
   else:
      if findGndToDel.search(line) != None:
         if special_mod:
            line = findGndToDel.sub(".GND(\\1)",line)
         else:
            line = findGndToDel.sub(".GND(\\1)"+string_to_add,line)
      if findVddToDel.search(line) != None:
         line = findVddToDel.sub(".VDD(\\1)",line)
      if findEndInst.search(line) != None:
         inMod=False
         special_mod=False
   nss.append(line) 
s = string.join(nss,"\n")

#Apply all additional transformations
for l in regexp_list:
   if options.verbose:
      sys.stderr.write("Using regexp: s/"+l[0]+"/"+l[1]+"/\n")
   s=re.sub(l[0],l[1],s)

#Writing to file or on standard output
if (len(args) > 2):
   if options.verbose:
      sys.stderr.write("Writing to file"+args[2]+"\n")
   OUTFILE = open(args[2],'w')
   OUTFILE.write(s)
   OUTFILE.close()
else:
   if options.verbose:
      sys.stderr.write("Writing to standard output\n")
   print s

