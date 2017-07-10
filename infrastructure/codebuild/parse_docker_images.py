import subprocess
import yaml
from cerberus import Validator
import argparse
import re


def parse_application_file(document):
    images = []
    app_document = yaml.safe_load(document)
    for app in app_document['shiny']['apps']:
        images.append(app['docker-image'])
    return images


def clear_env_file(script_file='/tmp/docker_images.txt'):
    print(f'clearing contents in {script_file}')
    subprocess.run(['/bin/bash', '-c', f"echo '' > {script_file}"])


def add_line_to_env_file(env_variable, docker_image_string, script_file='/tmp/docker_images.txt'):
    print(f'Adding {docker_image_string} to {env_variable} in {script_file}')
    subprocess.run(['/bin/bash', '-c', f"echo '{env_variable}={docker_image_string}' >> {script_file}"])


def main(args):
    print(f'loading up the configuration located {args.public_config_file}')
    clear_env_file()
    if args.public_config_file:
        with open(args.public_config_file) as f:
            public_apps = f.read()
            print('successfully loaded app config')
            f.close()
        add_line_to_env_file('PUBLIC_IMAGES', ",".join(parse_application_file(public_apps)))

    if args.private_config_file:
        with open(args.private_config_file) as f:
            private_apps = f.read()
            print('successfully loaded app config')
            f.close()
        add_line_to_env_file('PRIVATE_IMAGES', ",".join(parse_application_file(private_apps)))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse the shinyproxy application file and'
                                                 ' produce a list of expected images to download')
    parser.add_argument('public_config_file', help='location of application.yml file with public shiny apps')
    parser.add_argument('private_config_file', help='location of application.yml file private shiny apps')
    args = parser.parse_args()
    main(args)
