from itertools import islice
from collections import defaultdict
from DBRow import DBRow

class SoccerStatsRow(DBRow):

    def __init__(self):
        self.table_name = "soccer_statistics"
        self.data = {
                "home_team": None,
                "guest_team": None,
                "date_time": None,
                "goals_home": None,
                "goals_guest": None,
                "first_half_goals_guest": None,
                "first_half_goals_home": None,
                "second_half_goals_guest": None,
                "second_half_goals_home": None,
                "full_time_home_win_odds": None,
                "full_time_draw_odds": None,
                "full_time_guest_win_odds": None,
                "first_half_home_win_odds": None,
                "first_half_draw_odds": None,
                "first_half_guest_win_odds": None,
                "second_half_home_win_odds": None,
                "second_half_draw_odds": None,
                "second_half_guest_win_odds": None,
                "full_time_over_under_goals": None,
                "full_time_over_odds": None,
                "full_time_under_odds": None,
                "first_half_over_under_goals": None,
                "first_half_over_odds": None,
                "first_half_under_odds": None,
                "second_half_over_under_goals": None,
                "second_half_over_odds": None,
                "second_half_under_odds": None,
                "url": None
                }

