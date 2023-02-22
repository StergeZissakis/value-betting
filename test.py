from datetime import datetime, date, time, timedelta
from dateutil.relativedelta import relativedelta
import sqlparse
from  PGConnector import PGConnector


def calculate_event_date(event_date):
    today = datetime.today()
    tmp_date = datetime.strptime(event_date, "%A %d/%m")
    tmp_date = tmp_date.replace(year=today.year)
    if tmp_date < today - relativedelta(months=1): # in case of new year ahead
        tmp_date = tmp_date.replace(year=today.year + 1)
    return tmp_date


if __name__ == "__main__":
    #event_date = 'Saturday 18/02'
    #print(calculate_event_date(event_date))

    db = PGConnector("postgres", "localhost")
    if not db.is_connected():
        print("Fialed to connect to DB")
        exit(-1)

    home = 'OFI Crete'
    guest = 'Aris'
    db.update_historical_results_over_under("OverUnderHistorical", "2023-02-20 19:30:00", home, guest, 0, 3)






