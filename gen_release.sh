#!/usr/bin/env bash

#set -x

ROOT_DIR=`pwd`
OUT_DIR=release

v=`git tag | tail -n 1`
prefix=lal_${v}_

rm -rf ${ROOT_DIR}/${OUT_DIR}
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}linux/bin
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}linux/conf
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}macos/bin
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}macos/conf
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}windows/bin
mkdir -p ${ROOT_DIR}/${OUT_DIR}/${prefix}windows/conf

echo ${v} >> ${ROOT_DIR}/${OUT_DIR}/${prefix}linux/VERSION.txt
echo ${v} >> ${ROOT_DIR}/${OUT_DIR}/${prefix}macos/VERSION.txt
echo ${v} >> ${ROOT_DIR}/${OUT_DIR}/${prefix}windows/VERSION.txt

cp conf/lals.conf.json ${ROOT_DIR}/${OUT_DIR}/${prefix}linux/conf
cp conf/lals.conf.json ${ROOT_DIR}/${OUT_DIR}/${prefix}macos/conf
cp conf/lals.conf.json ${ROOT_DIR}/${OUT_DIR}/${prefix}windows/conf

GitCommitLog=`git log --pretty=oneline -n 1`
# 将 log 原始字符串中的单引号替换成双引号
GitCommitLog=${GitCommitLog//\'/\"}

GitStatus=`git status -s`
BuildTime=`date +'%Y.%m.%d.%H%M%S'`
BuildGoVersion=`go version`

LDFlags=" \
    -X 'github.com/q191201771/naza/pkg/bininfo.GitCommitLog=${GitCommitLog}' \
    -X 'github.com/q191201771/naza/pkg/bininfo.GitStatus=${GitStatus}' \
    -X 'github.com/q191201771/naza/pkg/bininfo.BuildTime=${BuildTime}' \
    -X 'github.com/q191201771/naza/pkg/bininfo.BuildGoVersion=${BuildGoVersion}' \
"

export CGO_ENABLED=0
export GOARCH=amd64

echo "build linux..."
export GOOS=linux
cd ${ROOT_DIR}/app/lals && go build -ldflags "$LDFlags" -o ${ROOT_DIR}/${OUT_DIR}/${prefix}linux/bin/lals

echo "build macos..."
export GOOS=darwin
cd ${ROOT_DIR}/app/lals && go build -ldflags "$LDFlags" -o ${ROOT_DIR}/${OUT_DIR}/${prefix}macos/bin/lals

echo "build windows..."
export GOOS=windows
cd ${ROOT_DIR}/app/lals && go build -ldflags "$LDFlags" -o ${ROOT_DIR}/${OUT_DIR}/${prefix}windows/bin/lals

cd ${ROOT_DIR}/${OUT_DIR}
zip -r ${prefix}linux.zip ${prefix}linux
zip -r ${prefix}macos.zip ${prefix}macos
zip -r ${prefix}windows.zip ${prefix}windows
