from datetime import datetime
import sqlparse


def test_date_time():
    event_date_time = 'Tomorrow, 04 Feb 2023, 15:00'

    (str_dat, str_date, str_time) = [part.strip() for part in event_date_time.split(',')]
    print(str_date)
    print(str_time)

    date = datetime.strptime(str_date + " " + str_time, "%d %b %Y %H:%M")
    print(date)
    

def validate_non_sql_string(string):
    try:
        tp = sqlparse.parse(string)
        for t in tp:
            if t.get_type() != "UNKNOWN":
                return False
    except:
        pass

    return True


def validate_non_sql(strings):
    if isinstance(strings, str):
        return validate_non_sql_string(strings)
    else:
        for s in strings:
            if not validate_non_sql_string(s):
                return False
                
    return True

if __name__ == "__main__":
    print(validate_non_sql("select * from x;"))
    print(validate_non_sql("Giannina"))
    print(validate_non_sql(("select * from x;", "Giannina")))


