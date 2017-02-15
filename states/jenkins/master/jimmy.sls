# Setup and run Jimmy (https://github.com/ci-team/jimmy.git) - tool to perform Jenkins master configuration

{% set jenkins = salt['pillar.get']('jenkins') %}

{% set venv_path = "/opt/jimmy" %}
{% set jimmy_sources = "git+https://github.com/ci-team/jimmy.git" %}
{% set config_prefix = "/var/lib/jenkins/jimmy" %}
{% set jimmy_config = "{0}/jimmy.yaml".format(config_prefix)  %}
{% set jenkins_config = "{0}/jenkins.yaml".format(config_prefix) %}

python-tox:
  pkg.installed

virtualenv:
  pkg.installed

jimmy_venv:
  virtualenv.managed:
    - name: {{ venv_path }}
    - pip_pkgs:
        - {{ jimmy_sources }}

jimmy_config:
  file.managed:
    - name: {{ jimmy_config }}
    - source: salt://jenkins/master/templates/jimmy.yaml.j2
    - template: jinja
    - context:
          jenkins_config: {{ jenkins_config }}
    - makedirs: True

jenkins_config:
  file.managed:
    - name: {{ jenkins_config }}
    - source: salt://jenkins/master/templates/jenkins.yaml.j2
    - template: jinja
    - context:
        cli_user_pub_key: {{ jenkins.public_key }}
        cli_user_password: {{ jenkins.cli_user_password }}
        jjb_password: {{ jenkins.jjb_password }}
    - makedirs: True
    - replace: True

run_jimmy:
  cmd.run:
    - cwd: {{ venv_path }}
    - runas: jenkins
    - shell: /bin/bash # needed for the source command
    - name: "source {{ venv_path }}/bin/activate && jimmy --conf-path {{ jimmy_config }} -e main"
