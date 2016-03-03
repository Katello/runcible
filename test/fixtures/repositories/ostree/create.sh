#!/bin/bash
pushd .
path="/tmp/fedora"

echo ${path}

rm -rf ${path}
mkdir -p ${path}
cd ${path}

ostree init --repo=. --mode=archive-z2

# 23.1
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates/docker-host --add-metadata-string=version=23.1 -s testing
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates-testing/docker-host --add-metadata-string=version=23.1 -s testing
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates/docker-host --add-metadata-string=version=23.2 -s testing
# 23.2
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates-testing/docker-host --add-metadata-string=version=23.2 -s testing
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates/docker-host --add-metadata-string=version=23.3 -s testing
ostree commit --repo=. -b fedora-atomic/f21/x86_64/updates-testing/docker-host --add-metadata-string=version=23.3 -s testing

ostree summary -u
popd

tar czf ./ostree-fedora-repo.tgz ${path}