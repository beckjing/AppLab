#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/3/24 14:16
# @Author  : Yuecheng Jing
# @Site    : www.nanosparrow.com
# @File    : config_manager
# @Software: PyCharm

import os
import simplejson


def get_database_info():
    if os.path.exists("../database.json"):
        with open("../database.json", "r") as json_file:
            database_info = simplejson.load(json_file)
        return database_info
    else:
        password = input("input database password:")
        user = input("input database user:")
        host = input("input database host:")
        database_name = input("input database name:")
        database_info = {
            "host": host,
            "user": user,
            "password": password,
            "database_name": database_name
        }
        with open("../database.json", "w") as database_info_file:
            simplejson.dump(database_info,
                            fp=database_info_file,
                            sort_keys=True,
                            indent=4,
                            separators=(',', ': '))
        return database_info


def get_api_info():
    if os.path.exists("../api.json"):
        with open("../api.json", "r") as json_file:
            api_info = simplejson.load(json_file)
        return api_info
    else:
        token = input("input token:")
        api_info = {
            "token": token,
        }
        with open("../api.json", "w") as api_info_file:
            simplejson.dump(api_info, fp=api_info_file, sort_keys=True, indent=4, separators=(',', ': '))
        return api_info


def reset_database_info():
    if os.path.exists("../database.json"):
        os.remove("../database.json")
    return get_database_info()


def reset_api_info():
    if os.path.exists("../api.json"):
        os.remove("../api.json")
    return get_api_info()


if __name__ == '__main__':
    mysql_database = reset_database_info()
    api_info = reset_api_info()
    print(mysql_database)
    print(api_info)
