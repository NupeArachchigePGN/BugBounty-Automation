#!/bin/bash
subfinder -dL input/domains.txt -config config/subfinder-config.yaml -o output/passive_subdomains.txt
dnsx -l output/passive_subdomains.txt -t 50 | tee output/active_subdomains.txt
naabu -l output/active_subdomains.txt  -rate 10000 -top-ports 100 | tee output/active_ports.txt
httpx -l output/active_ports.txt | tee output/active_urls.txt
nuclei -t /root/nuclei-templates/cves/ -l output/active_urls.txt -bs 100 -c 50 -rl 300 -nc | tee output/nuclei_output.txt
notify -pc config/notify-config.yaml -bulk -i output/active_urls.txt
notify -pc config/notify-config.yaml -bulk -i output/nuclei_output.txt
notify -pc config/notify-config.yaml -bulk -i output/active_ports.txt
notify -pc config/notify-config.yaml -bulk -i output/active_subdomains.txt
