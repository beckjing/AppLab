#!/usr/bin/env python 
# -*- coding: utf-8 -*- 
# @Time    : 04/03/2017 9:45 AM 
# @Author  : Yuecheng Jing 
# @Site    : www.nanosparrow.com 
# @File    : quantitativeStock.py
# @Software: PyCharm Community Edition

import sys
sys.path.append('../')
from pandas import *
from datetime import *
from stock.stock import *


observer_day = 1


def plot_all_stock_line():
    start_time = datetime.now()
    from matplotlib.pyplot import show
    do_some_thing_for_all_stock(function_process=plot_stock_line,
                                function_end=show)
    finish_time = datetime.now()
    print finish_time - start_time


def plot_stock_line(
    stock_database_session=None,
    stock_id=None,
    stock_count=None,
    process_index=None,
):
    from matplotlib.pyplot import plot
    if stock_id is None or len(stock_id) != 6 or stock_count is None or process_index is None:
        return None
    data = query_stock_data(stock_id=stock_id,
                            start_time='2017-01-01')
    color = 0xffffff
    if data is not None and not data.empty:
        color_value = hex(color / stock_count * process_index)
        color_string = '#' + '0' * (8 - len(color_value)) + color_value[2:]
        print stock_id
        try:
            data.index = np.array([datetime.strptime(data.date[i], "%Y-%m-%d") for i in range(len(data.date))])
            plot(data.index, data.close, color=color_string)
        except Exception, e:
            print Exception, ':', e
            print traceback.print_exc()
            print "plot stock %s fail" % stock_id
    else:
        print stock_id + " has no data"
        update_stock_data(stock_id=stock_id)
    return None


def do_some_thing_for_all_stock(
    stock_database_session=None,
    function_start=None,
    function_process=None,
    function_end=None,
    stock_list=None
):
    if stock_list is None or len(stock_list) == 0:
        stock_list = query_all_stock_id()
    if function_start is not None:
        function_start()
    stock_count = len(stock_list)
    process_index = 0
    results = []
    for stock_id in stock_list:
        if stock_id is None or len(stock_id) < 6:
            continue
        else:
            if function_process is not None:
                result = function_process(stock_database_session=stock_database_session,
                                          stock_id=stock_id,
                                          stock_count=stock_count,
                                          process_index=process_index)
            if result is not None and function_end is not None:
                result_dic = {
                    "stock_id": stock_id,
                    "stock_data": result
                }
                results.append(result_dic)
            process_index += 1
    if function_end is not None:
        if len(results) > 0:
            function_end(stock_results=results)
        else:
            function_end()


def analyse_single_new_stock(
    stock_database_session=None,
    stock_id=None,
    stock_count=None,
    process_index=None,
):
    if stock_id is None or len(stock_id) != 6:
        return None
    data = query_stock_data(stock_id=stock_id)
    if data is None or data.empty:
        # 后期把退市的股票滤掉
        print stock_id + "has no data"
        update_stock_data(stock_id=stock_id)
        return None
    # print "新股"
    # print stock_id
    stock_open_high = 0.0
    stock_open_low = 0.0
    stock_open_close = 0.0
    stock_open_date = ""
    stock_open_high_index = 0
    stock_open_low_index = 0
    stock_open_index = 0
    stock_observer_close = 0
    data_length = len(data)
    is_stock_open_limit = False
    for i in range(1, data_length):
        if is_stock_open_limit is False:
            if data.iloc[i].high != data.iloc[i].low:  # 涨停板打开了
                stock_open_date = data.iloc[i].date
                stock_open_close = float(data.iloc[i].close)
                stock_observer_close = stock_open_close
                stock_open_high = float(data.iloc[i].high)
                stock_open_low = float(data.iloc[i].low)
                stock_open_index = i
                stock_open_high_index = i
                stock_open_low_index = i
                is_stock_open_limit = True
                if data_length - i < 10:
                    print "最近刚打开涨停板，股票代码" + str(stock_id) + "，打开天数" + str(data_length - i) + "天"
                elif i == data_length - 1:
                    print "涨停板没有打开的股票，股票代码" + str(stock_id)
        else:  # 新股后期统计
            if i <= stock_open_index + observer_day:
                stock_observer_close = float(data.iloc[i].close)
            if stock_open_high < float(data.iloc[i].high):
                stock_open_high_index = i
                stock_open_high = float(data.iloc[i].high)
            if stock_open_low > float(data.iloc[i].low):
                stock_open_low_index = i
                stock_open_low = float(data.iloc[i].low)
    if is_stock_open_limit:
        up_rate = (stock_open_high - stock_open_close) / stock_open_close
        down_rate = (stock_open_low - stock_open_close) / stock_open_close
        observer_profit = (stock_observer_close - stock_open_close) / stock_open_close
        stock_data_frame = DataFrame({"id": [stock_id],
                                      "date": [datetime.strptime(stock_open_date, "%Y-%m-%d")],
                                      "close": [stock_open_close],
                                      "high": [stock_open_high],
                                      "low": [stock_open_low],
                                      "limit_days": [stock_open_index],
                                      "up": [up_rate],
                                      "down": [down_rate],
                                      "up_days": [stock_open_high_index - stock_open_index],
                                      "down_days": [stock_open_index - stock_open_low_index],
                                      "observer_profit": [observer_profit]
                                      })
        # print stock_data_frame
        print str(stock_id) + "涨停打开收于" + str(stock_open_date) + "收盘价" + str(stock_open_close)
        # print "最高价" + str(stock_open_high)
        # print "最高上涨" + str(up_rate * 100.0) + "%"
        # print "最低价" + str(stock_open_low)
        # print "最低下跌" + str(down_rate * 100.0) + "%"
        # print "\n"
        return stock_data_frame
    else:
        print stock_id + u"涨停板还未打开"
    return None


def analyse_all_new_stock(
    stock_results=None
):
    if stock_results is None or len(stock_results) == 0:
        return
    all_new_stock_list = None
    if len(stock_results) > 0:
        all_new_stock_list = stock_results[0]["stock_data"]
    for stock_result in stock_results:
        all_new_stock_list = all_new_stock_list.append(stock_result["stock_data"], ignore_index=True)
    all_new_stock_list = all_new_stock_list.drop(0)
    from matplotlib.pyplot import title, plot, grid, text, show

    print all_new_stock_list.sort_values(by='date')
    # print all_new_stock_list.up_days.mean()
    # print all_new_stock_list.down_days.mean()
    #

    # # 收益率点
    # title("The profit point of stock opened limit (total %s new stocks)" % str(len(all_new_stock_list)))
    # plot(all_new_stock_list.sort_values(by='date').date, all_new_stock_list.sort_values(by='date').up, 'r.')
    # plot(all_new_stock_list.sort_values(by='date').date, all_new_stock_list.sort_values(by='date').down, 'g.')
    # grid(True)
    # show()

    # # 上涨、下跌天数点
    # title("The up and down days point of stock opened limit (total %s new stocks)" % str(len(all_new_stock_list)))
    # plot(all_new_stock_list.sort_values(by='date').date, all_new_stock_list.sort_values(by='date').up_days, 'r.')
    # plot(all_new_stock_list.sort_values(by='date').date, all_new_stock_list.sort_values(by='date').down_days, 'g.')
    # grid(True)
    # show()

    # plot(all_new_stock_list.sort_values(by='date').date, all_new_stock_list.sort_values(by='date').observer_profit, 'b.')
    # grid(True)
    # show()

    # # 收益分布直方图
    # title("The profit histogram of stock after opened limit %s days (total %s new stocks)" %
    #       (str(observer_day), str(len(all_new_stock_list))))
    # text(all_new_stock_list.observer_profit.max() - 0.1, 200 / observer_day, 'mean = %.2f%%' % (all_new_stock_list.observer_profit.mean() * 100.0))
    # all_new_stock_list.observer_profit.hist(bins=50)
    # show()

    # 上涨、下跌天数直方图
    title("The histogram of the up and down days for stocks opened limit (total %s new stocks)" % str(len(all_new_stock_list)))
    frequency_of_days = 1
    all_new_stock_list.up_days.hist(bins=int(all_new_stock_list.up_days.max() / frequency_of_days), color='r')
    text(100, 50, 'mean of up days is %.2f' % (all_new_stock_list.up_days.mean()))
    all_new_stock_list.down_days.hist(bins=int(- all_new_stock_list.down_days.min() / frequency_of_days), color='g')
    text(-300, 50, 'mean of down days is %.2f' % (-all_new_stock_list.down_days.mean()))
    show()


def analyse_single_not_new_stock(
    stock_sqlalchemy_path=None,
    stock_database_connect=None,
    stock_id='000000',
    *args
):
    if stock_database_connect is None:
        return None
    data = query_stock_in_list(stock_database_connect, stock_id)
    if data is None or data.empty:
        return None
    else:
        data = data.sort_index(axis=0, ascending=False)
        return data


def analyse_all_not_new_stock(
    stock_results=None
):

    if stock_results is None or len(stock_results) == 0:
        return
    analyse_all_not_new_stock_reach_high_price_days(stock_results)


def analyse_all_not_new_stock_reach_high_price_days(
    stock_results=None
):
    date_today = datetime.strptime("2017-05-04 00:00:01", "%Y-%m-%d %H:%M:%S")
    # print date_today
    date_today_string = date_today.strftime("%Y-%m-%d %H:%M:%S")
    date_start_day = datetime.strptime("2017-01-17", "%Y-%m-%d")
    date_start_day_string = date_start_day.strftime("%Y-%m-%d")
    # print date_today_string
    # print date_start_day_string
    all_not_new_stock_high_days = None
    db_engine = create_engine(get_sqlite_sqlalchemy_path(), poolclass=NullPool)
    db_session = sessionmaker(db_engine)()
    stock_sum = 0
    for stock in stock_results:
        stock_data = stock["stock_data"]
        stock_id = stock["stock_id"]
        filtered_data = stock_data[(stock_data.date > date_start_day_string.decode('utf-8')) &
                                   (stock_data.date < date_today_string.decode('utf-8'))]
        if filtered_data.empty:
            continue
        if date_today_string.decode('utf-8')[0:10] == filtered_data.date.max()[0:10]:
            high_date = filtered_data[filtered_data.high == filtered_data.high.max()]
            high_date_time = datetime.strptime(high_date.iloc[0].date, '%Y-%m-%d %H:%M:%S')
            delta_day = date_today - high_date_time
            # if delta_day.days > 60 and 20.0 < all_stock_basics[all_stock_basics.index == stock_id].iloc[0].pe < 40.0:
            #     print stock_id
            #     print delta_day.days
            # print type(delta_day.days)
            # print all_not_new_stock_high_days
            if delta_day.days <= 3:
                stock_basic = db_session.query(StockBasic).filter(StockBasic.code == stock_id).first()
                if stock_basic.name.find("ST") == -1:
                    print stock_id
                    print stock_basic.name
                    stock_sum += 1
            if all_not_new_stock_high_days is None:
                all_not_new_stock_high_days = DataFrame({"id": [stock_id],
                                                         "days": [delta_day.days]
                                                         })
            else:
                all_not_new_stock_high_days = all_not_new_stock_high_days.append(
                    DataFrame({"id": [stock["stock_id"]],
                               "days": [delta_day.days]
                               }))
    print stock_sum
    db_session.close()
        # 不再创新高天数分布直方图
        # print all_not_new_stock_high_days.shape


def plot_all_stock_pe_hist(
    min_pe=0,
    max_pe=500
):

    from matplotlib.pyplot import show
    db_session = get_database_session()
    stock_basics = db_session.query(StockBasic).filter(StockBasic.pe <= max_pe, StockBasic.pe > min_pe).all()
    all_stock_pe = None
    for stock_basic in stock_basics:
        if all_stock_pe is None:
            all_stock_pe = DataFrame({"pe": [stock_basic.pe]})
        else:
            all_stock_pe = all_stock_pe.append(DataFrame({"pe": [stock_basic.pe]}))
    all_stock_pe.pe.hist(bins=int(all_stock_pe.pe.max() / 10), color='g')
    db_session.close()
    show()


def plot_all_not_new_stock_reach_high_price_days(
    stock_results=None
):
    from matplotlib.pyplot import title, plot, grid, text, show, figure
    for delta_day_index in range(-10, 0):
        date_today = datetime.today() + timedelta(days=delta_day_index)
        # print date_today
        # date_today = datetime.strptime("2017-04-15 00:00:01", "%Y-%m-%d %H:%M:%S")
        date_today_string = date_today.strftime("%Y-%m-%d %H:%M:%S")
        date_start_day = datetime.strptime("2017-01-17", "%Y-%m-%d")
        date_start_day_string = date_start_day.strftime("%Y-%m-%d")
        # print date_today_string
        # print date_start_day_string
        all_not_new_stock_high_days = None
        # all_stock_basics = ts.get_stock_basics()
        for stock in stock_results:
            stock_data = stock["stock_data"]
            stock_id = stock["stock_id"]
            filtered_data = stock_data[(stock_data.date > date_start_day_string.decode('utf-8')) &
                                       (stock_data.date < date_today_string.decode('utf-8'))]
            if filtered_data.empty:
                continue
            if date_today_string.decode('utf-8')[0:10] == filtered_data.date.max()[0:10]:
                high_data = filtered_data[filtered_data.high == filtered_data.high.max()]
                high_date_time = datetime.strptime(high_data.iloc[0].date, '%Y-%m-%d %H:%M:%S')
                delta_day = date_today - high_date_time
                if all_not_new_stock_high_days is None:
                    all_not_new_stock_high_days = DataFrame({"id": [stock_id],
                                                             "days": [delta_day.days]
                                                             })
                else:
                    all_not_new_stock_high_days = all_not_new_stock_high_days.append(
                        DataFrame({"id": [stock["stock_id"]],
                                   "days": [delta_day.days]
                                   }))
        if all_not_new_stock_high_days is None:
            continue
            # 不再创新高天数分布直方图
            # print all_not_new_stock_high_days.shape
        figure(- delta_day_index)
        title("The days histogram of the day since stock reach high price to %s " % date_today_string[0:10])
        all_not_new_stock_high_days.days.hist(bins=(all_not_new_stock_high_days.days.max() * 2 + 1), color='g')
    show()


def analyse_new_stock():
    start_time = datetime.now()
    do_some_thing_for_all_stock(function_process=analyse_single_new_stock,
                                function_end=analyse_all_new_stock,
                                stock_list=query_all_new_stock_id())
    finish_time = datetime.now()
    print finish_time - start_time


def analyse_not_new_stock(
    stock_sqlalchemy_path=None,
    stock_database_path=None
):
    start_time = datetime.now()
    stock_database_connect = sqlite3.connect(stock_database_path)
    do_some_thing_for_all_stock(stock_database_connect=stock_database_connect,
                                stock_sqlalchemy_path=stock_sqlalchemy_path,
                                function_start=None,
                                function_process=analyse_single_not_new_stock,
                                function_end=analyse_all_not_new_stock,
                                stock_list=generate_all_not_new_stock_id(stock_sqlalchemy_path))
    stock_database_connect.close()
    finish_time = datetime.now()
    print finish_time - start_time


if __name__ == '__main__':
    analyse_new_stock()
    # analyse_not_new_stock(get_sqlalchemy_path(), get_database_path())
    # plot_all_stock_line()
    # plot_all_stock_pe_hist()
