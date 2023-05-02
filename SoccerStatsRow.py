from itertools import islice
from collections import defaultdict

class SoccerStatsRow:

    data = defaultdict(dict)


    def __init__(self):
        self.data = {
                "home_team": "",
                "guest_team": "",
                "date_time": "",
                "goals_home": 0,
                "goals_guest": 0,
                "first_half_goals_guest": 0,
                "first_half_goals_home": 0,
                "second_half_goals_guest": 0,
                "second_half_goals_home": 0,
                "full_time_home_win_odds": 0.0,
                "full_time_draw_odds": 0.0,
                "full_time_guest_win_odds": 0.0,
                "fisrt_half_home_win_odds": 0.0,
                "first_half_draw_odds": 0.0,
                "first_half_guest_win_odds": 0.0,
                "second_half_home_win_odds": 0.0,
                "second_half_draw_odds": 0.0,
                "second_half_guest_win_odds": 0.0,
                "full_time_over_under_goals": 0,
                "full_time_over_odds": 0.0,
                "full_time_under_odds": 0.0,
                "full_time_payout": 0.0,
                "first_half_over_under_goals": 0,
                "first_half_over_odds": 0.0,
                "first_half_under_odds": 0.0,
                "first_half_payout": 0.0,
                "second_half_over_under_goals": 0,
                "second_half_over_odds": 0.0,
                "second_half_under_odds": 0.0,
                "second_half_payout": 0.0,
                "url": ""
                }


    def __str__(self):
        ret = ""
        for key, value in self.data.items():
            ret += f"{key} = '{value}'\n"
        return ret

    def set(self, key, value):
        self.data[key] = value

    def get(self, key):
        return self.data[key]

    def generate_sql_insert_into_values(self, table_name):
        return 'INSERT INTO "' + table_name + "' (" + ", ".join(self.data.keys()) + ") VALUES (" + "%s, " * (len(self.data.keys()) - 1) + "%s)"

    def generate_do_update_set(self):
        ret = ""

        for k in islice(self.data.keys(), 3, None):  
            ret += '"' + k + '" = EXCLUDED."' + k + '", '

        return ret[0:-2]

    def generate_sql_insert_values(self):
        vals = ()
        for k, v in self.data.items():
            if str(v).isnumeric():
                vals.append(v)
            else:
                vals.append( "'" + str(v) + "'" )
        return vals

