genmosh
=======

## Author:
Daniel (dmilith) Dettlaff (dmilith [at] verknowsys.com)
I'm also on #freebsd and #scala.pl @ freenode IRC.

## About:
Generation of mosh sessions on demand for "virtual users" using http POST.

## How:
Each user have defined unique sha1 key, stored in: "/Users/#{user_name}/mosh.authkey" on server.
If server key matches key given in params, genmosh generates mosh session on demand for that user without using ssh as proxy.

## Example:

→ curl -X POST http://localhost:51233/auth/501/32a532a8b458d6a3f3ed816464c30ba4fbde8f4f 
MOSH_KEY=KmLzPZkEXeYIHcm3l3hSnw mosh-client 78.46.95.147 60004

## License:

BSD / MIT
