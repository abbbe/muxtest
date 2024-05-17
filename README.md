# muxtest

This repository implements a testbed for flow tracker and multiplexor.
It deploys cointainers A, B, and C.
We run flows between A and C.
Container B is used for manipulating the flows.

## flow tracking

## flow multiplexing

## implementation

## testing

There is a main test script which brings up a testbed and invoke other test scripts.
Below is an example of HTTP and HTTP requests flowing from A to C via B.
The requests are intercepted by mitmproxy on B.

```
abb@box:~/muxtest$ ./test.sh
...
+ docker exec containera curl http://10.0.0.3/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   187  100   187    0     0  18331      0 --:--:-- --:--:-- --:--:-- 18700
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
</ul>
<hr>
</body>
</html>

+ docker exec containera curl -k https://10.0.0.3/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   187  100   187    0     0  14107      0 --:--:-- --:--:-- --:--:-- 14384
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
</ul>
<hr>
</body>
</html>
...

+ docker logs containerb
[22:32:52.587] HTTP(S) proxy listening at *:8080.
[22:32:53.514][10.0.0.1:55078] client connect
[22:32:53.520][10.0.0.1:55078] server connect 10.0.0.3:80
10.0.0.1:55078: GET http://10.0.0.3/ HTTP/1.1
    << HTTP/1.0 200 OK 187b
[22:32:53.524][10.0.0.1:55078] server disconnect 10.0.0.3:80
[22:32:53.525][10.0.0.1:55078] client disconnect
[22:32:53.611][10.0.0.1:37466] client connect
[22:32:53.628][10.0.0.1:37466] server connect 10.0.0.3:443
[22:32:53.658][10.0.0.1:37466] server disconnect 10.0.0.3:443
10.0.0.1:37466: GET https://10.0.0.3/ HTTP/2.0
    << HTTP/1.0 200 OK 187b
```
