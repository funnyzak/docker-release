# coding: utf-8

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
from datetime import datetime
from typing import Dict, Any, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor
import threading

EXEC_PATH = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(EXEC_PATH, 'logs')
os.makedirs(LOG_PATH, exist_ok=True)

def new_logger(log_name: Optional[str] = None) -> logging.Logger:
    """Create a new logger with file and console handlers."""
    log_name = log_name or 'info.log'
    logger = logging.getLogger(os.path.splitext(log_name)[0])
    LOG_FILENAME = os.path.join(LOG_PATH, log_name)
    logger.setLevel(logging.INFO)

    # Avoid duplicate handlers
    if logger.handlers:
        return logger

    formatter = logging.Formatter(
        '%(asctime)s - %(process)d-%(threadName)s - '
        '%(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s'
    )

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    file_handler = logging.handlers.RotatingFileHandler(
        LOG_FILENAME, maxBytes=5242880, backupCount=5, encoding="utf-8"
    )
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger

def get_timestamp(timeStamp: int) -> Tuple[int, int]:
    """Get start and end timestamps for a given day."""
    timeArray = time.localtime(timeStamp)
    otherStyleTime = time.strftime("%Y-%m-%d", timeArray)
    timeArray = time.strptime(otherStyleTime, "%Y-%m-%d")
    timeStamp = int(time.mktime(timeArray))
    return timeStamp, timeStamp + 86400

def parse_datetime_string(datetime_str: str) -> float:
    """Parse datetime string to timestamp."""
    try:
        dt = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")
        return dt.timestamp()
    except ValueError as e:
        raise ValueError(f"Invalid datetime format: {datetime_str}. "
                         f"Expected format: YYYY-MM-DD HH:MM:SS") from e

def validate_config(config: Dict[str, Any]) -> None:
    """Validate configuration structure."""
    required_fields = ['name', 'enable', 'postUrl', 'list']
    for field in required_fields:
        if field not in config:
            raise ValueError(f"Missing required field: {field}")

    if not isinstance(config['list'], list):
        raise ValueError("'list' must be an array")

    for gateway in config['list']:
        if 'type' not in gateway:
            raise ValueError("Gateway missing 'type' field")
        if gateway['type'] not in config['postUrl']:
            raise ValueError(f"No postUrl configured for gateway type: "
                             f"{gateway['type']}")

logger = new_logger()

_TML_CONFIG_JSON_PATH = os.path.join(os.getcwd(), 'config.sample.json')

class RandomMonitorData:
    """Generate and send random monitoring data to configured endpoints."""

    def __init__(self, config: Dict[str, Any]):
        validate_config(config)
        self.config = config
        self._stop_event = threading.Event()
        self._executor = ThreadPoolExecutor(max_workers=5)

    def is_night(self) -> bool:
        """Check if current time is within night interval."""
        night_interval = self.config.get(
            'nightInterval', {"start": 63000, "end": 118800}
        )
        now_ts = int(time.time())
        day_ts = get_timestamp(now_ts)
        return ((day_ts[0] + night_interval['start']) < now_ts <
                (day_ts[0] + night_interval['end']))

    def random_brt_device_data(self, device: Dict[str, Any],
                              time_seed: int = 10) -> Dict[str, Any]:
        """Generate random BRT device data."""
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
            lux = (device.get('luxNight', 0) if self.is_night()
                   else device['lux'])
            log.update({
                "lux": format(int(lux + rd.randrange(-5, 5)), "x"),
                "tvoc": format(int(device['tvoc'] + rd.randrange(-5, 5)), "x"),
                "eco2": format(int(device['eco2'] + rd.randrange(-5, 5)), "x")
            })
        return log

    def random_brt_gateway_data(self, gateway: Dict[str, Any],
                               collectTime: Optional[float] = None) -> str:
        """Generate random BRT gateway data."""
        _device_list = [
            self.random_brt_device_data(device, gateway['timeSeed'])
            for device in gateway['deviceList']
        ]
        deviceTime = collectTime or time.time()
        return json.dumps({
            "devices": _device_list,
            "seq_no": rd.randrange(10),
            "cbid": gateway['id'],
            "time": int(deviceTime),
            "cmd": rd.randrange(1000),
        }, sort_keys=True, indent=4)

    def random_cthm_gateway_device_data(self, gateway: Dict[str, Any],
                                       collectTime: Optional[float] = None) -> str:
        """Generate random CTHM gateway device data."""
        device = gateway['device']
        deviceTime = collectTime or time.time()
        log = {
            "macId": device['mac'],
            "time": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "humi": format(int(device['humi'] +
                              rd.randrange(-50, 50, 10)), "x"),
            "temp": format(int(device['temp'] +
                              rd.randrange(-50, 50, 10)), "x")
        }
        if 'runningStatus' in device:
            log['runningStatus'] = device['runningStatus']
        if 'ip' in device:
            log['localIp'] = device['ip']
        return json.dumps(log, sort_keys=True, indent=4)

    def random_toprie_gateway_device_data(self, gateway: Dict[str, Any],
                                         collectTime: Optional[float] = None) -> str:
        """Generate random Toprie gateway device data."""
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "FORMALDEHYDE": format(int(device['formaldehyde'] +
                                         rd.randrange(-50, 50, 10)), "x"),
                "HUMIDITY": format(int(device['humidity'] +
                                     rd.randrange(-50, 50, 10)), "x"),
                "TEMPERATURE": format(int(device['temperature'] +
                                        rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0,
                                                         gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_cthc_fh_gateway_device_data(self, gateway: Dict[str, Any],
                                          collectTime: Optional[float] = None) -> str:
        """Generate random CTHC-FH gateway device data."""
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "HUMIDITY": format(int(device['humidity'] +
                                     rd.randrange(-50, 50, 10)), "x"),
                "TEMPERATURE": format(int(device['temperature'] +
                                        rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0,
                                                         gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_milesight_gateway_device_data(self, gateway: Dict[str, Any],
                                           collectTime: Optional[float] = None) -> str:
        """Generate random Milesight gateway device data."""
        device = gateway['device']
        deviceTime = collectTime or time.time()
        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway['timeSeed']),
            "macId": device['mac'],
            "monitorData": {
                "ECO2": format(int(device['eco2'] +
                                 rd.randrange(-50, 50, 10)), "x"),
                "TVOC": format(int(device['tvoc'] +
                                 rd.randrange(-50, 50, 10)), "x"),
                "LUX": format(int(device['lux'] +
                                rd.randrange(-50, 50, 10)), "x")
            },
            "originData": ""
        }
        log = {
            "collectTime": int(deviceTime) - rd.randrange(0,
                                                         gateway['timeSeed']),
            "monitorDto": [logdata]
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_one_gateway_json_data(self, gateway: Dict[str, Any],
                                   collectTime: Optional[float] = None) -> str:
        """Generate random data for one gateway based on its type."""
        gateway_type = gateway['type']
        if gateway_type == 'brt':
            return self.random_brt_gateway_data(gateway, collectTime)
        elif gateway_type == 'cthm':
            return self.random_cthm_gateway_device_data(gateway, collectTime)
        elif gateway_type == 'toprie':
            return self.random_toprie_gateway_device_data(gateway, collectTime)
        elif gateway_type == 'cthc-fh':
            return self.random_cthc_fh_gateway_device_data(gateway,
                                                          collectTime)
        elif gateway_type == 'milesight':
            return self.random_milesight_gateway_device_data(gateway,
                                                           collectTime)
        else:
            raise ValueError(f"Unknown gateway type: {gateway_type}")

    def post_data_to_host(self, data: str, post_url: str) -> None:
        """Post data to the specified host URL."""
        logger.info('%s Post Data: %s To %s .',
                   self.config['name'], data, post_url)
        try:
            response = requests.post(
                post_url,
                data=data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            response.raise_for_status()
        except requests.ConnectionError:
            logger.error('%s post connect error.', self.config['name'])
        except requests.Timeout:
            logger.error('%s post timeout error.', self.config['name'])
        except requests.HTTPError as e:
            logger.error("%s post HTTP error: %s.", self.config['name'], str(e))
        except Exception as e:
            logger.error("%s post throw error: %s.",
                        self.config['name'], str(e))
        else:
            logger.info('%s post success.', self.config['name'])
        finally:
            logger.info('%s post finished.', self.config['name'])

    def post_one_data_tohost(self,
                           collectTime: Optional[float] = None) -> None:
        """Post data for all gateways to their respective hosts."""
        for gateway in self.config['list']:
            if self._stop_event.is_set():
                break
            data = self.random_one_gateway_json_data(gateway, collectTime)
            post_url = self.config['postUrl'][gateway['type']]
            self.post_data_to_host(data, post_url)

    def post_one_data_tohost_by_index(self, gateway_index: int = 0) -> None:
        """Post data for a specific gateway by index."""
        if gateway_index >= len(self.config['list']):
            logger.error('Gateway index %d out of range', gateway_index)
            return

        gateway = self.config['list'][gateway_index]
        data = self.random_one_gateway_json_data(gateway)
        post_url = self.config['postUrl'][gateway['type']]
        self.post_data_to_host(data, post_url)

    def insert_historical_data(self) -> None:
        """Insert historical data based on datetime range configuration."""
        historical_config = self.config.get('historicalDataRange', {})

        if not historical_config.get('enable', False):
            logger.info('%s Historical data insertion disabled',
                       self.config['name'])
            return

        try:
            start_time = parse_datetime_string(historical_config['startTime'])
            end_time = parse_datetime_string(historical_config['endTime'])
            interval_seconds = historical_config.get('intervalSeconds', 1800)

            if start_time >= end_time:
                logger.error('%s Invalid time range: start >= end',
                           self.config['name'])
                return

            logger.info('%s Starting historical data insertion from %s to %s',
                       self.config['name'],
                       historical_config['startTime'],
                       historical_config['endTime'])

            current_time = start_time
            total_iterations = int((end_time - start_time) / interval_seconds)
            completed = 0

            while current_time <= end_time and not self._stop_event.is_set():
                self.post_one_data_tohost(current_time)
                current_time += interval_seconds
                completed += 1

                # Log progress every 100 iterations
                if completed % 100 == 0:
                    progress = (completed / total_iterations) * 100
                    logger.info('%s Historical data progress: %.1f%% (%d/%d)',
                               self.config['name'], progress,
                               completed, total_iterations)

            logger.info('%s Historical data insertion completed',
                       self.config['name'])

        except Exception as e:
            logger.error('%s Historical data insertion failed: %s',
                        self.config['name'], str(e))

    def schedules(self) -> None:
        """Set up scheduled data posting for real-time mode."""
        if not self.config['enable']:
            logger.info('%s setting disabled, passed.', self.config['name'])
            return

        for idx, gateway in enumerate(self.config['list']):
            interval = gateway.get('interval', 15)
            intervalTo = gateway.get('intervalTo', interval + 15)
            schedule.every(interval).to(intervalTo).seconds.do(
                self.post_one_data_tohost_by_index, idx
            )
            logger.info('gateway: %s already schedule.', gateway['id'])

        logger.info('%s has %s gateway started.\n\n',
                   self.config['name'], len(self.config['list']))

    def stop(self) -> None:
        """Stop all operations gracefully."""
        self._stop_event.set()
        self._executor.shutdown(wait=True)
        logger.info('%s stopped gracefully', self.config['name'])

def run_pending() -> None:
    """Run scheduled tasks continuously."""
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == '__main__':
    arg_path = sys.argv[1] if len(sys.argv) > 1 else ''
    config_json_path = arg_path or os.path.join(os.getcwd(), 'config.json')

    if not os.path.exists(config_json_path):
        shutil.copy(_TML_CONFIG_JSON_PATH, config_json_path)

    try:
        with open(config_json_path, mode='r', encoding='utf-8') as f:
            json_config_list = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error('Failed to load config file: %s', str(e))
        sys.exit(1)

    monitor_instances = []

    try:
        for _json_config in json_config_list:
            _rmds = RandomMonitorData(_json_config)
            monitor_instances.append(_rmds)

            # Check for historical data mode first (new feature)
            historical_config = _json_config.get('historicalDataRange', {})
            if historical_config.get('enable', False):
                _rmds.insert_historical_data()
            else:
                _rmds.schedules()

        # Only run pending if we have scheduled tasks
        if any(not config.get('historicalDataRange', {}).get('enable', False)
               for config in json_config_list):
            run_pending()

    except KeyboardInterrupt:
        logger.info('Received interrupt signal, shutting down...')
        for instance in monitor_instances:
            instance.stop()
    except Exception as e:
        logger.error('Unexpected error: %s', str(e))
        for instance in monitor_instances:
            instance.stop()
        sys.exit(1)
