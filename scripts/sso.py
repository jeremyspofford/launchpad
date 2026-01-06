#!/usr/bin/env python3

# https://github.com/aws/aws-cli/issues/4982
# https://gist.githubusercontent.com/sgtoj/af0ed637b1cc7e869b21a62ef56af5ac/raw/bfa88cf6cda5d5b07690bfc134965fff3cdabf4e/aws_sso.py

import json
import os
import sys
import subprocess
import time
from configparser import ConfigParser
from datetime import datetime
from pathlib import Path

import boto3

AWS_CONFIG_PATH = f"{Path.home()}/.aws/config"
AWS_CREDENTIAL_PATH = f"{Path.home()}/.aws/credentials"
AWS_SSO_CACHE_PATH = f"{Path.home()}/.aws/sso/cache"
AWS_DEFAULT_REGION = "us-east-1"
SESSION_DURATION = 36000  # 10hrs

def read_config(path):
    config = ConfigParser()
    config.read(path)
    return config

def get_sso_profiles():
    config = read_config(AWS_CONFIG_PATH)
    profiles = []
    for section in config.sections():
        if section.startswith("profile "):
            profile_name = section.replace("profile ", "")
            profile_opts = dict(config.items(section))
            if "sso_session" in profile_opts or "sso_start_url" in profile_opts:
                profiles.append(profile_name)
    return profiles

def script_handler(args):
    pass

if __name__ == "__main__":
    script_handler(sys.argv)