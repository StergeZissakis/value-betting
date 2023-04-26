import psycopg2
import sqlparse
import SoccerStatsRow

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
                    print(t + " is passed for sql")
                    return False
        except sqlparse.exceptions.SQLParseError as e:
            print("sql.parse exception:" + str(e))
            pass

        return True


    def validate_non_sql(self, strings):
        if isinstance(strings, str):
            return self.validate_non_sql_string(strings)
        else:
            for s in strings:
                if not self.validate_non_sql_string(s):
                    print(s + " is passed for sql")
                    return False
        return True


class PGConnector(PGBase):

    def insert_or_update_team(self, name, english_name):
        if not self.validate_non_sql((name, english_name)):
            return None

        cursor = self.pg.cursor()

        if name is None:
            cursor.execute( 'INSERT INTO "Team" (english_name) VALUES (%s) ' + 
                            'ON CONFLICT ("team_pk") DO UPDATE SET english_name = EXCLUDED.english_name ' + 
                            'RETURNING id; ', (english_name)
                            )

        elif english_name is None:
            cursor.execute( 'INSERT INTO "Team" (name) VALUES (%s) ' + 
                            'ON CONFLICT ("team_pk") DO UPDATE SET name = EXCLUDED.name ' +
                            'RETURNING id; ', (name)
                            )

        else:
            cursor.execute( 'INSERT INTO "Team" (name, english_name) VALUES (%s, %s) ' +
                            'ON CONFLICT ("team_pk") DO UPDATE SET name = EXCLUDED.name, english_name = EXCLUDED.english_name ' + 
                            'RETURNING id; ', (name, english_name)
                            )

        ret = cursor.fetchone()[0]
        self.pg.commit()
        cursor.close()
        return ret

    def insert_or_update_match(self, table_name, home_team, guest_team, date_time):
        if not self.validate_non_sql((home_team, guest_team, date_time)):
            return None

        cursor = self.pg.cursor()

        cursor.execute( 'INSERT INTO "' + table_name + '" (home_team, guest_team, date_time) VALUES (%s, %s, %s) ' + 
                        'ON CONFLICT (home_team, guest_team, date_time) DO NOTHING RETURNING id;', (home_team, guest_team, date_time) 
                        )

        ret = cursor.fetchone();
        if ret is not None:
            ret = ret[0]
            self.pg.commit()
            cursor.close()
            return ret
        else:
            cursor = self.pg.cursor()
            cursor.execute( 'SELECT id FROM "' + table_name + '" where home_team=%s and guest_team=%s and date_time=%s;', (home_team, guest_team, date_time))
            ret = cursor.fetchone()
            if ret is not None:
                ret = ret[0]
            cursor.close()
            return ret

        return None

    def insert_or_update_over(self, table_name, match_id, half, goals, odds, bet_links = [], payout = "", sql_checked = True):
        if not sql_checked and not self.validate_non_sql((str(match_id), str(half), str(goals), str(odds), str(payout))):
            print("Found SQL on page")
            return
        cursor = self.pg.cursor()
        cursor.execute( 
                'INSERT INTO "' + table_name + '" (match_id, half, goals, type, odds,  bet_links, payout) VALUES (%s, %s, %s, %s, %s, %s, %s) ' +
                'ON CONFLICT ON CONSTRAINT "' + table_name + '_unique" DO UPDATE SET odds = EXCLUDED.odds, payout = EXCLUDED.payout;',
                (str(match_id), str(half), goals, 'Over', odds, bet_links, str(payout))
                )

        self.pg.commit()
        cursor.close()

    def insert_or_update_under(self, table_name, match_id, half, goals, odds, bet_links = [], payout = "", sql_checked = True):
        if not sql_checked and not self.validate_non_sql((str(match_id), str(half), str(goals), str(odds), str(payout))):
            print("Found SQL on page")
            return

        cursor = self.pg.cursor()
        cursor.execute( 
                'INSERT INTO "' + table_name + '" (match_id, half, goals, type, odds, bet_links, payout) VALUES (%s, %s, %s, %s, %s, %s, %s) ' +
                'ON CONFLICT ON CONSTRAINT "' + table_name + '_unique" DO UPDATE SET odds = EXCLUDED.odds, payout = EXCLUDED.payout;',
                (str(match_id), str(half), goals, 'Under', odds, bet_links, str(payout))
                )

        self.pg.commit()
        cursor.close()

    def insert_or_update_over_under(self, table_name, match_id, half, data_array):
        for row in data_array:
            (goals, over, under, payout, bet_links) = row

            if over and str(over) not in ("", " ", "-"):
                self.insert_or_update_over(table_name, match_id, half, goals, over, bet_links, payout)

            if under and str(under) not in ("", " ", "-"):
                self.insert_or_update_under(table_name, match_id, half, goals, under, bet_links, payout)

    def update_historical_results_over_under(self, table_name, event_date_time, home_team, guest_team, home_goals, guest_goals, half_1_score, half_2_score):
        update_sql  = " UPDATE public.\"" + table_name + "\" " + " SET \"Home_Team_Goals\" = %s, "
        update_sql += " \"Guest_Team_Goals\" = %s, \"Home_Team_Goals_1st_Half\" = %s, \"Home_Team_Goals_2nd_Half\" = %s, "
        update_sql += " \"Guest_Team_Goals_1st_Half\" = %s, \"Guest_Team_Goals_2nd_Half\" = %s "
        where_sql   = " WHERE \"Date_Time\" = timestamp %s "
        params = list()
        params.append(home_goals)
        params.append(guest_goals)
        params.append(half_1_score.split(':')[0])
        params.append(half_2_score.split(':')[0])
        params.append(half_1_score.split(':')[-1])
        params.append(half_2_score.split(':')[-1])
        params.append(event_date_time)


        if len(home_team.split(' ')) > 1:
            home_parts = home_team.split(' ')
            where_home_sql = " (\"Home_Team\" = ANY(%s) OR SPLIT_PART(\"Home_Team\", ' ', 1) = ANY(%s)) "
            params.append(home_parts)
            params.append(home_parts)
        else:
            where_home_sql = " (\"Home_Team\" = %s OR %s = ANY(string_to_array(\"Home_Team\", ' '))) "
            params.append(home_team)
            params.append(home_team)

        if len(guest_team.split(' ')) > 1:
            guest_parts = guest_team.split(' ')
            where_guest_sql = " (\"Guest_Team\" = ANY(%s) OR SPLIT_PART(\"Guest_Team\", ' ', 1) = ANY(%s)) "
            params.append(guest_parts)
            params.append(guest_parts)
        else:
            where_guest_sql = " (\"Guest_Team\" = %s OR %s = ANY(string_to_array(\"Guest_Team\", ' '))) "
            params.append(guest_team)
            params.append(guest_team)

        sql_update = update_sql + where_sql + " AND " + where_home_sql + " AND " + where_guest_sql + " ; "
        cursor = self.pg.cursor()
        cursor.execute(sql_update, params)
        self.pg.commit()
        cursor.close()

    def insert_or_update_1x2_odds(self, soccerStatsRow):
        table_name = "soccer_statistics"

        cursor = self.pg.cursor()
        cursor.execute( 
            'INSERT INTO "' + table_name + '" ' + soccerStatsRow.generate_sql_insert_into_values(table_name) +  
            'ON CONFLICT ON CONSTRAINT "' + table_name + soccerStatsRow.generate_do_update_set() + ";",
            soccerStatsRow.generate_sql_insert_values()
        )
        self.pg.commit()
        cursor.close()

