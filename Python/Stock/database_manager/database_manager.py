#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/3/25 23:49
# @Author  : Yuecheng Jing
# @Site    : www.nanosparrow.com
# @File    : database_manager
# @Software: PyCharm

from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import *
from sqlalchemy.pool import NullPool
from config_manager.config_manager import *
from datetime import *

base = declarative_base()


class StockBasic(base):
    __tablename__ = 'stock_basics'
    symbol = Column(VARCHAR(6), primary_key=true, index=true)
    ts_code = Column(VARCHAR(10))
    name = Column(Text)
    area = Column(Text)
    industry = Column(Text)
    market = Column(Text)
    list_date = Column(Text)
    fullname = Column(Text)
    enname = Column(Text)
    exchange = Column(Text)
    curr_type = Column(Text)
    list_status = Column(Text)
    is_hs = Column(Text)
    update_time = Column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    def __init__(self, data):
        self.symbol = data.symbol
        self.ts_code = data.ts_code
        self.name = data['name']
        self.area = data.area
        self.industry = data.industry
        self.market = data.market
        self.list_date = data.list_date
        self.fullname = data.fullname
        self.enname = data.enname
        self.exchange = data.exchange
        self.curr_type = data.curr_type
        self.list_status = data.list_status
        self.is_hs = data.is_hs

    def is_new_stock(self):
        start_time = datetime.strptime(str(self.list_date), "%Y%m%d")
        today = datetime.now()
        if (today - start_time).days <= 365:
            return True
        else:
            return False


def get_sqlalchemy_path():
    database_info = get_database_info()
    create_database(database_info)
    if database_info is None or len(database_info.keys()) == 0:
        return None
    host = database_info["host"]
    user = database_info["user"]
    password = database_info["password"]
    database_name = database_info["database_name"]
    database_path = "mysql+mysqldb://" + user + \
                    ":" + password + \
                    "@" + host + \
                    ":" + "3306" + \
                    "/" + database_name\
                    + "?charset=utf8"
    return database_path


def get_database_engine():
    database_engine = create_engine(get_sqlalchemy_path(), poolclass=NullPool)
    return database_engine


def get_database_session():
    database_engine = get_database_engine()
    database_session = sessionmaker(bind=database_engine)()
    database_engine.dispose()
    return database_session


def execute_sql_sentence(
    sql_sentence=None,
    database_session=None,
):
    if sql_sentence is None or len(sql_sentence) == 0:
        return None
    result = None
    stock_database_session = None
    try:
        if database_session is not None:
            result = database_session.execute(sql_sentence).fetchall()
        else:
            stock_database_session = get_database_session()
            result = stock_database_session.execute(sql_sentence).fetchall()
    except Exception as e:
        print("execute_sql_sentence has problem, sentence is %s" % sql_sentence)
        print(e)
    finally:
        if stock_database_session is not None:
            stock_database_session.close()
        return result


def create_database(
    database_info=None
):
    if database_info is None or len(database_info.keys()) == 0:
        return
    host = database_info["host"]
    user = database_info["user"]
    password = database_info["password"]
    database_name = database_info["database_name"]
    database_path = "mysql+mysqldb://" + user + \
                    ":" + password + \
                    "@" + host + \
                    ":" + "3306"
    database_engine = create_engine(database_path)
    existing_databases = database_engine.execute("SHOW DATABASES;")
    existing_databases = [d[0] for d in existing_databases]
    if database_name not in existing_databases:
        print('create database')
        database_engine.execute("CREATE DATABASE {0} CHARSET=UTF8".format(database_name))
    database_path = "mysql+mysqldb://" + user + \
                    ":" + password + \
                    "@" + host + \
                    ":" + "3306" + \
                    "/" + database_name +\
                    "?charset=utf8"
    database_engine = create_engine(database_path)
    base.metadata.create_all(database_engine)
    database_session = sessionmaker(bind=database_engine)()
    database_session.commit()
    database_session.close()
    database_engine.dispose()


if __name__ == '__main__':
    create_database()
