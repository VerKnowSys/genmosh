
## Author:
Daniel (dmilith) Dettlaff (dmilith [at] verknowsys.com)
I'm also on #freebsd and #scala.pl @ freenode IRC.

## About:
if /Users/501/mosh.authkey sha1 key matches posted params, then generate mosh session on demand for that user.

## Example:

→ curl -X POST http://localhost:51233/auth/501/32a532a8b458d6a3f3ed816464c30ba4fbde8f4f 
MOSH_KEY=KmLzPZkEXeYIHcm3l3hSnw mosh-client 78.46.95.147 60004
