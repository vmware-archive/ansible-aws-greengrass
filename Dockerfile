# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0 or GPL-3.0-only
FROM williamyeh/ansible:ubuntu16.04

VOLUME /code
ADD . /code
WORKDIR /code

RUN pip install -r requirements.txt
RUN ansible-galaxy install -r requirements.yml -p roles

CMD ["site.yml"]
ENTRYPOINT ["ansible-playbook"]
