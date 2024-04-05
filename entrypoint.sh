#!/bin/bash

WORKDIR=/github/workspace
ADDONS_PATH=/mnt/extra-addons
BASE=$1

PKG_FILE="${WORKDIR}/packages.txt"
REQ_FILE="${WORKDIR}/requirements.txt"

if [ -f ${PKG_FILE} ]
then
    items=$(grep -vE "^\s*#" ${PKG_FILE}  | tr "\n" " ")
    pkg_cmd="RUN apt-get update && apt-get install --no-install-recommends -y ${items}"
else
    pkg_cmd=""
fi

if [ -f ${REQ_FILE} ]
then
    items=$(grep -vE "^\s*#" ${REQ_FILE}  | tr "\n" " ")
    req_cmd="RUN pip3 install ${items}"
else
    req_cmd=""
fi

content="""
FROM ${BASE}

USER root

${pkg_cmd}
${req_cmd}

COPY . ${ADDONS_PATH}

RUN chown -R odoo:odoo ${ADDONS_PATH}

USER odoo

"""
echo "${content}"
echo "${content}" > "${WORKDIR}/Dockerfile"