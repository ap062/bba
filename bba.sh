domain=$1
wordlist="/home/ap/need/wordlist.txt"
reso="/home/ap/need/reso.txt"



domain_enum(){

mkdir -p $domain $domain/sources $domain/Recon  $domain/Recon/nuclei $domain/Recon/waybackurls  $domain/Recon/gf $domain/Recon/wordlist $domain/Recon/massscan

subfinder -d $domain -o $domain/sources/subfinder.txt
findomain -t  $domain  --quiet | tee $domain/sources/findodmain.txt
assetfinder -subs-only $domain | tee $domain/sources/assetfinder.txt
amass enum  -passive -d $domain -o $domain/sources/passive.txt
shuffledns  -d $domain -w $wordlist -r $reso -o $domain/sources/shuffledns.txt
cat $domain/sources/*.txt > $domain/sources/all.txt

}
domain_enum

resolving_domains(){
#resolve doamin using shuffle_dns
shuffledns -d $domain -list $domain/sources/all.txt -o $domain/domains.txt  -r $reso
}
resolving_domains

http_prob(){
#checking http /https
cat $domain/domains.txt | httpx -threads 200 -o $domain/Recon/httpx.txt
}
http_prob

scanner(){

#cat $domain/Recon/httpx.txt |nuclei -t /home/ap/nuclei-templates/cves/ -c 50 -o $domain/Recon/nuclei/cves.txt
cat $domain/Recon/httpx.txt |nuclei -t $nuc/files/ -c 50 -o $domain/Recon/nuclei/files.txt
#cat $domain/Recon/httpx.txt |nuclei -t $nuc/vulnerabilities/ -c 50 -o $domain/Recon/nuclei/vulnerabilites.txt
#cat $domain/Recon/httpx.txt |nuclei -t $nuc/technologies/ -c 50 -o $domain/Recon/nuclei/technologies.txt

}
scanner

wbs(){

cat $domain/Recon/httpx.txt | waybackurls | tee $domain/Recon/waybackurls/waybackurls.txt
cat $domain/Recon/waybackurls/waybackurls.txt | egrep -v  "\.woff|\.ttf|\.eot|\.png|\.jpeg|\.jpg|\.svg|\.css|\.ico" |sed 's/:80//g;s/:443//g' | sort -u > $domain/Recon/waybackurls/wbresolve.txt


}
wbs

ff(){

ffuf -c -u "FUZZ" -w  $domain/Recon/waybackurls/wbresolve.txt -of csv -o $domain/Recon/waybackurls/temp.txt
cat  $domain/Recon/waybackurls/temp.txt | grep http |awk -F '{print $3}' |tee $domain/Recon/waybackurls/valid.txt
rm -rf $domain/Recon/waybackurls/temp.txt


}
ff

gfp(){

gf xss  $domain/Recon/waybackurls/valid.txt | tee  $domain/Recon/gf/gf.txt
gf sqli $domain/Recon/waybackurls/valid.txt | tee  $domain/Recon/gf/sqli.txt
gf ssrf $domain/Recon/waybackurls/valid.txt | tee  $domain/Recon/gf/ssrf.txt
gf ssti $domain/Recon/waybackurls/valid.txt | tee  $domain/Recon/gf/ssti.txt
}
gfp


cw(){
cat $domain/Recon/waybackurls/valid.txt | unfurl -unique paths > $domain/Recon/wordlist/path.txt
cat $domain/Recon/waybackurls/valid.txt | unfurl -unique keys > $domain/Recon/wordlist/params.txt
}
cw

resolving(){

massdns -r $reso  -t AAAA  -w $domain/Recon/massscan/results.txt   $domain/domains.txt
cat $domain/Recon/massscan/results.txt |awk -F '{print $1}' |tee $domain/Recon/massscan/tmp.txt
gf ip $domain/Recon/massscan/tmp.txt |tee $domain/Recon/massscan/ip.txt
rm -rf $domain/Recon/massscan/tmp.txt

}
resolving
