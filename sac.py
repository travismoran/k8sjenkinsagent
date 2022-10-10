#!/usr/bin/python3
import os
import socket
import sys
import dns.resolver
import linecache
import re
from slack_sdk.webhook import WebhookClient



# terraform file path argument
farg = str(sys.argv[1])

# slack webhook url
surl = str(sys.argv[2])

# example usage
# python3 signalwire_acl_check.py /usr/src/infra/terraform/myaclfile.tf https://myslackurl.com

print ('query sip.signalwire.com for current IP list.')

domain = "sip.signalwire.com"
iplist = []
mislist = []
acllist = []
A = dns.resolver.resolve(domain, 'A')
for answer in A.response.answer:
    for item in answer.items:
        iplist.append(item.address)



tf = linecache.getline(farg, 121)

# break iplist out into individual IP addresses
pattern = re.compile('(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')
for n in re.finditer(pattern, str(iplist)):
    swip = (n.group(1))

    if swip in tf:
        print(swip, 'string exists in file')
    else:
        print(swip, 'ERR NOT FOUND!')
        mislist.append(swip)


for n in re.finditer(pattern, str(tf)):
    aclip = (n.group(1))
    acllist.append(aclip)


webhook = WebhookClient(surl)


slacktext0 = "Starting SignalWire ACL DNS Update Check."

slacktext1 = "query sip.signalwire.com for current IP list."
slacktext2 = iplist

slacktext3 = "Current terraform signalwire ACL(includes additional static ip addresses)."
slacktext4 = acllist

slacktext5 = "Missing IP Addresses(should be empty if no new IP addresses are found)."
slacktext6 = mislist


slacktext2.sort()
slacktext4.sort()

response = webhook.send(text=str(slacktext0))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext1))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext2))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext3))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext4))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext5))
assert response.status_code == 200
assert response.body == "ok"

response = webhook.send(text=str(slacktext6))
assert response.status_code == 200
assert response.body == "ok"

