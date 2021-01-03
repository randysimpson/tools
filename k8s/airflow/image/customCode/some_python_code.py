#!/usr/bin/env python
# coding: utf-8
import json
import logging
import os
import tempfile
import time

# Logger settings
logger = logging.getLogger()
logHandler = logging.StreamHandler()
if not logger.hasHandlers():
    logger.addHandler(logHandler)

LOGLEVEL = os.environ.get("LOGLEVEL", "WARNING").upper()
logging.basicConfig(level=LOGLEVEL)

TEST_ENV_VAR = int(os.getenv("TEST_ENV_VAR", 1))
logger.debug(f"TEST_ENV_VAR: {TEST_ENV_VAR}")

def run_test_func():
    logger.warning("################ Begin test func ###############")
    print('This is a test func, nothing exciting here.')
    x = 2 * 50 + 3
    print(f'x is 2 * 50 + 3... x={x}')
    print(f'The test env var is {TEST_ENV_VAR}')
    print('Done with the test')
    logger.warning("################ Done with test func ###############")
    logger.debug("test the debug logging")
    logger.info("test the info logging")

def main():
    logger.debug("################ Beginning main function ###############")
    run_test_func()
    logger.debug("################ Done ###############")

if __name__ == "__main__":
    main()
