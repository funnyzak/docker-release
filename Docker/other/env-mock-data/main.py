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
LOG_PATH = os.path.join(EXEC_PATH, "logs")
os.makedirs(LOG_PATH, exist_ok=True)


def new_logger(log_name: Optional[str] = None) -> logging.Logger:
    log_name = log_name or "info.log"
    logger = logging.getLogger(os.path.splitext(log_name)[0])
    LOG_FILENAME = os.path.join(LOG_PATH, log_name)
    logger.setLevel(logging.INFO)

    if logger.handlers:
        return logger

    formatter = logging.Formatter(
        "%(asctime)s - %(process)d-%(threadName)s - "
        "%(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s"
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

    timeArray = time.localtime(timeStamp)

    otherStyleTime = time.strftime("%Y-%m-%d", timeArray)

    timeArray = time.strptime(otherStyleTime, "%Y-%m-%d")

    timeStamp = int(time.mktime(timeArray))

    return timeStamp, timeStamp + 86400


def parse_datetime_string(datetime_str: str) -> float:

    try:

        dt = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")
        return dt.timestamp()
    except ValueError as e:
        raise ValueError(
            f"日期时间格式无效: {datetime_str}. " f"期望格式: YYYY-MM-DD HH:MM:SS"
        ) from e


def validate_config(config: Dict[str, Any]) -> None:

    required_fields = ["name", "enable", "postUrl", "list"]
    for field in required_fields:
        if field not in config:
            raise ValueError(f"缺少必需的配置字段: {field}")

    if not isinstance(config["list"], list):
        raise ValueError("'list' 字段必须是数组类型")

    for gateway in config["list"]:
        if "type" not in gateway:
            raise ValueError("网关设备缺少 'type' 字段")
        if gateway["type"] not in config["postUrl"]:
            raise ValueError(f"未为网关类型配置postUrl: {gateway['type']}")


logger = new_logger()


_TML_CONFIG_JSON_PATH = os.path.join(os.getcwd(), "config.sample.json")


class RandomMonitorData:
    def __init__(self, config: Dict[str, Any]):

        validate_config(config)
        self.config = config

        self._stop_event = threading.Event()

        self._executor = ThreadPoolExecutor(max_workers=5)

    def is_night(self) -> bool:

        night_interval = self.config.get(
            "nightInterval", {"start": 63000, "end": 118800}
        )

        now_ts = int(time.time())

        day_ts = get_timestamp(now_ts)

        return (
            (day_ts[0] + night_interval["start"])
            < now_ts
            < (day_ts[0] + night_interval["end"])
        )

    def is_in_daily_run_interval(self) -> bool:

        daily_run_interval = self.config.get("dailyRunInterval")
        if not daily_run_interval:
            return True

        now_ts = int(time.time())

        day_ts = get_timestamp(now_ts)

        return (
            (day_ts[0] + daily_run_interval["start"])
            <= now_ts
            <= (day_ts[0] + daily_run_interval["end"])
        )

    def random_brt_device_data(
        self, device: Dict[str, Any], time_seed: int = 10
    ) -> Dict[str, Any]:

        log = {
            "ble_addr": device["mac"],
            "addr_type": 1,
            "scan_rssi": rd.randrange(50, 90),
            "scan_time": int(time.time()) - rd.randrange(0, time_seed),
            "humi": format(int(device["humi"] + rd.randrange(-5, 5)), "x"),
            "pwr_percent": format(device["pwr"], "x"),
            "temp": format(int(device["temp"] + rd.randrange(-5, 5)), "x"),
        }

        if device["type"].upper() == "VOC":

            lux = device.get("luxNight", 0) if self.is_night() else device["lux"]
            log.update(
                {
                    "lux": format(int(lux + rd.randrange(-5, 5)), "x"),
                    "tvoc": format(int(device["tvoc"] + rd.randrange(-5, 5)), "x"),
                    "eco2": format(int(device["eco2"] + rd.randrange(-5, 5)), "x"),
                }
            )
        return log

    def random_brt_gateway_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:

        _device_list = [
            self.random_brt_device_data(device, gateway["timeSeed"])
            for device in gateway["deviceList"]
        ]

        deviceTime = collectTime or time.time()

        return json.dumps(
            {
                "devices": _device_list,
                "seq_no": rd.randrange(10),
                "cbid": gateway["id"],
                "time": int(deviceTime),
                "cmd": rd.randrange(1000),
            },
            sort_keys=True,
            indent=4,
        )

    def random_cthm_gateway_device_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:

        device = gateway["device"]
        deviceTime = collectTime or time.time()

        log = {
            "macId": device["mac"],
            "time": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "humi": format(int(device["humi"] + rd.randrange(-50, 50, 10)), "x"),
            "temp": format(int(device["temp"] + rd.randrange(-50, 50, 10)), "x"),
        }

        if "runningStatus" in device:
            log["runningStatus"] = device["runningStatus"]

        if "ip" in device:
            log["localIp"] = device["ip"]

        return json.dumps(log, sort_keys=True, indent=4)

    def random_toprie_gateway_device_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:

        device = gateway["device"]
        deviceTime = collectTime or time.time()

        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "macId": device["mac"],
            "monitorData": {
                "FORMALDEHYDE": format(
                    int(device["formaldehyde"] + rd.randrange(-50, 50, 10)), "x"
                ),
                "HUMIDITY": format(
                    int(device["humidity"] + rd.randrange(-50, 50, 10)), "x"
                ),
                "TEMPERATURE": format(
                    int(device["temperature"] + rd.randrange(-50, 50, 10)), "x"
                ),
            },
            "originData": "",
        }

        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "monitorDto": [logdata],
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_cthc_fh_gateway_device_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:

        device = gateway["device"]
        deviceTime = collectTime or time.time()

        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "macId": device["mac"],
            "monitorData": {
                "HUMIDITY": format(
                    int(device["humidity"] + rd.randrange(-50, 50, 10)), "x"
                ),
                "TEMPERATURE": format(
                    int(device["temperature"] + rd.randrange(-50, 50, 10)), "x"
                ),
            },
            "originData": "",
        }

        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "monitorDto": [logdata],
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_milesight_gateway_device_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:

        device = gateway["device"]
        deviceTime = collectTime or time.time()

        logdata = {
            "scanTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "macId": device["mac"],
            "monitorData": {
                "ECO2": format(int(device["eco2"] + rd.randrange(-50, 50, 10)), "x"),
                "TVOC": format(int(device["tvoc"] + rd.randrange(-50, 50, 10)), "x"),
                "LUX": format(int(device["lux"] + rd.randrange(-50, 50, 10)), "x"),
            },
            "originData": "",
        }

        log = {
            "collectTime": int(deviceTime) - rd.randrange(0, gateway["timeSeed"]),
            "monitorDto": [logdata],
        }
        return json.dumps(log, sort_keys=True, indent=4)

    def random_one_gateway_json_data(
        self, gateway: Dict[str, Any], collectTime: Optional[float] = None
    ) -> str:
        gateway_type = gateway["type"]

        if gateway_type == "brt":
            return self.random_brt_gateway_data(gateway, collectTime)
        elif gateway_type == "cthm":
            return self.random_cthm_gateway_device_data(gateway, collectTime)
        elif gateway_type == "toprie":
            return self.random_toprie_gateway_device_data(gateway, collectTime)
        elif gateway_type == "cthc-fh":
            return self.random_cthc_fh_gateway_device_data(gateway, collectTime)
        elif gateway_type == "milesight":
            return self.random_milesight_gateway_device_data(gateway, collectTime)
        else:
            raise ValueError(f"未知的设备类型: {gateway_type}")

    def post_data_to_host(self, data: str, post_url: str) -> None:
        logger.info("%s 发送数据: %s 到 %s .", self.config["name"], data, post_url)
        try:

            response = requests.post(
                post_url,
                data=data,
                headers={"Content-Type": "application/json"},
                timeout=30,
            )

            response.raise_for_status()
        except requests.ConnectionError:
            logger.error("%s 发送数据连接错误.", self.config["name"])
        except requests.Timeout:
            logger.error("%s 发送数据超时错误.", self.config["name"])
        except requests.HTTPError as e:
            logger.error("%s 发送数据HTTP错误: %s.", self.config["name"], str(e))
        except Exception as e:
            logger.error("%s 发送数据异常: %s.", self.config["name"], str(e))
        else:
            logger.info("%s 发送数据成功.", self.config["name"])
        finally:
            logger.info("%s 发送数据完成.", self.config["name"])

    def post_one_data_tohost(self, collectTime: Optional[float] = None) -> None:
        for gateway in self.config["list"]:

            if self._stop_event.is_set():
                break

            data = self.random_one_gateway_json_data(gateway, collectTime)

            post_url = self.config["postUrl"][gateway["type"]]

            self.post_data_to_host(data, post_url)

    def post_one_data_tohost_by_index(self, gateway_index: int = 0) -> None:

        if not self.is_in_daily_run_interval():
            logger.debug(
                "%s 当前时间不在运行时间区间内，跳过数据发送", self.config["name"]
            )
            return

        if gateway_index >= len(self.config["list"]):
            logger.error("设备索引 %d 超出范围", gateway_index)
            return

        gateway = self.config["list"][gateway_index]

        data = self.random_one_gateway_json_data(gateway)

        post_url = self.config["postUrl"][gateway["type"]]

        self.post_data_to_host(data, post_url)

    def insert_historical_data(self) -> None:

        historical_config = self.config.get("historicalDataRange", {})

        if not historical_config.get("enable", False):
            logger.info("%s 历史数据插入功能已禁用", self.config["name"])
            return

        try:

            start_time = parse_datetime_string(historical_config["startTime"])
            end_time = parse_datetime_string(historical_config["endTime"])

            interval_seconds = historical_config.get("intervalSeconds", 1800)

            if start_time >= end_time:
                logger.error(
                    "%s 无效的时间范围: 开始时间 >= 结束时间", self.config["name"]
                )
                return

            logger.info(
                "%s 开始插入历史数据，时间范围: %s 到 %s",
                self.config["name"],
                historical_config["startTime"],
                historical_config["endTime"],
            )

            current_time = start_time
            total_iterations = int((end_time - start_time) / interval_seconds)
            completed = 0

            while current_time <= end_time and not self._stop_event.is_set():

                self.post_one_data_tohost(current_time)

                current_time += interval_seconds
                completed += 1

                if completed % 100 == 0:
                    progress = (completed / total_iterations) * 100
                    logger.info(
                        "%s 历史数据插入进度: %.1f%% (%d/%d)",
                        self.config["name"],
                        progress,
                        completed,
                        total_iterations,
                    )

            logger.info("%s 历史数据插入完成", self.config["name"])

        except Exception as e:
            logger.error("%s 历史数据插入失败: %s", self.config["name"], str(e))

    def schedules(self) -> None:

        if not self.config["enable"]:
            logger.info("%s 配置已禁用，跳过设置.", self.config["name"])
            return

        daily_run_interval = self.config.get("dailyRunInterval")
        if daily_run_interval:
            start_hour = daily_run_interval["start"] // 3600
            start_minute = (daily_run_interval["start"] % 3600) // 60
            end_hour = daily_run_interval["end"] // 3600
            end_minute = (daily_run_interval["end"] % 3600) // 60

            logger.info(
                "%s 每天运行时间区间: %02d:%02d - %02d:%02d",
                self.config["name"],
                start_hour,
                start_minute,
                end_hour,
                end_minute,
            )

        for idx, gateway in enumerate(self.config["list"]):

            interval = gateway.get("interval", 15)

            intervalTo = gateway.get("intervalTo", interval + 15)

            schedule.every(interval).to(intervalTo).seconds.do(
                self.post_one_data_tohost_by_index, idx
            )
            logger.info("设备: %s 已设置定时任务.", gateway["id"])

        logger.info(
            "%s 共启动了 %s 个设备的定时任务.\n\n",
            self.config["name"],
            len(self.config["list"]),
        )

    def stop(self) -> None:

        self._stop_event.set()

        self._executor.shutdown(wait=True)
        logger.info("%s 已优雅停止", self.config["name"])


def run_pending() -> None:
    while True:

        schedule.run_pending()

        time.sleep(1)


if __name__ == "__main__":

    arg_path = sys.argv[1] if len(sys.argv) > 1 else ""
    config_json_path = arg_path or os.path.join(os.getcwd(), "config.json")

    if not os.path.exists(config_json_path):
        shutil.copy(_TML_CONFIG_JSON_PATH, config_json_path)

    try:

        with open(config_json_path, mode="r", encoding="utf-8") as f:
            json_config_list = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error("加载配置文件失败: %s", str(e))
        sys.exit(1)

    monitor_instances = []

    try:

        for _json_config in json_config_list:
            _rmds = RandomMonitorData(_json_config)
            monitor_instances.append(_rmds)

            historical_config = _json_config.get("historicalDataRange", {})
            if historical_config.get("enable", False):

                _rmds.insert_historical_data()
            else:

                _rmds.schedules()

        if any(
            not config.get("historicalDataRange", {}).get("enable", False)
            for config in json_config_list
        ):
            run_pending()

    except KeyboardInterrupt:
        logger.info("收到中断信号，正在关闭...")

        for instance in monitor_instances:
            instance.stop()
    except Exception as e:
        logger.error("意外错误: %s", str(e))

        for instance in monitor_instances:
            instance.stop()
        sys.exit(1)
