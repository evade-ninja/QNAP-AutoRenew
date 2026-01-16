# QNAP-AutoRenew

Script to create/renew SSL certificate on QNAP using ACME/Lets Encrypt. I created this script to allow me to have an auto-renewing SSL certificate on my QNAP NAS Server. I use an internal CA (smallstep) running in a Docker container on my QNAP. I also don't want to expose port 80 of my NAS to the internet. This script utilizes the LEGO ACME client. I chose that client because: it is a standalone executable with no external dependencies and it can place its HTTP-01 challenge files in the QNAP's web server folder. It just works - simply and easily.

Usage:
Create a folder on the QNAP to store the script and LEGO client. It must reside somewhere under `/share` or it won't survive a reboot. Something like `/share/lego` is easy to remember. Download the LEGO ACME client <https://github.com/go-acme/lego> that is applicable to your QNAPs architecture (either x86 or ARM). Un-gzip the executable.

Run the `renew.sh` command. You need to pass 4 arguments to it:

- Full path to LEGO executable
- Full path to LEGO certificate store
- FQDN of the NAS you want a certificate for
- ACME URL of your CA

Sample command line: `./renew.sh "/share/CACHEDEV1_DATA/lego/lego" "/share/CACHEDEV1_DATA/lego/.lego/certificates" "nas-host.awesomedomain.interwebs" "https://fqdn-ca.awesomedomain.interwebs/acme/acme/directory"`


Add an entry to the bottom of crontab to run renew.sh:

`vi /etc/config/crontab`

`15 4 * * * ./renew.sh "/share/CACHEDEV1_DATA/lego/lego" "/share/CACHEDEV1_DATA/lego/.lego/certificates" "nas-name.my-cool-domain.interwebs" "https://certs.my-cool-domain.interwebs/acme/acme/directory" 2>>/dev/null`

Reload crontab:
`crontab /etc/config/crontab && /etc/init.d/crond.sh restart`

Crontab instructions from the QNAP FAQ: <https://www.qnap.com/en/how-to/faq/article/how-to-add-jobs-to-crontab-to-schedule-a-job>


This script is provided as-is with no warranty or support.
