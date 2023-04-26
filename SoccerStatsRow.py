
class SoccerStatsRow:
    data = {
        "home_team": "",
        "guest_team": "",
        "date_time": "",
        "goals_home": "",
        "goals_guest": "",
        "first_half_goals_guest": "",
        "first_half_goals_home": "",
        "second_half_goals_guest": "",
        "second_half_goals_home": "",
        "full_time_home_win_odds": "",
        "full_time_draw_odds": "",
        "full_time_guest_win_odds": "",
        "fisrt_half_home_win_odds": "",
        "first_half_draw_odds": "",
        "first_half_guest_win_odds": "",
        "second_half_home_win_odds": "",
        "second_half_draw_odds": "",
        "second_half_guest_win_odds": "",
        "full_time_over_under_goals": "",
        "full_time_over_odds": "",
        "full_time_under_odds": "",
        "full_time_payout": "",
        "first_half_over_under_goals": "",
        "first_half_over_odds": "",
        "first_half_under_odds": "",
        "first_half_payout": "",
        "second_half_over_under_goals": "",
        "second_half_over_odds": "",
        "second_half_under_odds": "",
        "second_half_payout": ""
    }

    def __str__(self):
        ret = "";
        for key, value in self.data:
            ret += f"{key} = '{value}'\n"
        return ret;

    def to_sql_insert_into(self, table_name):
        return 'INSERT INTO "' + table_name + "' (" + ", ".join(self.data.keys()) + ") VALUES (" + "%s, " * (len(self.data.keys()) - 1) + "%s)"

    def to_sql_insert_values(self, table_name):
        vals = "(";
        for v in self.data.values():
            if isinstance(v, str):
                vals += "'" + v + "'"
            else:
                vals += v
            vales += ", "
        return vals[0:-2] + ")"

