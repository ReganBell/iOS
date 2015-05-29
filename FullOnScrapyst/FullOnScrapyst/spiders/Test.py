__author__ = 'regan'
import json

def merge(a, b, path=None):
    "merges b into a"
    if path is None: path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                merge(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass # same leaf value
            else:
                raise Exception('Conflict at %s' % '.'.join(path + [str(key)]))
        else:
            a[key] = b[key]
    return a

a = {'faculty':
        {'Malan':
            {'Overall':
                {'breakdown': [1, 2, 3, 4, 5],
                     'median': 4.0,
                     'mean': 4.0
                }
            },
            'Workload':
                {'breakdown': [1, 2, 3, 4, 5],
                     'median': 4.0,
                     'mean': 4.0}
                }
        }
b = {'answers':
        {'Malan':
            {'Difficulty':
                {'breakdown': [1, 2, 3, 4, 5],
                     'median': 4.0,
                     'mean': 4.0
                }
            },
            'Section':
                {'breakdown': [1, 2, 3, 4, 5],
                     'median': 4.0,
                     'mean': 4.0}
                }
        }
with open('real_results.json', 'w') as f:
            print f
            json.dump(a, f)