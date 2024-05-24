#!/bin/bash

WORKDIR=/github/workspace
ADDONS_PATH=/mnt/extra-addons

PKG_FILE="${WORKDIR}/packages.txt"
REQ_FILE="${WORKDIR}/requirements.txt"
VERSION_FILE="${WORKDIR}/$1"
BASE="`cat ${VERSION_FILE}`"

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
    req=""
    for word in $items; do req="${req} \"$word\""; done
    req_cmd="RUN pip3 install ${req}"
else
    req_cmd=""
fi

content="""
FROM ${BASE}

USER root

RUN pip3 install pip --upgrade

${pkg_cmd}

USER odoo

${req_cmd}

USER root

COPY . ${ADDONS_PATH}

RUN chown -R odoo:odoo ${ADDONS_PATH}

USER odoo

"""
echo "${content}"
echo "${content}" > "${WORKDIR}/Dockerfile"