import json
import sys

import yaml
from cffconvert.cli import cli as cffconvert_main

if len(sys.argv) == 1 or sys.argv[1] == 'latest':
    branch = 'master'
    layout = 'latest'
    landing_page = 'index.markdown'
else:
    branch = f'{sys.argv[1]}'
    layout = 'version'
    landing_page = f'versions/{branch}.markdown'

try:
    cffconvert_main(['-u', f'https://github.com/pace-neutrons/horace-euphonic-interface/tree/{branch}',
                     '-f', 'schema.org',
                     '-of', 'tmp.json'])
except SystemExit:
    pass

with open(f'tmp.json', 'r') as f:
    data = json.load(f)

schema_data = {'schemadotorg': data}
landing_page_content = (
    f'---\n'
    f'layout: {layout}\n'
    f'{yaml.dump(schema_data)}'
    f'---\n')
if branch == 'master':
    landing_page_content += f'# Horace-Euphonic-Interface - Latest\n'
else:
    landing_page_content = landing_page_content.replace(
        f'SOFTWARE/HORACEEUPHONICINTERFACE',
        f'SOFTWARE/HORACEEUPHONICINTERFACE/{branch.strip("v")}')

with open(landing_page, 'w') as f:
    f.write(landing_page_content)
