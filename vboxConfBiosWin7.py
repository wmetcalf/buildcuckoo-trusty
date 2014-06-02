#!/usr/bin/env python  
#############################################################################################################
# This script is take from http://blog.michaelboman.org/2014/01/making-virtualbox-nearly-undetectable.html  #
#############################################################################################################
import re  
import subprocess  
import sys  
import os  
import json  
import random
   
from pprint import pprint  
   
def cloneMAC():
  ifconfig_out = runcmd(["/sbin/ifconfig","eth0"])
  regex = r"HWaddr (?P<mac>([0-9A-Fa-f]{2}[:-]){5}[0-9a-fA-F]{2})"
  pat = re.compile(regex, re.I | re.S | re.M)
  print ifconfig_out
  if pat.search(ifconfig_out):
      mac = pat.search(ifconfig_out).group("mac").split(":")
      mac[0] = int(mac[0], 16)
      mac[1] = int(mac[1], 16)
      mac[2] = int(mac[2], 16)
      mac[3] = random.randint(0x00, 0x7f)
      mac[4] = random.randint(0x00, 0xff)
      mac[5] = random.randint(0x00, 0xff)
      pprint(mac)
      return ''.join(map(lambda x: "%02x" % x, mac))
 
def randomMAC():  
  # 00:1b:fc = ASUSTek COMPUTER INC.  
  mac = [ 0x00, 0x1b, 0xfc,  
    random.randint(0x00, 0x7f),  
    random.randint(0x00, 0xff),  
    random.randint(0x00, 0xff) ]  
  return ''.join(map(lambda x: "%02x" % x, mac))  
   
def getnewmac(hostname):  
  regex = r"(%s)\s+([0-9A-Fa-f]+)\s+([0-9\.]+)" % hostname  
  pat = re.compile(regex, re.I | re.S | re.M)  
  with open("/data/macs.txt") as fh:  
    for line in fh:  
      if pat.search(line):  
        (hostname,mac,ip) = pat.match(line).groups()  
        if mac:  
          return mac  
  return randomMAC()  
   
def runcmd(cmd):  
  try:  
    print "Executing %s" % ' '.join(cmd)  
    output = subprocess.check_output(cmd)  
    print output  
    return output  
  except:  
    print "Failed"  
    return None  

def gethd():
    hd ={}
    hdparm = runcmd(["sudo","hdparm","-i","/dev/sda"])
    #Model=ST2000DM001-1CH164, FwRev=CC26, SerialNo=S1E1R0TH
    m = re.search(r"\s*?Model=(?P<Model>[^,]+),\s*?FwRev=(?P<FwRev>[^,]+),\s*?SerialNo=(?P<SerialNo>[^\r\n]+)[\r\n]",hdparm)
    if m:
        hd["SerialNumber"] = "string:" + m.group("SerialNo")
        hd["FirmwareRevision"] = m.group("FwRev")
        hd["ModelNumber"] = m.group("Model")
    for key, value in hd.iteritems():
      if value == None:
        del hd[key]
      else:
        if isinstance( value, ( int, long ) ):
          hd[key] = str(value)
        else:
          hd[key] = value.strip()
    return hd

def getcd():
    cd ={}
    cddrive = runcmd(["cd-drive"])
    m = re.search(r"\nVendor\s*\x3a\s*(?P<vendor>[^\n]+)\s*\nModel\s*\x3a\s*(?P<Model>[^\n]+)\s*\nRevision\s*\x3a\s*(?P<Revision>[^\n]+)\s*\n",cddrive)
    if m:
        cd["ATAPIVendorId"] = m.group("vendor")
        cd["ATAPIProductId"] = m.group("Model")
        cd["ATAPIRevision"] = m.group("Revision")
        cd["ATAPISerialNumber"] = "string:" + str(random.randint(1,10**(20-1)))
    for key, value in cd.iteritems():
      if value == None:
        del cd[key]
      else:
        if isinstance( value, ( int, long ) ):
          cd[key] = str(value)
        else:
          cd[key] = value.strip()
    print cd
    return cd

# Gather system information  
def getdmi():  
  dmi = {}  
  
   # Anti-VM detection, DMI BIOS information (type 0)  
  dmitmp = runcmd(["sudo","dmidecode","-t0"])  
  dmi['DmiBIOSVendor'] = re.search("Vendor: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiBIOSVersion'] = "string:" + re.search("Version: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiBIOSReleaseDate']= re.search("Release Date: ([0-9\\/\\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
   
  # Anti-VM detection, DMI BIOS information (type 1)  
  dmitmp = runcmd(["sudo","dmidecode","-t1"])  
  dmi['DmiSystemVendor'] = re.search("Manufacturer: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemProduct'] = re.search("Product Name: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemVersion'] = "string:" + re.search("Version: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemSerial'] = "string:" + re.search("Serial Number: ([0-9A-Z\\ \\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemSKU']   = re.search("SKU Number: ([0-9A-Z\\ \\-\\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemFamily'] = re.search("Family: ([0-9A-Z\\ \\-\\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiSystemUuid']  = re.search("UUID: ([0-9A-Z\\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
   
  # Anti-VM detection, DMI BIOS information (type 2)  
  MotherboardTypes = [  
    "Unknown",  
    "Other",  
    "Server Blade",  
    "Connectivity Switch",  
    "System Management Module",  
    "Processor Module",  
    "I/O Module",  
    "Memory Module",  
    "Daughter Board",  
    "Motherboard",  
    "Processor+Memory Module",  
    "Processor+I/O Module",  
    "Interconnect Board"  
  ]  
   
  dmitmp = runcmd(["sudo","dmidecode","-t2"])  
  
  dmi['DmiBoardVendor']   = re.search("Manufacturer: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiBoardProduct']  = re.search("Product Name: ([A-Z0-9\\ \\.\\-/]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiBoardVersion']  = "string:" + re.search("Version: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiBoardSerial']   = "string:" + re.search("Serial Number: ([0-9A-Z\\ \\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
  try:
      dmi['DmiBoardAssetTag']  = re.search("Asset Tag: ([0-9A-Z\\ \\-\\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  except:
      print "Failed to get Asset Tag"
  try:
      dmi['DmiBoardLocInChass'] = re.search("Location In Chassis: ([0-9A-Z\\ \\-\\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  except:
      print "Failed to get Location in Chassis"
  try:
      dmi['DmiBoardBoardType'] = str(MotherboardTypes.index(re.search("Type: ([0-9A-Z\\ \\-]+)", dmitmp, re.I | re.S | re.M).group(1))+1)  
  except:
      print "Failed to get Motherboard Type" 
  # Anti-VM detection, DMI system enclosure or chassis (type 3) 
  ChassiTypes = [  
    "Other",   
    "Unknown",  
    "Desktop",  
    "Low Profile Desktop",  
    "Pizza Box",  
    "Mini Tower",  
    "Tower",  
    "Portable",  
    "Laptop",  
    "Notebook",  
    "Hand Held",  
    "Docking Station",  
    "All In One",  
    "Sub Notebook",  
    "Space-saving",  
    "Lunch Box",  
    "Main Server Chassis",  
    "Expansion Chassis",  
    "Sub Chassis",  
    "Bus Expansion Chassis",  
    "Peripheral Chassis",  
    "RAID Chassis",  
    "Rack Mount Chassis",  
    "Sealed-case PC",  
    "Multi-system",  
    "CompactPCI",  
    "AdvancedTCA",  
    "Blade",  
    "Blade Enclosing"  
    ]  
   
  dmitmp = runcmd(["sudo","dmidecode","-t3"])  
  dmi['DmiChassisVendor']  = re.search("Manufacturer: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiChassisType']   = str(ChassiTypes.index(re.search("Type: ([0-9A-Z\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1))+1)  
  dmi['DmiChassisVersion'] = "string:" + re.search("Version: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiChassisSerial']  = "string:" + re.search("Serial Number: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiChassisAssetTag'] = re.search("Asset Tag: ([A-Z0-9\\ \\.\\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
   
  # Anti-VM detection, DMI processor informatiion (type 4)    
  dmitmp = runcmd(["sudo","dmidecode","-t4"])  
  dmi['DmiProcManufacturer'] = re.search("Manufacturer: ([A-Z0-9\\ \\.]+)", dmitmp, re.I | re.S | re.M).group(1)  
  dmi['DmiProcVersion']   = "string:" + re.search("Version: ([A-Z0-9\\ \\.\\(\\)\\-]+)", dmitmp, re.I | re.S | re.M).group(1)  
      
  for key, value in dmi.iteritems():  
    if value == None:  
      del dmi[key]  
    else:  
      if isinstance( value, ( int, long ) ):  
        dmi[key] = str(value)  
      else:  
        dmi[key] = value.strip()  
  return dmi  
   
dmi = None  
try:  
  fh = open('/data/dmi.txt', 'r')  
  if fh:  
    dmi = json.load(fh)  
    fh.close()  
except Exception:  
  dmi = getdmi()  

  with open('/data/dmi.txt', 'w') as outfile:  
    json.dump(dmi, outfile, sort_keys=True, indent=4, separators=(',', ': '))  
  print json.dumps(dmi, sort_keys=True, indent=4, separators=(',', ': '))  
 

# Globals, of sorts  
DSDT_BIN="/data/dsdt.bin"  
VBoxManage = '/usr/bin/VBoxManage'  
  
 # Get the DSDT   
if not os.path.exists(DSDT_BIN):  
    runcmd(['sudo','dd','if=/sys/firmware/acpi/tables/DSDT','of=%s' % DSDT_BIN])  
  
for target in sys.argv[1:]:  
  # Configure all the virtual BIOS setings  
  for key, value in dmi.iteritems():  
    runcmd([VBoxManage,"setextradata",target,"VBoxInternal/Devices/pcbios/0/Config/" + key,value])  
   
  # Configure DSDT  
  if os.path.exists(DSDT_BIN):  
    runcmd([VBoxManage,"setextradata",target,"VBoxInternal/Devices/acpi/0/Config/CustomTable",DSDT_BIN])  
  
  # Setting guest MAC  
  #newmac = getnewmac(target)  
  newmac = cloneMAC()  
  runcmd([VBoxManage,"modifyvm",target,"--macaddress1",newmac])  
  
  hd = gethd()
  for key, value in hd.iteritems():
    runcmd([VBoxManage,"setextradata",target,"VBoxInternal/Devices/ahci/0/Config/Port0/" + key,value])

  cd = getcd()
  for key, value in cd.iteritems():
    runcmd([VBoxManage,"setextradata",target,"VBoxInternal/Devices/piix3ide/0/Config/PrimaryMaster/" + key,value])
 
