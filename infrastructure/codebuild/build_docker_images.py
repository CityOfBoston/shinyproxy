import subprocess
import yaml
from cerberus import Validator
import argparse
import re



def load_app_configuration(document):
    """
    This function will read in the app-images.yml
    file and load the properties for all defined celery apps
    into a dictionary. This function will fail if the
    required properties are not found for each app specified

    :param document:
    :type document:
    :return:
    :rtype:
    """
    document = yaml.safe_load(document)
    expected_yaml_schema = {
        'apps': {
            'type': 'dict',
            'valueschema': {
                'type': 'dict',
                'schema': {
                    'git': {'type': 'string', 'required': True},
                    'ecr_repository': {'type': 'string', 'required': True},
                    'image': {'type': 'string', 'required': True},
                    'tag': {'type': 'string', 'required': True}
                }

            }
        }
    }
    v = Validator(expected_yaml_schema)
    if v.validate(document):
        return document
    else:
        raise ValueError(f'incorrect schema of the app-images.yml file {v.errors}')


def clone_app_libraries(app_properties):
    """
    Will take a dictionary containing container properties and will clone the specified repos to the
    task_libraries directory. Note that this function will delete any repo
    :param app_name:
    :type app_name:
    :param app_properties:
    :type app_properties:
    :return:
    :rtype:
    """
    try:
        git_location = app_properties.get('git', None)
        if git_location:
            print(f'Attempting to clone {git_location}')
            subprocess.run(['git', 'clone', f'{git_location}'], cwd='./app_libraries')

    except Exception as err:
        msg = f'An error occurred when attempting to clone the respository {err}'
        raise Exception(msg)


def pull_app_image(app_properties):
    try:
        image = app_properties.get('image')
        tag = app_properties.get('tag')
        ecr_repository = app_properties.get('ecr_repository')
        subprocess.run(['/bin/bash', '-c', 'eval $(aws ecr get-login)'])
        subprocess.run(['docker',
                        'pull', f'{ecr_repository}/{image}:{tag}'])
    except Exception as err:
        print(f'Could not pull docker image from ecr repository. The error that occured was {err}')


def build_app_image(app_properties):
    """
    Will take a dictionary containing container properties for the  celery
    app and build a docker image with those arguments

    :param app_properties:
    :type app_properties:
    :return:
    :rtype:
    """
    try:
        ecr_repository = app_properties.get('ecr_repository')
        image = app_properties.get('image')
        tag = app_properties.get('tag')
        git_location = app_properties.get('git')
        regex = re.compile(r'/.+[^.git]')
        lib_name = regex.search(git_location).group().split('/')[1]
        subprocess.run(['docker', 'build',
                        '-t', f'{ecr_repository}/{image}:{tag}',
                       f'app_library/{lib_name}'])
                        #'.'], cwd=f'app_library/{lib_name}')
    except Exception as err:
        print(f'Could not build docker image. The error that occurred was {err}')


def push_app_image(app_properties):
    """
    This function will take the app properties dictionary
    and rename the docker image to match AWS ECR requirements
    then push that image to the AWS ECR Repository specified in the
    configuration

    :param app_properties:
    :type app_properties:
    :return:
    :rtype:
    """
    image = app_properties.get('image')
    ecr_repository = app_properties.get('ecr_repository')
    tag = app_properties.get('tag')
    subprocess.run(['/bin/bash', '-c', 'eval $(aws ecr get-login)'])
    subprocess.run(['docker',
                    'push', f'{ecr_repository}/{image}:{tag}'])


def main(args):
    print(f'loading up the configuration located {args.config_file}')
    with open(args.config_file) as f:
        apps = load_app_configuration(f.read())
        print('successfully loaded app config')
        f.close()

    print("Creating folder to store shiny apps locally")
    subprocess.run(['mkdir', 'app_libraries'])
    print('Attempting to build docker images and push to ecr repo')

    for app, app_properties in apps.items():

        if args.app:
            if args.app in app_properties:
                build_app = {args.app: app_properties.get(args.app)}
            else:
                raise Exception('This app name used is not defined in the configuration file')
        else:
            build_app = app_properties
        for name, properties in build_app.items():
            print(f'name:{name}')
            print(f'prop:{properties}')
            pull_app_image(properties)
            clone_app_libraries(properties)
            build_app_image(properties)
            print('successfully built image')
            if not args.build_only:
                push_app_image(properties)
                print("successfully pushed image to AWS ECR")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Build docker images and push them to AWS')
    parser.add_argument('config_file', help='location of app_config.yml file')
    parser.add_argument('-build_only', action='store_true',
                        help='build the image locally, but do not push to the AWS ECR')
    parser.add_argument('-app', default=None,
                        help='the name of the app as defined in the config yaml file'
                             ' that you would like build specifically')
    args = parser.parse_args()
    main(args)




