# bba-v1.0
bug bounty automation 
prerequisites
 > subfinder
 > assetfinder
 > amass
 > shuffledns
 > httpx
 > nuclei
 > waybackurls
 > ffuf
 > gf 
 > unfurl
 > massdns
 
 
<h1>Installation </h1> 

git clone  https://github.com/ap062/bba    
cd  bba


<h2> Give path to the variables </h2> <h6>
  
nano bba.sh 

wordlist="wordlist.txt"  

reso="resolvers.txt"   

nuc="nuclei-templates"

save and close 

chmod 777 bba.sh </h6>
<h1> Usage: </h1>
  ./bba.sh target.com
  
  
  >It will do basic recon of your target 
