#!/usr/bin/python
import subprocess
import sys
from optparse import OptionParser

#### Maybe random select from these in the future This is needed as setting cpu mfr/model via extadata doesn't seem to do anything ###
#intel=["Intel(R) Core(TM)2 Quad CPU    Q8400  @ 2.66GHz",
#"Intel(R) Core(TM)2 Duo CPU     E8400  @ 3.00GHz",
#"Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz",
#"Intel(R) Core(TM) i7-3820 CPU @ 3.60GHz",
#"Intel(R) Core(TM)2 CPU          4400  @ 2.00GHz",
#"Intel(R) Core(TM)2 Duo CPU     P8600  @ 2.40GHz",
#"Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz",
#"Intel(R) Core(TM) i3-2100 CPU @ 3.10GHz",
#"Intel(R) Celeron(R) CPU G530 @ 2.40GHz",
#"Intel(R) Pentium(R) CPU G645T @ 2.50GHz",
#"Intel(R) Core(TM) i3-2310M CPU @ 2.10GHz",
#"Intel(R) Core(TM) i3-4340 CPU @ 3.60GHz",
#"Intel(R) Core(TM) i3-3110M CPU @ 2.40GHz",
#"Intel(R) Core(TM) i3-4130T CPU @ 2.90GHz",
#"Intel(R) Core(TM) i7-2630QM CPU @ 2.00GHz",
#"Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz"]

#amd=["AMD Sempron(tm) X2 190 Processor",
#"AMD Phenom(tm) II X4 20 Processor",
#"AMD FX(tm)-6300 Six-Core Processor",
#"AMD Athlon(tm) 64 X2 Dual Core Processor 4400+",
#"AMD A4-5000 APU with Radeon(TM) HD Graphics",
#"AMD FX(tm)-8120 Eight-Core Processor,
#"AMD A4-3300M APU with Radeon(tm) HD Graphics"
#"AMD Phenom(tm) II X2 20 Processor"]

parser = OptionParser()
parser.add_option("--vm", dest="vm", type="string", help="target vm")
parser.add_option("--cpu",dest="cpu",  type="string", help="user specified cpu to add")
(options, args) = parser.parse_args()

def cmd_wrapper(cmd):
    print("running command and waiting for it to finish %s" % (cmd))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout,stderr = p.communicate()
    return (p.returncode, stdout, stderr)

def chunkstring(string, length):
    return (string[0+i:length+i] for i in range(0, len(string), length))


if len(options.cpu) < 48:
    options.cpu = "\x20" * (47 - len(options.cpu)) + options.cpu + "\x00"

if options.cpu[-1] is not "\x00":
   print "the cpu target must be null terminated"
   sys.exit(-1)

ar2=[]
sp=list(chunkstring(options.cpu,4))
for e in sp:
    ar2.append(e[::-1].encode("hex"))
print len(ar2)
cmd_wrapper("VBoxManage modifyvm \"%s\" --cpuidset 80000002 %s %s %s %s" % (options.vm,ar2[0],ar2[1],ar2[2],ar2[3]))
cmd_wrapper("VBoxManage modifyvm \"%s\" --cpuidset 80000003 %s %s %s %s" % (options.vm,ar2[4],ar2[5],ar2[6],ar2[7]))
cmd_wrapper("VBoxManage modifyvm \"%s\" --cpuidset 80000004 %s %s %s %s" % (options.vm,ar2[8],ar2[9],ar2[10],ar2[11]))
