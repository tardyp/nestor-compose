#!/usr/bin/env python
from __future__ import print_function

import os

from kazoo.client import KazooClient

try:
    from ansible.utils.vault import VaultLib
except ImportError:
    # Ansible 2.0 has changed the vault location
    from ansible.parsing.vault import VaultLib

os.system("docker-compose up -d zk")
vault = VaultLib(open(os.path.expanduser("~/.vault-password.nestor")).read().strip())
DEFAULT_HOSTS = os.environ.get("ZK_HOST", "localhost:2181")

zk = KazooClient(hosts=DEFAULT_HOSTS)
zk.start()
dir = 'config'
path = '/nestor/config'
for root, dirs, files in os.walk(dir):
    outroot = root.replace(dir, "").strip("/")
    outroot = os.path.join(path, outroot)
    for name in files:
        inpath = os.path.join(root, name)
        outpath = os.path.join(outroot, name)
        zk.ensure_path(outpath)
        with open(inpath) as f:
            data = f.read()
            if data.startswith("$ANSIBLE_VAULT"):
                data = vault.decrypt(data)
            zk.set(outpath, data)
        print("created", outpath, ":")
        print(data)
