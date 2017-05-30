#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Author: Siyi Xie (siyi.xie@cootek.cn)
# Created On: 2016-09-09
#
# push util for binary api
#


'''
Reference:
https://www.pubnub.com/knowledge-base/discussion/234/how-do-i-test-my-pem-key
'''


import json
import logging
import os
import socket
import ssl
import struct
import sys
import time
import uuid
import argparse
import sys

from utils import normalizer


PUSH_DRY = 'dry'
PUSH_DEVELOPMENT = 'dev'
PUSH_PRODUCTION = 'production'

APNS_HOST = 'gateway.push.apple.com'
APNS_HOST_SANDBOX = 'gateway.sandbox.push.apple.com'
APNS_PORT = 2195

KEY_DIR = 'keys'
KEY_PRODUCTION = 'apn-key-production.pem'
KEY_DEVELOPMENT = 'apn-key-dev.pem'


CURRENT_DIR = os.path.dirname(__file__)

APNS_ERRORS = {
    1:'Processing error',
    2:'Missing device token',
    3:'missing topic',
    4:'missing payload',
    5:'invalid token size',
    6:'invalid topic size',
    7:'invalid payload size',
    8:'invalid token',
    255:'Unknown'
}


def push(mode, device_tokens, push_message=None):
    cert_path = cert_file(mode)
    logging.debug('cert path = %s' % (cert_path))

    if not os.path.exists(cert_path):
        logging.error("Invalid certificate path: %s" % cert_path)
        sys.exit(1)

    # expiry = time.time() + 3600

    try:
        sock = ssl.wrap_socket(
            socket.socket(socket.AF_INET, socket.SOCK_STREAM),
            certfile=cert_path
        )
        host = APNS_HOST if mode == PUSH_PRODUCTION else APNS_HOST_SANDBOX
        sock.connect((host, APNS_PORT))
        sock.settimeout(1)
    except Exception as e:
        logging.error("Failed to connect: %s" % e)
        sys.exit(1)

    logging.info("Connected to APNS\n")

    payload = json.dumps(push_message)
    for token in device_tokens:
        logging.info("Sending push notifications, token= %s" % token)

        device = token.decode('hex')
        # items = [1, ident, expiry, 32, device, len(payload), payload]
        items = [0, 32, device, len(payload), payload]

        try:
            # sent = sock.write(struct.pack('!BIIH32sH%ds' %len(payload), *items))
            sent = sock.write(struct.pack('!BH32sH%ds' %len(payload), *items))
            if sent:
                logging.info("Message sent\n")
            else:
                logging.error("Unable to send message\n")
        except socket.error as e:
            logging.error("Socket write error: %s", e)

        # If there was an error sending, we will get a response on socket
        try:
            response = sock.read(6)
            command, status, failed_ident = struct.unpack('!BBI',response[:6])
            logging.info("APNS Error: %s\n", APNS_ERRORS.get(status))
            sys.exit(1)
        except socket.timeout:
            pass
        except ssl.SSLError:
            pass

    sock.close()


def dry_push(device_tokens, push_mesage=None):
    for token in device_tokens:
        logging.info('token: %s' % (token))


def cert_file(mode):
    pem_file = None
    if mode == PUSH_PRODUCTION:
        pem_file = KEY_PRODUCTION
    else:
        pem_file = KEY_DEVELOPMENT

    abs_keys_dir = os.path.join(CURRENT_DIR, KEY_DIR)
    return os.path.join(abs_keys_dir, pem_file)


def tokens_from_file():
    tokens = []
    with open('tokens.txt', 'r') as f:
        for line in f.readlines():
            if '#' in line:
                continue
            else:
                tokens.append(line.strip())
    return tokens


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)

    parser = argparse.ArgumentParser(description="Send test APNS notifications to device using cert\
        by legacy binary provider API. It is hight recommend to use the modern APNs API which conforms to \
        HTTP/2 protocol. See the Apple guide for details.")
    parser.add_argument('-d', '--dry', help="dry run", action="store_true", default=False)
    parser.add_argument('-m', '--mode', help="push mode: dry, dev, production", \
        default='dev', choices=['dry', 'dev', 'production'])
    parser.add_argument('-t', '--token', help="tokens", type=str, nargs='*')

    parser.set_defaults(mode=PUSH_DEVELOPMENT)
    args = parser.parse_args()
    if args.token is None or len(args.token) == 0:
        args.token = tokens_from_file()

    apn_message = normalizer.load_push_message()
    if apn_message is None:
        logging.error('push info message is none')
        sys.exit(1)

    logging.debug('args= %s', str(args))
    logging.info('apn-message: %s' % (apn_message))

    if args.mode == PUSH_DRY:
        dry_push(args.token)
    else:
        push(args.mode, args.token, push_message=apn_message)

    logging.info("Complete\n")
