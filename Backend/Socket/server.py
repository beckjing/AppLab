#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019-08-07 16:35
# @Author  : Yuecheng Jing
# @Site    : www.nanosparrow.com
# @File    : server
# @Software: PyCharm


import socket

HOST = '0.0.0.0'
PORT = 65432

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print('Connect by', addr)
        while True:
            data = conn.recv(1024)
            if not data:
                break
            conn.sendall(data)


