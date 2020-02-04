#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/3/26 00:32
# @Author  : Yuecheng Jing
# @Site    : www.nanosparrow.com
# @File    : stock_manager
# @Software: PyCharm

import tushare as ts
import traceback
import threading
from queue import *
from pandas import *
from database_manager.database_manager import *


def get_pro_api():
    return ts.pro_api(get_api_info()['token'])


def get_stock_basics():
    pro_api = get_pro_api()
    return pro_api.stock_basic(fields='ts_code,'
                                      'symbol,'
                                      'name,'
                                      'area,'
                                      'industry,'
                                      'fullname,'
                                      'enname,'
                                      'market,'
                                      'exchange,'
                                      'curr_type,'
                                      'list_status,'
                                      'list_date,'
                                      'is_hs')


def get_available_time_string(
    include_today=False
):
    local_time = datetime.now()
    if include_today:
        if local_time.weekday() - 4 > 0:  # 双休往前两天
            available_time = local_time + timedelta(days=(4 - local_time.weekday()))
            return available_time.strftime('%Y%m%d')
        else:  # 正常
            return local_time.strftime('%Y%m%d')
    else:
        if local_time.weekday() - 4 > 0:  # 双休往前两天
            available_time = local_time + timedelta(days=(4 - local_time.weekday()))
            return available_time.strftime('%Y%m%d')
        elif local_time.weekday() == 0: # 周一倒退一天
            available_time = local_time + timedelta(days=-3)
            return available_time.strftime('%Y%m%d')
        else:  # 正常倒退一天
            available_time = local_time + timedelta(days=-1)
            return available_time.strftime('%Y%m%d')


def query_all_stock_basic():
    database_session = get_database_session()
    result = []
    try:
        result = database_session.query(StockBasic).all()
    except Exception as e:
        print("query_all_stock has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        database_session.close()
        return result


def query_all_stock_id(
    filter_updatetime=False
):
    all_stocks = query_all_stock_basic()
    result = []
    try:
        for query_stock in all_stocks:
            if filter_updatetime:
                if query_stock.update_time < (datetime.now() - timedelta(days=1)):
                    result.append(query_stock.symbol)
            else:
                result.append(query_stock.symbol)
    except Exception as e:
        print("query_all_stock_id has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        return result


def query_all_stock_code_in_basics(
    filter_updatetime=False
):
    all_stocks = query_all_stock_basic()
    result = []
    try:
        for query_stock in all_stocks:
            if filter_updatetime:
                if query_stock.update_time < (datetime.now() - timedelta(days=1)):
                    result.append(query_stock.ts_code)
            else:
                result.append(query_stock.ts_code)
    except Exception as e:
        print("query_all_stock_id has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        return result


def query_all_stock_code_in_database():
    all_stock_table = query_all_stock_table()
    result = []
    try:
        for stock_table in all_stock_table:
            if stock_table[0:6].isdigit():
                result.append(stock_table)
    except Exception as e:
        print("query_all_stock_id has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        return result


def update_stock_basics():
    database_session = get_database_session()
    try:
        data = get_stock_basics()
        for i in range(0, len(data)):
            row = data.iloc[i]
            stock_basic_info = StockBasic(row)
            stock_basic_info.update_time = datetime.now()
            database_session.merge(stock_basic_info)
            if i % 100 == 0:
                print('%.2f%%' % (i / len(data) * 100))
                database_session.commit()
    except Exception as e:
        print("insert_stock_basics has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        database_session.commit()
        database_session.close()


def query_all_stock_table():
    sql_sentence = "select table_name from information_schema.tables " \
                   "where table_schema='stock' and table_type='base table';"
    result = []
    try:
        stock_tables = execute_sql_sentence(sql_sentence)
        for stock_table in stock_tables:
            result.append(stock_table[0])
    except Exception as e:
        print("query_all_stock_table has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        return result


def get_stock_data(
    stock_code=None,
    need_check=True,
    start_time='20170101',
    end_time=get_available_time_string(include_today=True),
    database_session=None
):
    result = None
    try:
        if need_check is True:
            date_time = execute_sql_sentence(sql_sentence="select max(trade_date) from `%s`" % stock_code,
                                             database_session=database_session)
            if date_time is not None and date_time[0] is not None and date_time[0][0] is not None and len(
                    date_time[0][0]) > 0:
                start_time = (datetime.strptime(date_time[0][0], "%Y%m%d") + timedelta(days=1)).strftime("%Y%m%d")
        if (datetime.strptime(start_time, "%Y%m%d") - datetime.strptime(end_time, "%Y%m%d")).days >= 0:
            print("start time is bigger")
        else:
            data = ts.pro_bar(api=get_pro_api(), ts_code=stock_code, start_date=start_time, end_date=end_time, adj='qfq')
            data = data.drop(labels='ts_code', axis=1)
            if data is not None and not data.empty:
                result = data.sort_values(by='trade_date', axis=0, ascending=True)
    except Exception as e:
        print("update_stock_data has problem, stock id is %s" + stock_code)
        print(e)
        print(traceback.print_exc())
    finally:
        return result


def update_stock_data(
    stock_code=None,
    need_check=True,
    start_time='20170101',
    end_time=get_available_time_string(include_today=True),
    stock_data=None,
    database_engine=None,
    database_session=None
):
    result = False
    stock_database_engine = None
    try:
        if need_check is True:
            date_time = execute_sql_sentence("select max(trade_date) from `%s`" % stock_code)
            if date_time is not None and date_time[0] is not None and date_time[0][0] is not None and len(date_time[0][0]) > 0:
                start_time = (datetime.strptime(date_time[0][0], "%Y%m%d") + timedelta(days=1)).strftime("%Y%m%d")
        if (datetime.strptime(start_time, "%Y%m%d") - datetime.strptime(end_time, "%Y%m%d")).days >= 0:
            print("start time is bigger")
            result = False
        else:
            if_exists = 'replace'
            if need_check:
                if_exists = 'append'
            if stock_data is None:
                stock_data = get_stock_data(stock_code=stock_code,
                                            need_check=need_check,
                                            start_time=start_time,
                                            end_time=end_time)
            if stock_data is not None:
                if database_engine is None:
                    stock_database_engine = get_database_engine()
                    stock_data.to_sql(name=stock_code,
                                      con=stock_database_engine,
                                      if_exists=if_exists,
                                      index=False)
                else:
                    stock_data.to_sql(name=stock_code,
                                      con=database_engine,
                                      if_exists=if_exists,
                                      index=False)
                update_stock_update_time(stock_code=stock_code,
                                         database_session=database_session)
                result = True
    except Exception as e:
        print("update_stock_data has problem, stock id is %s" + stock_code)
        print(e)
        print(traceback.print_exc())
    finally:
        if stock_database_engine is not None:
            stock_database_engine.dispose()
        return result


def query_stock_data(
    stock_code=None,
    start_time='20140101',
    end_time=datetime.now().strftime('%Y%m%d'),
):
    if stock_code is None or len(stock_code) != 9:
        return None
    stock_code_in_basics = query_all_stock_code_in_basics()
    if not stock_code in stock_code_in_basics:
        return None
    else:
        try:
            stock_data_result = None
            sql_sentence = "select * from stock.`%s` where trade_date > '%s' and trade_date < '%s'" % (stock_code, start_time, end_time)
            stock_data = execute_sql_sentence(sql_sentence)
            stock_data_result = DataFrame(stock_data,
                                          columns=["trade_date",
                                                   "open",
                                                   "high",
                                                   "low",
                                                   "close",
                                                   "pre_close",
                                                   "change",
                                                   "pct_chg",
                                                   "vol",
                                                   "amount"])
        except Exception as e:
            print("query_stock_data has problem, stock id is %s" % stock_code)
            print(e)
            print(traceback.print_exc())
        finally:
            return stock_data_result


def update_stock_update_time(
    stock_code=None,
    database_session=None
):
    stock_database_session = None
    stock = None
    if stock_code is None or len(stock_code) != 9:
        return
    try:
        if database_session is None:
            stock_database_session = get_database_session()
            stock = stock_database_session.query(StockBasic).filter(StockBasic.ts_code == stock_code).first()
            if stock is not None:
                stock.update_time = datetime.now()
                stock_database_session.commit()
        else:
            stock = database_session.query(StockBasic).filter(StockBasic.ts_code == stock_code).first()
            if stock is not None:
                stock.update_time = datetime.now()
                database_session.commit()
    except Exception as e:
        print("update_stock_update_time has problem, stock id is %s" % stock_code)
        print(e)
        print(traceback.print_exc())
    finally:
        if stock_database_session is not None:
            stock_database_session.close()


def get_last_update_stock_code():
    stock_code = None
    try:
        stock = execute_sql_sentence("select ts_code from stock_basics where update_time in"
                                     "(select min(stock_basics.update_time) from stock_basics) order by symbol")
        if stock is not None and len(stock) > 0:
            stock_code = stock[0][0]
    except Exception as e:
        print("query_stock_id_statement_last_update has problem")
        print(e)
        print(traceback.print_exc())
    finally:
        return stock_code


def query_all_stock_code_not_in_stock_basics():
    result = []
    try:
        stock_code_in_database = query_all_stock_table()
        stock_code_in_basics = query_all_stock_code_in_basics()
        for stock_code in stock_code_in_basics:
            if stock_code not in stock_code_in_database:
                result.append(stock_code)
    except Exception as e:
        print("query_stock_id_not_in_stock_list has problem")
        print(Exception, ":", e)
        print(traceback.print_exc())
    finally:
        return result


def multi_update_stock_data(
    thread_number=1
):
    start_time = datetime.now()
    if thread_number < 0:
        return
    threads = []
    database_engines = []
    database_sessions = []
    stock_codes = query_all_stock_code_not_in_stock_basics()
    if stock_codes is None or len(stock_codes) == 0:
        stock_codes = query_all_stock_code_in_basics(filter_updatetime=True)
    stock_code_length = len(stock_codes)
    if stock_code_length > 0:
        stock_code_queue = Queue(0)
        stock_data_queue = Queue(0)
        print("get stock code")
        for stock_code in stock_codes:
            stock_code_queue.put(stock_code)
        print("finish insert stock code %d" % len(stock_codes))
        for i in range(0, thread_number):
            thread = None
            database_engine = get_database_engine()
            database_session = get_database_session()
            thread = UpdateThread(thread_id=str(i),
                                  stock_code_queue=stock_code_queue,
                                  stock_data_queue=stock_data_queue,
                                  database_engine=database_engine,
                                  database_session=database_session)
            thread.start()
            threads.append(thread)
            database_engines.append(database_engine)
            database_sessions.append(database_session)
        for thread in threads:
            thread.join()
    for database_engine in database_engines:
        database_engine.dispose()
    for database_session in database_sessions:
        database_session.close()
    finish_time = datetime.now()
    print(finish_time - start_time)


class UpdateThread(threading.Thread):
    def __init__(self,
                 thread_id,
                 stock_code_queue,
                 stock_data_queue,
                 database_engine,
                 database_session,
                 download_data_first=False):
        threading.Thread.__init__(self)
        self.thread_id = thread_id
        self.stock_code_queue = stock_code_queue
        self.stock_data_queue = stock_data_queue
        self.database_engine = database_engine
        self.database_session = database_session
        self.download_data_first = download_data_first

    def run(self):
        print("Starting " + self.thread_id)
        while not self.stock_code_queue.empty() or not self.stock_data_queue.empty():
            if self.download_data_first:
                if not self.stock_code_queue.empty():
                    stock_code = self.stock_code_queue.get()
                    print("get stock data: %s, in thread: %s" % (stock_code, self.thread_id))
                    stock_data = get_stock_data(stock_code=stock_code,
                                                need_check=True,
                                                database_session=self.database_session)
                    if stock_data is not None and not stock_data.empty and stock_code is not None:
                        stock_map = {"data": stock_data, "code": stock_code}
                        self.stock_data_queue.put(stock_map)
                else:
                    if not self.stock_data_queue.empty():
                        print("insert stock data: %s, in thread: %s" % (stock_code, self.thread_id))
                        stock_map = self.stock_data_queue.get()
                        stock_data = stock_map["data"]
                        stock_code = stock_map["code"]
                        if stock_data is not None and not stock_data.empty and stock_code is not None:
                            update_stock_data(stock_code=stock_code,
                                              need_check=True,
                                              stock_data=stock_data,
                                              database_engine=self.database_engine,
                                              database_session=self.database_session)
            else:
                if not self.stock_data_queue.empty():
                    print("insert stock data: %s, in thread: %s" % (stock_code, self.thread_id))
                    stock_map = self.stock_data_queue.get()
                    stock_data = stock_map["data"]
                    stock_code = stock_map["code"]
                    if stock_data is not None and not stock_data.empty and stock_code is not None:
                        update_stock_data(stock_code=stock_code, need_check=True, stock_data=stock_data)
                else:
                    if not self.stock_code_queue.empty():
                        stock_code = self.stock_code_queue.get()
                        print("get stock data: %s, in thread: %s" % (stock_code, self.thread_id))
                        stock_data = get_stock_data(stock_code=stock_code,
                                                    need_check=True)
                        if stock_data is not None and not stock_data.empty and stock_code is not None:
                            stock_map = {"data": stock_data, "code": stock_code}
                            self.stock_data_queue.put(stock_map)
        print("Ending " + self.thread_id)


if __name__ == '__main__':
    update_stock_basics()
    # print(query_all_stock_code())
    # print(update_stock_data(stock_code='600000.SH'))
    # print(query_stock_data(stock_code='000001.SZ'))
    # update_stock_update_time(stock_code='000001.SZ')
    # print(get_last_update_stock_code())
    # print(get_stock_data(stock_code='600000.SH'))
    # multi_update_stock_data(4)
