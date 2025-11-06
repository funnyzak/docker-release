# coding: utf-8

"""
File: monitor_data.py
Created: 2019-08-06
Updated: 2025-06-05
Author: leon
Description: Send random device monitoring data to server
Features: Support multiple device types for data simulation, including real-time data sending and historical data backfill
"""

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
import argparse
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor
import threading

# Get current execution path and log path
EXEC_PATH = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(EXEC_PATH, 'logs')
os.makedirs(LOG_PATH, exist_ok=True)


def new_logger(log_name: Optional[str] = None, log_level: int = logging.INFO) -> logging.Logger:
    """
    Create a new logger with file and console output support

    Args:
        log_name: Log file name, defaults to 'info.log'
        log_level: Log level, defaults to logging.INFO

    Returns:
        Configured logger instance
    """
    # Set default log file name
    log_name = log_name or 'info.log'
    logger = logging.getLogger(os.path.splitext(log_name)[0])
    LOG_FILENAME = os.path.join(LOG_PATH, log_name)
    logger.setLevel(log_level)

    # Avoid duplicate handlers
    if logger.handlers:
        return logger

    # Create log formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(process)d-%(threadName)s - '
        '%(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s'
    )

    # Add console output handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(log_level)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    # Add file output handler with log rotation
    file_handler = logging.handlers.RotatingFileHandler(
        LOG_FILENAME, maxBytes=5242880, backupCount=5, encoding="utf-8"
    )
    file_handler.setLevel(log_level)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger


def get_timestamp(timeStamp: int) -> Tuple[int, int]:
    """
    Get start and end timestamps for the date containing the specified timestamp

    Args:
        timeStamp: Input timestamp

    Returns:
        Tuple (start_timestamp, end_timestamp) representing 00:00:00 to 23:59:59 of that day
    """
    # Convert timestamp to local time
    timeArray = time.localtime(timeStamp)
    # Format as date string
    otherStyleTime = time.strftime("%Y-%m-%d", timeArray)
    # Re-parse as time array, removing hour/minute/second information
    timeArray = time.strptime(otherStyleTime, "%Y-%m-%d")
    # Convert to start of day timestamp
    timeStamp = int(time.mktime(timeArray))
    # Return start and end timestamps of the day
    return timeStamp, timeStamp + 86400


def parse_datetime_string(datetime_str: str) -> float:
    """
    Parse datetime string to timestamp

    Args:
        datetime_str: Datetime string in format "YYYY-MM-DD HH:MM:SS"

    Returns:
        Corresponding timestamp (float)

    Raises:
        ValueError: Raised when datetime format is incorrect
    """
    try:
        # Parse datetime string
        dt = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")
        return dt.timestamp()
    except ValueError as e:
        raise ValueError(f"Invalid datetime format: {datetime_str}. "
                         f"Expected format: YYYY-MM-DD HH:MM:SS") from e


def validate_config(config: Dict[str, Any]) -> None:
    """
    Validate configuration file structure completeness and correctness

    Args:
        config: Configuration dictionary

    Raises:
        ValueError: Raised when configuration structure is incorrect
    """
    # Check required configuration fields
    required_fields = ['name', 'enable', 'postUrl', 'list']
    for field in required_fields:
        if field not in config:
            raise ValueError(f"Missing required configuration field: {field}")

    # Check if device list is an array
    if not isinstance(config['list'], list):
        raise ValueError("'list' field must be an array type")

    # Check configuration for each gateway device
    for gateway in config['list']:
        if 'type' not in gateway:
            raise ValueError("Gateway device missing 'type' field")
        if gateway['type'] not in config['postUrl']:
            raise ValueError(f"postUrl not configured for gateway type: {gateway['type']}")


# Configuration file template path
_TML_CONFIG_JSON_PATH = os.path.join(os.getcwd(), 'config.sample.json')

# Global logger instance (will be initialized in main)
logger = None


def parse_arguments() -> argparse.Namespace:
    """
    Parse command line arguments

    Returns:
        Parsed arguments namespace
    """
    parser = argparse.ArgumentParser(
        description='监控数据模拟生成系统 - 生成和发送多种类型设备监控数据',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  %(prog)s                                    # 使用默认配置 config.json 和 INFO 日志级别
  %(prog)s -c config_custom.json              # 指定配置文件
  %(prog)s --log-level DEBUG                  # 设置日志级别为 DEBUG
  %(prog)s -c config.json -l WARNING          # 同时指定配置文件和日志级别
        """
    )

    parser.add_argument(
        '-c', '--config',
        type=str,
        default='config.json',
        help='配置文件路径 (默认: config.json)'
    )

    parser.add_argument(
        '-l', '--log-level',
        type=str,
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
        default='INFO',
        help='日志级别: DEBUG, INFO, WARNING, ERROR, CRITICAL (默认: INFO)'
    )

    return parser.parse_args()


def get_log_level(level_name: str) -> int:
    """
    Convert log level name string to logging level constant

    Args:
        level_name: Log level name (DEBUG, INFO, WARNING, ERROR, CRITICAL)

    Returns:
        Corresponding logging level constant
    """
    level_map = {
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO,
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR,
        'CRITICAL': logging.CRITICAL,
    }
    return level_map.get(level_name.upper(), logging.INFO)


class RandomMonitorData:
    """
    Random monitoring data generator and sender

    Supports data simulation for multiple device types:
    - BRT devices (Bluetooth temperature and humidity sensors)
    - CTHM devices (Constant temperature and humidity machines)

    Supports two operation modes:
    1. Real-time mode: Periodically send data at configured intervals
    2. Historical data mode: Batch send historical data within specified time range
    """

    def __init__(self, config: Dict[str, Any]):
        """
        Initialize monitoring data generator

        Args:
            config: Configuration dictionary containing device information and sending configuration
        """
        # Validate configuration file completeness
        validate_config(config)
        self.config = config
        # Create stop event for graceful shutdown
        self._stop_event = threading.Event()
        # Create thread pool executor
        self._executor = ThreadPoolExecutor(max_workers=5)
        logger.info(f"Initialized RandomMonitorData for config: {config.get('name', 'Unknown')}")

    def is_night(self, check_time: Optional[float] = None) -> bool:
        """
        Check if specified time is in night period

        Night period is used for certain devices (e.g., light sensors) to adjust data range

        Args:
            check_time: Time to check, uses current time if None

        Returns:
            True if specified time is in night period, False otherwise
        """
        # Get night time configuration, default 17:30-21:00 is night
        night_interval = self.config.get(
            'nightInterval', {"start": 63000, "end": 118800}
        )
        # Use specified time or current time
        now_ts = int(check_time) if check_time is not None else int(time.time())
        # Get start timestamp of current day
        day_ts = get_timestamp(now_ts)
        # Check if specified time is within night period
        return ((day_ts[0] + night_interval['start']) < now_ts <
                (day_ts[0] + night_interval['end']))

    def is_in_daily_run_interval(self) -> bool:
        """
        Check if current time is within daily run interval

        Used to control the time range for simulated data sending, only send data within specified time interval

        Returns:
            True if current time is within run interval, False otherwise
        """
        # Get daily run time configuration, no restriction if not configured
        daily_run_interval = self.config.get('dailyRunInterval')
        if not daily_run_interval:
            return True  # No restriction if run time interval is not configured
        # Get current timestamp
        now_ts = int(time.time())
        # Get start timestamp of current day
        day_ts = get_timestamp(now_ts)
        # Check if current time is within run interval
        return ((day_ts[0] + daily_run_interval['start']) <= now_ts <=
                (day_ts[0] + daily_run_interval['end']))

    def random_brt_device_data(self, device: Dict[str, Any],
                               time_seed: int = 10,
                               collectTime: Optional[float] = None) -> Dict[str, Any]:
        """
        Generate random data for BRT device

        BRT devices are Bluetooth temperature and humidity sensors, supporting multiple monitoring indicators:
        - lux, hcho, uva_class, uva_raw, co2, voc: Optional monitoring indicators

        Args:
            device: Device configuration information
            time_seed: Time random seed for simulating randomness in data collection time
            collectTime: Specified data collection time, uses current time if None

        Returns:
            Dictionary containing device data
        """
        # Build base device data
        temp_value = int((device['temp'] + rd.randrange(-5, 5)))
        humi_value = int((device['humi'] + rd.randrange(-5, 5)))

        # Use specified collection time or current time for scan_time
        base_time = collectTime if collectTime is not None else time.time()

        log = {
            "ble_addr": device['mac'],  # Bluetooth MAC address
            "addr_type": 1,  # Address type
            "scan_rssi": rd.randrange(50, 90),  # Signal strength
            "scan_time": int(base_time) - rd.randrange(0, time_seed),  # Scan time
            "humi": format(humi_value, "x"),  # Humidity
            "pwr": device.get('pwr', 99),  # Power percentage (hexadecimal)
            "temp": format(temp_value, "x")  # Temperature
        }

        # Add optional monitoring indicators if configured
        # lux: Light intensity
        if 'lux' in device:
            # Select different light value based on whether it's night
            lux = (device.get('luxNight', device['lux']) if self.is_night(collectTime)
                   else device['lux'])
            log["lux"] = format(int(lux + rd.randrange(-1, 1)), "x")

        # hcho: Formaldehyde concentration
        if 'hcho' in device:
            log["hcho"] = format(int(device['hcho'] + rd.randrange(-1, 1)), "x")

        # uva_class: UVA level (1-12)
        if 'uva_class' in device:
            log["uva_class"] = format(int(device['uva_class'] + rd.randrange(-1, 1)), "x")

        # uva_raw: UVA raw value
        if 'uva_raw' in device:
            log["uva_raw"] = format(int(device['uva_raw'] + rd.randrange(-1, 1)), "x")

        # co2: Carbon dioxide concentration
        if 'co2' in device:
            log["co2"] = format(int(device['co2'] + rd.randrange(-5, 5)), "x")

        # voc: Volatile organic compounds
        if 'voc' in device:
            log["voc"] = format(int(device['voc'] + rd.randrange(-3, 3)), "x")

        return log

    def random_brt_gateway_data(self, gateway: Dict[str, Any],
                                collectTime: Optional[float] = None) -> str:
        """
        Generate random data packet for BRT gateway

        BRT gateway can manage multiple BRT devices and package all device data for sending

        Args:
            gateway: Gateway configuration information
            collectTime: Specified data collection time, uses current time if None

        Returns:
            JSON formatted gateway data packet string
        """
        # Generate data for all devices under gateway
        _device_list = [
            self.random_brt_device_data(device, gateway.get('timeSeed', 25), collectTime)
            for device in gateway['deviceList']
        ]
        # Use specified time or current time
        deviceTime = collectTime or time.time()
        # Build gateway data packet
        return json.dumps({
            "devices": _device_list,  # Device data list
            "seq_no": rd.randrange(10),  # Sequence number
            "cbid": gateway['id'],  # Gateway ID
            "time": int(deviceTime),  # Data time
            "cmd": rd.randrange(1000),  # Command code
        }, sort_keys=True, indent=4)

    def random_cthm_gateway_device_data(
            self, gateway: Dict[str, Any],
            collectTime: Optional[float] = None) -> str:
        """
        Generate random data for CTHM device

        CTHM is a constant temperature and humidity machine device, mainly monitoring temperature and humidity
        Temperature and humidity values are float in config, adding random variation
        Traverses all devices in deviceList and generates data for each device

        Supports two data formats:
        - v1 (legacy): Simple format with hex-encoded temperature and humidity
        - v2 (current): ISO 8601 format with detailed device information

        Args:
            gateway: Device configuration information (contains deviceList array)
            collectTime: Specified data collection time, uses current time if None

        Returns:
            JSON formatted device data string
            Returns an array containing data for all devices in deviceList
        """
        # CTHM deviceList is an array, process all devices
        if not gateway.get('deviceList') or len(gateway['deviceList']) == 0:
            raise ValueError("CTHM deviceList is empty")

        # Check if v1 format is enabled (default: v2)
        use_v1_format = gateway.get('useV1Format', False)

        deviceTime = collectTime or time.time()
        device_data_list = []

        # Traverse all devices in deviceList
        for device in gateway['deviceList']:
            # Apply time seed variation to simulate data collection time randomness
            actualTime = deviceTime - rd.randrange(0, gateway.get('timeSeed', 25))

            # Generate temperature and humidity with random variation
            temperature = round(device['temp'] + rd.uniform(-5, 5), 1)
            humidity = round(device['humi'] + rd.uniform(-5, 5), 1)

            if use_v1_format:
                # v1 format: Legacy format with hex-encoded values
                # temp and humi are multiplied by 100, then converted to hex
                temp_hex = format(int(temperature * 100), "x")
                humi_hex = format(int(humidity * 100), "x")

                log = {
                    "macId": device['mac'],  # MAC address
                    "time": int(actualTime),  # Timestamp (integer)
                    "humi": humi_hex.upper(),  # Humidity (hex string, multiplied by 100)
                    "temp": temp_hex.upper()  # Temperature (hex string, multiplied by 100)
                }

                # If IP address is configured, add to data (v1 uses localIp)
                if 'ip' in device:
                    log['localIp'] = device['ip']

            else:
                # v2 format: Current format with ISO 8601 timestamp
                # Convert timestamp to ISO 8601 format with timezone
                # Use local timezone (UTC+8 for China) or system timezone
                dt = datetime.fromtimestamp(actualTime)
                # Add timezone info if not present (assume local timezone)
                if dt.tzinfo is None:
                    # Get local timezone offset
                    local_offset = time.timezone if (time.daylight == 0) else time.altzone
                    local_tz = timezone(timedelta(seconds=-local_offset))
                    dt = dt.replace(tzinfo=local_tz)
                iso_timestamp = dt.isoformat()

                # Build device data object
                log = {
                    "name": device.get('name', 'Unknown Device'),  # Device name
                    "type": "HumidifyingMachine",  # Fixed device type
                    "mac": device['mac'],  # Device MAC address
                    "temperature": temperature,  # Temperature (float)
                    "humidity": humidity,  # Humidity (float)
                    "is_active": device.get('is_active', True),  # Device active status
                    "last_seen": iso_timestamp,  # Last seen time (ISO 8601)
                    "timestamp": iso_timestamp  # Data timestamp (ISO 8601)
                }

                # If IP address is configured, add to data
                if 'ip' in device:
                    log['ip'] = device['ip']

            device_data_list.append(log)

        # Return JSON array containing all device data
        return json.dumps(device_data_list, sort_keys=True, indent=4)

    def random_one_gateway_json_data(self, gateway: Dict[str, Any],
                                     collectTime: Optional[float] = None) -> str:
        """
        Generate random data based on gateway type

        Factory method that calls corresponding data generation function based on device type

        Args:
            gateway: Gateway/device configuration information
            collectTime: Specified data collection time, uses current time if None

        Returns:
            JSON formatted device data string

        Raises:
            ValueError: Raised when encountering unknown device type
        """
        gateway_type = gateway['type']

        # Select corresponding data generation method based on device type
        if gateway_type == 'brt':
            return self.random_brt_gateway_data(gateway, collectTime)
        elif gateway_type == 'cthm':
            return self.random_cthm_gateway_device_data(gateway, collectTime)
        else:
            raise ValueError(f"Unknown device type: {gateway_type}")

    def post_data_to_host(self, data: str, post_url: str) -> None:
        """
        Send data to specified server address

        Send JSON data using HTTP POST method, includes complete error handling and logging

        Args:
            data: JSON data string to send
            post_url: Target server URL
        """
        logger.info('[%s] Sending data to %s (data length: %d bytes)',
                    self.config['name'], post_url, len(data))
        logger.debug('[%s] Request body data: %s', self.config['name'], data)
        try:
            # Send HTTP POST request
            response = requests.post(
                post_url,
                data=data,
                headers={"Content-Type": "application/json"},
                timeout=30  # 30 second timeout
            )
            # Check HTTP status code, raise exception if not 2xx
            response.raise_for_status()
            logger.info('[%s] Data sent successfully (status: %d)',
                       self.config['name'], response.status_code)
        except requests.ConnectionError as e:
            logger.error('[%s] Connection error when sending data: %s',
                        self.config['name'], str(e))
        except requests.Timeout:
            logger.error('[%s] Timeout error when sending data to %s',
                        self.config['name'], post_url)
        except requests.HTTPError as e:
            logger.error('[%s] HTTP error when sending data: %s (status: %d)',
                        self.config['name'], str(e), response.status_code if 'response' in locals() else 0)
        except Exception as e:
            logger.error('[%s] Unexpected error when sending data: %s',
                        self.config['name'], str(e), exc_info=True)

    def post_one_data_tohost(self,
                             collectTime: Optional[float] = None) -> None:
        """
        Generate and send one round of data for all gateway devices

        Iterate through all devices in configuration, generate data for each device and send to corresponding server
        For CTHM devices, traverses deviceList and sends data for each device separately

        Args:
            collectTime: Specified data collection time, uses current time if None
        """
        logger.debug('[%s] Starting to send data for all gateways', self.config['name'])
        for gateway in self.config['list']:
            # Check if stop signal received
            if self._stop_event.is_set():
                logger.info('[%s] Stop signal received, stopping data sending', self.config['name'])
                break
            # Generate device data
            data = self.random_one_gateway_json_data(gateway, collectTime)
            # Get sending address for corresponding device type
            post_url = self.config['postUrl'][gateway['type']]

            # For CTHM devices, data is returned as an array, send each device separately
            if gateway['type'] == 'cthm':
                try:
                    device_list = json.loads(data)
                    if isinstance(device_list, list):
                        # Traverse all devices and send each one separately
                        for device_data in device_list:
                            device_json = json.dumps(device_data, sort_keys=True, indent=4)
                            self.post_data_to_host(device_json, post_url)
                    else:
                        # Fallback: send as single object
                        self.post_data_to_host(data, post_url)
                except (json.JSONDecodeError, TypeError) as e:
                    logger.error('[%s] Failed to parse CTHM device data: %s',
                                self.config['name'], str(e))
                    # Fallback: send original data
                    self.post_data_to_host(data, post_url)
            else:
                # For other device types, send data directly
                self.post_data_to_host(data, post_url)
        logger.debug('[%s] Completed sending data for all gateways', self.config['name'])

    def post_one_data_tohost_by_index(self, gateway_index: int = 0) -> None:
        """
        Generate and send data for gateway device at specified index

        This method is mainly used for scheduled tasks, sending data for a single device

        Args:
            gateway_index: Device index in configuration list
        """
        # Check if within daily run interval
        if not self.is_in_daily_run_interval():
            logger.debug('[%s] Current time is not within run interval, skipping data send',
                        self.config['name'])
            return

        # Check if index is valid
        if gateway_index >= len(self.config['list']):
            logger.error('[%s] Device index %d is out of range (max: %d)',
                        self.config['name'], gateway_index, len(self.config['list']) - 1)
            return

        # Get device configuration at specified index
        gateway = self.config['list'][gateway_index]
        logger.debug('[%s] Generating data for device: %s (type: %s)',
                    self.config['name'], gateway['id'], gateway['type'])
        # Generate device data
        data = self.random_one_gateway_json_data(gateway)
        # Get sending address for corresponding device type
        post_url = self.config['postUrl'][gateway['type']]

        # For CTHM devices, data is returned as an array, send each device separately
        if gateway['type'] == 'cthm':
            try:
                device_list = json.loads(data)
                if isinstance(device_list, list):
                    # Traverse all devices and send each one separately
                    for device_data in device_list:
                        device_json = json.dumps(device_data, sort_keys=True, indent=4)
                        self.post_data_to_host(device_json, post_url)
                else:
                    # Fallback: send as single object
                    self.post_data_to_host(data, post_url)
            except (json.JSONDecodeError, TypeError) as e:
                logger.error('[%s] Failed to parse CTHM device data: %s',
                            self.config['name'], str(e))
                # Fallback: send original data
                self.post_data_to_host(data, post_url)
        else:
            # For other device types, send data directly
            self.post_data_to_host(data, post_url)

    def insert_historical_data(self) -> None:
        """
        Insert historical data

        Batch generate and send historical data based on time range and interval in configuration
        This feature is used for data backfill or testing scenarios
        """
        # Get historical data configuration
        historical_config = self.config.get('historicalDataRange', {})

        # Check if historical data insertion is enabled
        if not historical_config.get('enable', False):
            logger.info('[%s] Historical data insertion is disabled',
                        self.config['name'])
            return

        try:
            # Parse start and end time
            start_time = parse_datetime_string(historical_config['startTime'])
            end_time = parse_datetime_string(historical_config['endTime'])
            # Get time interval, default 10 minutes
            interval_seconds = historical_config.get('intervalSeconds', 600)

            # Validate time range validity
            if start_time >= end_time:
                logger.error('[%s] Invalid time range: start time >= end time',
                             self.config['name'])
                return

            logger.info('[%s] Starting historical data insertion, time range: %s to %s',
                        self.config['name'],
                        historical_config['startTime'],
                        historical_config['endTime'])

            # Initialize loop variables
            current_time = start_time
            total_iterations = int((end_time - start_time) / interval_seconds)
            completed = 0

            logger.info('[%s] Total iterations: %d, interval: %d seconds',
                        self.config['name'], total_iterations, interval_seconds)

            # Loop and send data at time intervals
            while current_time <= end_time and not self._stop_event.is_set():
                # Send data for current time point
                self.post_one_data_tohost(current_time)
                # sleep 1 second
                # time.sleep(1)
                # Advance time by one interval
                current_time += interval_seconds
                completed += 1

                # Log progress every 100 iterations
                if completed % 100 == 0:
                    progress = (completed / total_iterations) * 100
                    logger.info('[%s] Historical data insertion progress: %.1f%% (%d/%d)',
                                self.config['name'], progress,
                                completed, total_iterations)

            logger.info('[%s] Historical data insertion completed (total: %d iterations)',
                        self.config['name'], completed)

        except Exception as e:
            logger.error('[%s] Historical data insertion failed: %s',
                         self.config['name'], str(e), exc_info=True)

    def schedules(self) -> None:
        """
        Set up scheduled tasks for real-time mode

        Configure scheduled sending tasks for each device, supporting different sending intervals
        """
        # Check if configuration is enabled
        if not self.config['enable']:
            logger.info('[%s] Configuration is disabled, skipping setup',
                        self.config['name'])
            return

        # Get daily run time configuration
        daily_run_interval = self.config.get('dailyRunInterval')
        if daily_run_interval:
            start_hour = daily_run_interval['start'] // 3600
            start_minute = (daily_run_interval['start'] % 3600) // 60
            end_hour = daily_run_interval['end'] // 3600
            end_minute = (daily_run_interval['end'] % 3600) // 60

            logger.info('[%s] Daily run time interval: %02d:%02d - %02d:%02d',
                        self.config['name'], start_hour, start_minute, end_hour, end_minute)

        # Set up scheduled tasks for each device
        for idx, gateway in enumerate(self.config['list']):
            # Get sending interval, default 15 seconds
            interval = gateway.get('interval', 15)
            # Get interval upper limit, default interval + 15 seconds
            intervalTo = gateway.get('intervalTo', interval + 15)
            # Set scheduled task, execute randomly between interval and intervalTo seconds
            schedule.every(interval).to(intervalTo).seconds.do(
                self.post_one_data_tohost_by_index, idx
            )
            logger.info('[%s] Device %s scheduled task set up (interval: %d-%d seconds)',
                        self.config['name'], gateway['id'], interval, intervalTo)

        logger.info('[%s] Scheduled tasks started for %d device(s)',
                    self.config['name'], len(self.config['list']))

    def stop(self) -> None:
        """
        Gracefully stop all operations

        Set stop event, shutdown thread pool, ensure all resources are properly released
        """
        logger.info('[%s] Initiating graceful shutdown', self.config['name'])
        # Set stop event
        self._stop_event.set()
        # Shutdown thread pool and wait for all tasks to complete
        self._executor.shutdown(wait=True)
        logger.info('[%s] Gracefully stopped', self.config['name'])


def run_pending() -> None:
    """
    Continuously run scheduled tasks

    This is the main loop function that continuously checks and executes due scheduled tasks
    """
    logger.info('Starting scheduled task loop')
    while True:
        # Run all due scheduled tasks
        schedule.run_pending()
        # Sleep 1 second to avoid high CPU usage
        time.sleep(1)


if __name__ == '__main__':
    # Parse command line arguments
    args = parse_arguments()

    # Get log level from arguments
    log_level = get_log_level(args.log_level)

    # Create logger with specified log level and assign to global logger
    logger = new_logger(log_level=log_level)
    # Update module-level logger for use in classes
    import sys
    sys.modules[__name__].logger = logger

    # Get configuration file path from arguments
    config_json_path = args.config
    # If relative path, make it absolute relative to current working directory
    if not os.path.isabs(config_json_path):
        config_json_path = os.path.join(os.getcwd(), config_json_path)

    logger.info('Starting monitor data generator')
    logger.info('Configuration file path: %s', config_json_path)
    logger.info('Log level: %s', args.log_level)

    # If configuration file doesn't exist, copy template file
    if not os.path.exists(config_json_path):
        if os.path.exists(_TML_CONFIG_JSON_PATH):
            logger.info('Configuration file not found, copying from template: %s',
                       _TML_CONFIG_JSON_PATH)
            shutil.copy(_TML_CONFIG_JSON_PATH, config_json_path)
            logger.info('Template file copied to: %s', config_json_path)
        else:
            logger.error('Configuration file not found and template file not available: %s',
                        _TML_CONFIG_JSON_PATH)
            sys.exit(1)

    try:
        # Read configuration file
        with open(config_json_path, mode='r', encoding='utf-8') as f:
            json_load = json.load(f)
        if isinstance(json_load, list):
            json_config_list = json_load
        else:
            json_config_list = json_load.get('config', [])

        logger.info('Configuration file loaded successfully, found %d configuration(s)',
                   len(json_config_list))
    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error('Failed to load configuration file: %s', str(e), exc_info=True)
        sys.exit(1)

    # Store all monitor instances for graceful shutdown
    monitor_instances = []

    try:
        # Create monitor instance for each configuration
        for idx, _json_config in enumerate(json_config_list):
            logger.info('Processing configuration %d/%d: %s',
                       idx + 1, len(json_config_list), _json_config.get('name', 'Unknown'))
            _rmds = RandomMonitorData(_json_config)
            monitor_instances.append(_rmds)

            # Check if historical data mode is enabled
            historical_config = _json_config.get('historicalDataRange', {})
            if historical_config.get('enable', False):
                # Historical data mode: batch insert historical data
                logger.info('[%s] Historical data mode enabled',
                           _json_config.get('name', 'Unknown'))
                _rmds.insert_historical_data()
            else:
                # Real-time mode: set up scheduled tasks
                logger.info('[%s] Real-time mode enabled',
                           _json_config.get('name', 'Unknown'))
                _rmds.schedules()

        # Only run main loop if there are scheduled tasks
        if any(not config.get('historicalDataRange', {}).get('enable', False)
               for config in json_config_list):
            logger.info('Starting scheduled task loop')
            run_pending()
        else:
            logger.info('All configurations are in historical data mode, exiting')

    except KeyboardInterrupt:
        logger.info('Received interrupt signal, shutting down...')
        # Gracefully shutdown all instances
        for instance in monitor_instances:
            instance.stop()
        logger.info('Shutdown completed')
    except Exception as e:
        logger.error('Unexpected error: %s', str(e), exc_info=True)
        # Also gracefully shutdown all instances when exception occurs
        for instance in monitor_instances:
            instance.stop()
        sys.exit(1)
