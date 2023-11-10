FROM ubuntu

# ENV TZ="America/Vancouver"
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y iptables tcpdump dsniff iproute2 python3 python3-pip tmux dnsutils
RUN pip3 install scapy mitmproxy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Vancouver
RUN apt-get install -y tzdata vim curl
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
