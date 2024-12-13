import random as rd
import json
import time
import requests
import schedule
import os
import shutil
import sys
import logging
import logging.handlers
from typing import Dict, Any, Optional, List, Tuple

EXEC_PATH = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(EXEC_PATH, 'logs')
os.makedirs(LOG_PATH, exist_ok=True)

def new_logger(log_name: Optional[str] = None) -> logging.Logger:
    log_name = log_name or 'info.log'
    logger = logging.getLogger(os.path.splitext(log_name)[0])
    LOG_FILENAME = os.path.join(LOG_PATH, log_name)
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(process)d-%(threadName)s - '
                                  '%(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    file_handler = logging.handlers.RotatingFileHandler(
        LOG_FILENAME, maxBytes=5242880, backupCount=5, encoding="utf-8")
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger

def get_timestamp(timeStamp: int) -> Tuple[int, int]:
    timeArray = time.localtime(timeStamp)
    otherStyleTime = time.strftime("%Y-%m-%d", timeArray)
    timeArray = time.strptime(otherStyleTime, "%Y-%m-%d")
    timeStamp = int(time.mktime(timeArray))
    return timeStamp, timeStamp + 86400

logger = new_logger()

_TML_CONFIG_JSON_PATH = os.path.join(os.getcwd(), 'config.sample.json')

class RandomMonitorData:
    def __init__(self, config: Dict[str, Any]):
        self.config = config

    def is_night(self) -> bool:
        night_interval = self.config.get('nightInterval', {"start": 63000, "end": 118800})
        now_ts = int(time.time())
        day_ts = get_timestamp(now_ts)
        return (day_ts[0] + night_interval['start']) < now_ts < (day_ts[0] + night_interval['end'])

    def random_brt_device_data(self, device: Dict[str, Any], time_seed: int = 10) -> Dict[str, Any]:
        log = {
            "ble_addr": device['mac'],
            "addr_type": 1,
            "scan_rssi": rd.randrange(50, 90),
            "scan_time": int(time.time()) - rd.randrange(0, time_seed),
            "humi": format(int(device['humi'] + rd.randrange(-5, 5)), "x"),
            "pwr_percent": format(device['pwr'], "x"),
            "temp": format(int(device['temp'] + rd.randrange(-5, 5)), "x")
        }

        if device['type'].upper() == 'VOC':
            lux = device.get('luxNight', 0) if self.is_night() else device['lux']
            log.update({
                "lux": format(int(lux + rd.randrange(-5, 5)), "x"),
                "tvoc": format(int(device['tvoc'] + rd.randrange(-5, 5)), "x"),
                "eco2": format(int(device['eco2'] + rd.randrange(-5, 5)), "x")
            })
        return log

    def random_brt_gateway_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        _device_list = [self.random_brt_device_data(device, gateway['timeSeed']) for device in gateway['deviceList']]
        deviceTime = collectTime or time.time()
        return json.dumps({
            "devices": _device_list,
            "seq_no": rd.randrange(10),
            "cbid": gateway['id'],
            "time": int(deviceTime),
            "cmd": rd.randrange(1000),
        }, sort_keys=True, indent=4)

    def random_cthm_gateway_device_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        device = gateway['device']
        deviceTime = collectTime or time.time()
        log = {
            "macId": device['mac'],
            "localIp": device['ip'],
            "time": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "humi": format(int(device['humi'] + rd.randrange(-50, 50, 10)), "x"),
            "temp": format(int(device['temp'] + rd.randrange(-50, 50, 10)), "x"),
            "runningStatus": device['runningStatus']
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_toprie_gateway_device_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "FORMALDEHYDE": format(int(device['formaldehyde'] + rd.randrange(-50, 50, 10)), "x"),
                "HUMIDITY": format(int(device['humidity'] + rd.randrange(-50, 50, 10)), "x"),
                "TEMPERATURE": format(int(device['temperature'] + rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_cthc_fh_gateway_device_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "HUMIDITY": format(int(device['humidity'] + rd.randrange(-50, 50, 10)), "x"),
                "TEMPERATURE": format(int(device['temperature'] + rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_milesight_gateway_device_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "ECO2": format(int(device['eco2'] + rd.randrange(-50, 50, 10)), "x"),
                "TVOC": format(int(device['tvoc'] + rd.randrange(-50, 50, 10)), "x"),
                "LUX": format(int(device['lux'] + rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_one_gateway_json_data(self, gateway: Dict[str, Any], collectTime: Optional[float] = None) -> str:
        gateway_type = gateway['type']
        if gateway_type == 'brt':
            return self.random_brt_gateway_data(gateway, collectTime)
        elif gateway_type == 'cthm':
            return self.random_cthm_gateway_device_data(gateway, collectTime)
        elif gateway_type == 'toprie':
            return self.random_toprie_gateway_device_data(gateway, collectTime)
        elif gateway_type == 'cthc-fh':
            return self.random_cthc_fh_gateway_device_data(gateway, collectTime)
        elif gateway_type == 'milesight':
            return self.random_milesight_gateway_device_data(gateway, collectTime)
        else:
            raise ValueError(f"Unknown gateway type: {gateway_type}")

    def post_data_to_host(self, data: str, post_url: str) -> None:
        logger.info('%s Post Data: %s To %s .', self.config['name'], data, post_url)
        try:
            requests.post(post_url, data=data, headers={"Content-Type": "application/json"})
        except requests.ConnectionError:
            logger.error('%s post connect error.', self.config['name'])
        except Exception as e:
            logger.error("%s post throw error: %s.", self.config['name'], str(e))
        else:
            logger.info('%s post success.', self.config['name'])
        finally:
            logger.info('%s post finished.', self.config['name'])

    def post_one_data_tohost(self, collectTime: Optional[float] = None) -> None:
        for gateway in self.config['list']:
            self.post_data_to_host(self.random_one_gateway_json_data(gateway, collectTime), self.config['postUrl'][gateway['type']])

    def post_one_data_tohost_by_index(self, gateway_index: int = 0) -> None:
        gateway = self.config['list'][gateway_index]
        self.post_data_to_host(self.random_one_gateway_json_data(gateway), self.config['postUrl'][gateway['type']])

    def insert_device_log_between_start_to_end(self) -> None:
        execStartTime = self.config['execTimeRange']['start']
        execEndTime = self.config['execTimeRange']['end']
        execIntervalTime = self.config['execTimeRange']['interval']

        while execStartTime <= execEndTime:
            self.post_one_data_tohost(execStartTime)
            execStartTime += execIntervalTime

    def schedules(self) -> None:
        if not self.config['enable']:
            logger.info('%s setting disabled, passed.', self.config['name'])
            return

        for idx, gateway in enumerate(self.config['list']):
            interval = gateway.get('interval', 15)
            intervalTo = gateway.get('intervalTo', interval + 15)
            schedule.every(interval).to(intervalTo).seconds.do(self.post_one_data_tohost_by_index, idx)
            logger.info('gateway: %s already schedule.', gateway['id'])
        logger.info('%s has %s gateway started.\n\n', self.config['name'], len(self.config['list']))

def run_pending() -> None:
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == '__main__':
    arg_path = sys.argv[1] if len(sys.argv) > 1 else ''
    config_json_path = arg_path or os.path.join(os.getcwd(), 'config.json')

    if not os.path.exists(config_json_path):
        shutil.copy(_TML_CONFIG_JSON_PATH, config_json_path)

    with open(config_json_path, mode='r', encoding='utf-8') as f:
        json_config_list = json.load(f)

    for _json_config in json_config_list:
        _rmds = RandomMonitorData(_json_config)
        if _json_config['execTimeRange']['enable']:
            _rmds.insert_device_log_between_start_to_end()
        else:
            _rmds.schedules()

    run_pending()
