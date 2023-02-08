import psycopg2
import sqlparse



class PGBase:

    def __init__(self, db, db_host, db_user='postgres', db_pass='p0stgr35', db_port=5432):
        self.pg = psycopg2.connect(database=db, host=db_host, user=db_user, password=db_pass, port=str(db_port))
        if self.pg is None:
            print("DatabasE::CTOR [Failed to connect to databse]")

    def is_connected(self):
        return self.pg is not None

    def validate_non_sql_string(self, string):
        try:
            tp = sqlparse.parse(string)
            for t in tp:
                if t.get_type() != "UNKNOWN":
                    return False
        except:
            pass

        return True


    def validate_non_sql(self, strings):
        if isinstance(strings, str):
            return self.validate_non_sql_string(strings)
        else:
            for s in strings:
                if not self.validate_non_sql_string(s):
                    return False
        return True


class PGConnector(PGBase):

    def insert_or_update_team(self, name, english_name):
        if not self.validate_non_sql((name, english_name)):
            return None

        cursor = self.pg.cursor()

        if name is None:
            cursor.execute( "INSERT INTO \"Team\" (english_name) VALUES (%s) " + 
                            "ON CONFLICT (\"team_pk\") DO UPDATE SET english_name = EXCLUDED.english_name " + 
                            "RETURNING id; ", (english_name))

        elif english_name is None:
            cursor.execute( "INSERT INTO \"Team\" (name) VALUES (%s) " + 
                            "ON CONFLICT (\"team_pk\") DO UPDATE SET name = EXCLUDED.name " +
                            "RETURNING id; ", (name))

        else:
            cursor.execute( "INSERT INTO \"Team\" (name, english_name) VALUES (%s, %s) " +
                            "ON CONFLICT (\"team_pk\") DO UPDATE SET name = EXCLUDED.name, english_name = EXCLUDED.english_name " + 
                            "RETURNING id; ", (name, english_name))

        ret = cursor.fetchone()[0]

        self.pg.commit()
        cursor.close()
        return ret

    def insert_or_update_oddsportal_match(self, home_team, guest_team, date_time):
        if not self.validate_non_sql((home_team, guest_team, date_time)):
            return None

        cursor = self.pg.cursor()

        cursor.execute( "INSERT INTO \"Match\" (home_team, guest_team, date_time) VALUES (%s, %s, %s) " + 
                        "ON CONFLICT (home_team, guest_team, date_time) DO NOTHING RETURNING id;", (home_team, guest_team, date_time) )

        if cursor.fetchone() is not None:
            ret = cursor.fetchone()[0];
            self.pg.commit()
            cursor.close()
        else:
            cursor.execute( "SELECT \"id\" FROm \"Match\" where home_team=\"%s\" and guest_team = \"%\" and date_time = \"%s\"; ", (home_team, guest_team, date_time))

        return ret

    def insert_or_update_oddsportal_over_under(self, match_id, half, data_array):
        if not self.validate_non_sql((str(match_id), str(half))):
            return False

        cursor = self.pg.cursor()
        for row in data_array:
            (value, over, under, payout) = row
            if self.validate_non_sql((str(value), str(over), str(under), str(payout))):
                return False

            cursor.execute( 
                    "INSERT INtO \"OverUnder\" (match_id, half, value, over, under, payout) VALUES " +
                    "(" + str(match_id) + ", " + half + ", " + str(value) + ", " + over, ", " + under + ", " + str(payout) + ") " +
                    "On CONFLICT (\"over_under_pk\") DO SET over = EXCLUDED.over, under = EXCLUDED.under, payout = EXCLUDED.payout;"
                    )

        self.pg.commit()
        cursor.close()
        return True

