genmosh
=======


## Author:
Daniel (dmilith) Dettlaff (dmilith [at] verknowsys.com)
I'm also on #freebsd and #scala.pl @ freenode IRC.


## About:
Generation of mosh sessions on demand for "virtual users" using http(s) POST.


## How:
Each user have defined unique sha1 key and bound uid, stored in: "/SystemUsers/mosh.keys" on server.
If server key matches key given in params, genmosh generates mosh session on demand for that user without using ssh as proxy.


## Pitfals:
It's obvious that http post example here is NOT secure. It's recommended to have SSL backend (Nginx proxy) for this app.


## Example usage:

Example mosh.keys:
    $ → cat /SystemUsers/mosh.keys
    [{"sha": "31a512a8b358d6a3f3ed816464c3fba4fbde8f4f", "uid": "system-uid"}]

Example request for auth:
    $ → curl -X POST http://localhost:51233/auth/31a512a8b358d6a3f3ed816464c3fba4fbde8f4f 
    MOSH_KEY=KmLzPZkEXeYIHcm3l3hSnw mosh-client 78.46.95.147 60004
    
Example login command:
    $ → eval "$(curl -X POST http://fiend.verknowsys.com:51233/auth/31a512a8b358d6a3f3ed816464c3fba4fbde8f4f)"


## License:

BSD / MIT
