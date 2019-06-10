#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019-06-05 14:49
# @Author  : Yuecheng Jing
# @Site    : www.nanosparrow.com
# @File    : CacheDemo
# @Software: PyCharm

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'


@app.route('/cache_control')
def cacheControl():
    return jsonify(request.args)


@app.after_request
def add_header(response):
    response.cache_control.max_age = 3600
    return response