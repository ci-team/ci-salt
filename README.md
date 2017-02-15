# Salt states for CI infrastructure

This states are not generic and this is done on purpose. The goal is to have maintainable configuration management code and prioritize readability over flexibility.

## States

### states/jenkins

Jenkins state for Debian Jessie.

Install Jenkins, add plugins according to the hardcoded list, run jimmy to setup basic authentication.

## Secrets

Passwords and credentials are stored directly in the repository, but encrypted with gpgkeys.

To encrypt data one may use utils/encrypt.py script. For it to work you need access to the salt-master gpgkeys.
