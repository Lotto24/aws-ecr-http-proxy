#!/bin/bash

set -e

echo "Performing syntax check on ansible playbooks"

ansible-playbook -i hosts --syntax-check playbook-docker-registry-proxy.yaml
