from datetime import datetime, date, time, timedelta
from dateutil.relativedelta import relativedelta
import sqlparse


def calculate_event_date(event_date):
    today = datetime.today()
    tmp_date = datetime.strptime(event_date, "%A %d/%m")
    tmp_date = tmp_date.replace(year=today.year)
    if tmp_date < today - relativedelta(months=1): # in case of new year ahead
        tmp_date = tmp_date.replace(year=today.year + 1)
    return tmp_date



if __name__ == "__main__":
    event_date = 'Saturday 18/02'

    print(calculate_event_date(event_date))




