# Man in the Middle Docker Demo

### #The original source is from https://github.com/kientuong114
[This repo is original](https://github.com/kientuong114/docker-mitm.git)  
___
This is a really simple demo to showcase a Man in the Middle (MitM) attack via ARP poisoning using Docker containers.

The idea is that this example should be really quick to set-up and lightweight: the only softwares to download are Docker and docker-compose, everything else is managed by the container's configuration. Then, the only thing that remains is to run the attack itself.

The tools used are [mitmproxy](http://mitmproxy.org), [arpspoof](https://www.monkey.org/~dugsong/dsniff/) and [Docker](http://www.docker.com)

## Setup

There are 3 containers, Milad, Otoha and Jeff.

- **Milad**: is hosting an http server, serving the files contained in `milad_files`
- **Otoha**: is a container with Firefox running on it. To connect to firefox from the host, visit `http://localhost:5800`.
- **Jeff**: is a container meant to be used via bash. To run commands, just run `docker exec -it mitm_jeff /bin/bash`. This container has the `jeff_files` folder mounted on the container as `/demo` 

The three containers are connected together with a docker bridge network called `mitm`

## How to run the demo

1. Install Docker, docker-compose, then run `docker-compose up -d`
2. Connect to Otoha's Firefox instance and visit `http://milad/`. This should show the actual website served by Milad
3. You may also connect to otoha via command line (`docker exec -it mitm_alice /bin/sh`) and see which MAC address corresponds to Milad's IP address
4. Open 2 instances of bash on Jeff's container (or, equivalently, use tmux with two splits) and run the `dig` command to discover the IPs of Otoha and Milad:

```
$ dig otoha
$ dig milad
```

5. With this information, now run arspoof twice, once for each bash instance. In this case, both of hostname are resolved thank to the function of Docker.
[Reffed site](https://www.virtualizationhowto.com/2023/03/docker-compose-static-ip-configuration/)

In the first bash window:
```
$ arpspoof -t otoha milad
```

In the second bash window:
```
$ arpspoof -t milad otoha
```

6. Now you may verify in Otoha's `sh` instance that `ip neighbor` shows that Milad's IP is now associated to Jeff's MAC address, meaning that the ARP spoofing was successful. In any case, reloading the page still shows the normal website, since Jeff is not blocking any packets yet.
7. Now run the `add_iptables_rule.sh` script in the `demo` folder. This will add a rule to `iptables` to forward every packet with destination port 80 to the proxy
8. You may verify that Otoha's browser will give an error when reloading the page. This is because Jeff is not blocking the packets in pitables and forwarding them to the proxy. Since the proxy is not active yet, the packets are simply dropped.
9. Now we activate the proxy in passive mode:

```
$ mitmproxy -m transparent
```

10. Reload the browser page: the honest page will show again, but mitmproxy will show that the request passed through Jeff
11. Now shut down the proxy and activate it again, this time with the script that modifies the contents of the page:
```
$ mitmproxy -m transparent -s /demo/proxy.py
```
12. Reload the browser page: the attacker has changed the contents of the website.
13. To shut down everything use the `del_iptables_rul.sh` script in the `demo` folder to remove the iptables rule and turn off the two arpspoof instances


## The points I changed
- I changed some points so that I can do presentation smoothly using this demo.
    - Hostname - For adjusting my environment  
    - HTML file - Just changed context  
    - Timezone - I changed Dockerfile's three RUN commands so that tzdata is installed as expected (Line 9,10,11). I reffered [this answer in stackoverflow](https://serverfault.com/a/1016972). It took time to realize and catch up that there is constraints for setting timezone concurrently as container starting.

