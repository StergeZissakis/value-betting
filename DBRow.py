from itertools import islice
from collections import defaultdict

class DBRow:

    data = defaultdict(dict)
    table_name = str()

    def __str__(self):
        ret = ""
        for key, value in self.data.items():
            ret += f"{key} = '{value}'\n"
        return ret

    def set(self, key, value):
        self.data[key] = value

    def get(self, key):
        return self.data[key]

    def generate_sql_insert_into_values(self):
        return 'INSERT INTO ' + self.table_name + ' (' + ", ".join(self.data.keys()) + ' ) VALUES ( ' + '%s, ' * (len(self.data.keys()) - 1) + '%s)'

    def generate_do_update_set(self):
        ret = ""

        for k in islice(self.data.keys(), 3, None):  
            ret += ' ' + k + ' = EXCLUDED.' + k + ', '

        return ret[0:-2]

    def generate_sql_insert_values(self):
        vals = []
        for v in self.data.values():
            if isinstance(v, list) and len(v) == 0: 
                vals.append(None)
            else:
                vals.append( v )

        return vals


