#!/usr/bin/env python3
import sys
import json
import requests
from random import randint

# https://app.datadoghq.com/account/settings#api
api_key = ''
app_key = ''
if not api_key or not app_key:
    sys.exit('Please provide a Datadog API and APP key')

lookback = {
    'hour': 'now - 1h',
    'half_day': 'now - 12h',
    'day': 'now - 1d',
    'two_days': 'now - 2d',
    'four_days': 'now - 4d',
    'eight_days': 'now - 8d',
    'sixteen_days': 'now - 16d'
}


def search(**kwargs):
    return requests.post(
        f"https://api.datadoghq.com/api/v1/logs-queries/list?api_key={api_key}&application_key={app_key}",
        headers={
            'content-type': 'application/json'
        },
        json={
            'query': kwargs['query'],
            'time': {
                'from': kwargs['time_from'],
                'to': 'now'
            },
            'sort': 'desc',
            'limit': 1000
        }
    )


def get_searchable_ips(timeframe):
    r = search(
        time_from=timeframe,
        query='task_name: http'
    )
    return [l['content']['attributes']['ip'] for l in r.json()['logs']]


def random_searchable_ip(ip_addrs):
    octets = ip_addrs[randint(0, len(ip_addrs) - 1)].split('.')
    return '.'.join(octets[0:3]) + '.*'


for timeframe in lookback.values():
    print(f"Using Timeframe: {timeframe}")
    searchable_ip_addrs = get_searchable_ips(timeframe)
    for i in range(0, 3):
        query = random_searchable_ip(searchable_ip_addrs)
        print(f"  Searching for: {query}", end='\t')
        r = search(
            time_from=timeframe,
            query=query
        )
        if r.status_code == 200:
            result_count = len(r.json()['logs'])
            print(f"\t{result_count} results\t {r.elapsed.total_seconds()} seconds")
        else:
            print(f"\tapi returned status code: {r.status_code}")
    print('\n')
