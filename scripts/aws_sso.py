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


# -------------------------------------------------------------------- main ---


def set_profile_credentials(profile_name):
    profile = get_aws_profile(profile_name)
    cache_login = get_sso_cached_login(profile)
    credentials = get_sso_role_credentials(profile, cache_login)
    update_aws_credentials(profile_name, profile, credentials)


# --------------------------------------------------------------------- fns ---


def get_sso_cached_login(profile):
    file_paths = list_directory(AWS_SSO_CACHE_PATH)
    for file_path in file_paths:
        data = load_json(file_path)
        if data.get("startUrl") != profile["sso_start_url"]:
            continue
        if data.get("region") != profile["sso_region"]:
            continue
        if datetime.now() > parse_timestamp(data["expiresAt"]):
            continue
        return data
    raise Exception("Current cached SSO login is expired or invalid")


def get_sso_role_credentials(profile, login):
    client = boto3.client("sso", region_name=profile["sso_region"])
    response = client.get_role_credentials(
        roleName=profile["sso_role_name"],
        accountId=profile["sso_account_id"],
        accessToken=login["accessToken"],
    )
    return response["roleCredentials"]


def get_aws_profile(profile_name):
    config = read_config(AWS_CONFIG_PATH)
    profile_opts = config.items(f"profile {profile_name}")
    profile = dict(profile_opts)
    
    # Handle new SSO session format
    if "sso_session" in profile:
        session_name = profile["sso_session"]
        if config.has_section(f"sso-session {session_name}"):
            session_opts = config.items(f"sso-session {session_name}")
            session = dict(session_opts)
            # Copy SSO session values to profile
            profile["sso_start_url"] = session.get("sso_start_url", "")
            if "sso_region" not in profile:
                profile["sso_region"] = session.get("sso_region", AWS_DEFAULT_REGION)
    
    return profile


def update_aws_credentials(profile_name, profile, credentials):
    region = profile.get("region", AWS_DEFAULT_REGION)
    config = read_config(AWS_CREDENTIAL_PATH)
    if config.has_section(profile_name):
        config.remove_section(profile_name)
    config.add_section(profile_name)
    config.set(profile_name, "region", region)
    config.set(profile_name, "aws_access_key_id", credentials["accessKeyId"])
    config.set(profile_name, "aws_secret_access_key", credentials["secretAccessKey"])
    config.set(profile_name, "aws_session_token", credentials["sessionToken"])
    write_config(AWS_CREDENTIAL_PATH, config)


# ------------------------------------------------------------------- utils ---


def list_directory(path):
    file_paths = []
    if os.path.exists(path):
        file_paths = Path(path).iterdir()
    file_paths = sorted(file_paths, key=os.path.getmtime)
    file_paths.reverse()  # sort by recently updated
    return [str(f) for f in file_paths]


def load_json(path):
    try:
        with open(path) as context:
            return json.load(context)
    except ValueError:
        pass  # ignore invalid json


def parse_timestamp(value):
    return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")


def read_config(path):
    config = ConfigParser()
    config.read(path)
    return config


def write_config(path, config):
    with open(path, "w") as destination:
        config.write(destination)


# ---------------------------------------------------------------- handlers ---


def get_sso_profiles():
    """Get all AWS SSO profiles from the config file."""
    config = read_config(AWS_CONFIG_PATH)
    profiles = []
    
    for section in config.sections():
        if section.startswith("profile "):
            profile_name = section.replace("profile ", "")
            profile_opts = dict(config.items(section))
            
            # Check if it's an SSO profile (has sso_session or sso_start_url)
            if "sso_session" in profile_opts or "sso_start_url" in profile_opts:
                profiles.append(profile_name)
    
    return sorted(profiles)


def select_profile():
    """Display available profiles and let user select one."""
    profiles = get_sso_profiles()
    
    if not profiles:
        print("No SSO profiles found in ~/.aws/config")
        sys.exit(1)
    
    print("Available AWS SSO profiles:")
    for i, profile in enumerate(profiles, 1):
        print(f"  {i}. {profile}")
    
    while True:
        try:
            choice = input("\nSelect a profile (enter number or profile name): ").strip()
            
            # Check if user entered a number
            if choice.isdigit():
                index = int(choice) - 1
                if 0 <= index < len(profiles):
                    return profiles[index]
                else:
                    print(f"Invalid selection. Please enter a number between 1 and {len(profiles)}")
            # Check if user entered a profile name
            elif choice in profiles:
                return choice
            else:
                print(f"Profile '{choice}' not found. Please try again.")
        except KeyboardInterrupt:
            print("\nCancelled.")
            sys.exit(0)


def script_handler(args):
    # Determine profile name
    if len(args) == 2:
        profile_name = args[1]
    elif len(args) == 1:
        # No profile specified, show selection menu
        profile_name = select_profile()
        print(f"\nUsing profile: {profile_name}")
        subprocess.run(["aws", "configure", "export-credentials", "--profile", profile_name, "--format", "env"])
        print("-------------------------------")
        print("To activate your alias for this profile in the current shell, run:")
        print(f"    {profile_name}")
        print("-------------------------------")
        print("")
    # else:
        print("Usage: sso [profile_name]")
        sys.exit(1)
    
    # Try to use existing credentials first
    try:
        set_profile_credentials(profile_name)
        print("Finished copying data into ~/.aws/credentials.")
    except Exception:
        # If credentials are expired or invalid, login again
        print(f"SSO token expired or invalid. Logging in again...")
        result = subprocess.run(["aws", "sso", "login", "--profile", profile_name])
        
        if result.returncode != 0:
            print(f"Failed to login to AWS SSO for profile: {profile_name}")
            sys.exit(1)
        
        # Give AWS CLI a moment to write the cache file
        time.sleep(1)
        
        # Try again after fresh login
        try:
            set_profile_credentials(profile_name)
            print("Finished copying data into ~/.aws/credentials.")
        except Exception as e2:
            print(f"Error setting credentials after login: {e2}")
            sys.exit(1)


if __name__ == "__main__":
    script_handler(sys.argv)
