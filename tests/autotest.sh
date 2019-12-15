#!/bin/bash

VOLUMES_PATH=/var/mocker/volumes
MOCKER=${1:-mocker}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEST_RESOURCES_DIR=$SCRIPT_DIR/resources
HELLO_DIR=$TEST_RESOURCES_DIR/hello
GOODBYE_DIR=$TEST_RESOURCES_DIR/goodbye
BUSYBOX_DIR=$TEST_RESOURCES_DIR/busybox


function clean() {
    echo "--- Cleaning After Tests ---"
    btrfs subvolume delete /var/mocker/volumes/*
    echo "--- Cleaned ---"
    echo ""
}


function test_help() {
    echo -e "\n=== Testing help ==="

    $MOCKER help
    echo ""

    clean
}


function test_init() {
    echo -e "\n=== Testing init ==="

    $MOCKER init $HELLO_DIR
    echo "[ls src] $(ls -1 $HELLO_DIR | tr '\n' ' ')"
    echo "[ls img] $(ls -1 $VOLUMES_PATH/img_0 | tr '\n' ' ')"
    echo "[cat .mocker_src] $(cat $VOLUMES_PATH/img_0/.mocker_src)"
    echo ""

    $MOCKER init $GOODBYE_DIR
    echo "[ls src] $(ls -1 $GOODBYE_DIR | tr '\n' ' ')"
    echo "[ls img] $(ls -1 $VOLUMES_PATH/img_1 | tr '\n' ' ')"
    echo "[cat .mocker_src] $(cat $VOLUMES_PATH/img_1/.mocker_src)"
    echo ""

    $MOCKER init $BUSYBOX_DIR
    echo "[ls src] $(ls -1 $BUSYBOX_DIR | tr '\n' ' ')"
    echo "[ls img] $(ls -1 $VOLUMES_PATH/img_2 | tr '\n' ' ')"
    echo "[cat .mocker_src] $(cat $VOLUMES_PATH/img_2/.mocker_src)"
    echo ""

    clean
}

function test_images() {
    echo -e "\n=== Testing images ==="

    $MOCKER images
    echo ""
    $MOCKER init $HELLO_DIR
    echo ""
    $MOCKER images
    echo ""
    $MOCKER init $GOODBYE_DIR
    echo ""
    $MOCKER images
    echo ""
    $MOCKER init $BUSYBOX_DIR
    echo ""
    $MOCKER images
    echo ""

    clean
}

function test_rmi() {
    echo -e "\n=== Testing rmi ==="

    $MOCKER init $HELLO_DIR
    $MOCKER init $HELLO_DIR
    $MOCKER init $HELLO_DIR
    echo ""

    $MOCKER images
    echo ""

    $MOCKER rmi 1
    $MOCKER rmi 0
    echo ""

    $MOCKER images
    echo ""

    clean
}


function test_pull() {
    echo -e "\n=== Testing pull ==="
    echo "NOT IMPLEMENTED"

    $MOCKER pull hello-world

    clean
}


function test_run() {
    echo -e "\n=== Testing run ==="

    $MOCKER init $BUSYBOX_DIR
    echo ""

    sudo $MOCKER run 0 ./busybox ls
    echo "[cat .mocker_cmd] $(cat $VOLUMES_PATH/ps_2/.mocker_cmd)"
    echo ""

    sudo $MOCKER run 0 ./busybox cat download
    echo "[cat .mocker_cmd] $(cat $VOLUMES_PATH/ps_3/.mocker_cmd)"
    echo ""

    clean
}

function test_ps() {
    echo -e "\n=== Testing ps ==="

    $MOCKER init $BUSYBOX_DIR
    echo ""

    $MOCKER ps
    echo ""
    sudo $MOCKER run 0 ./busybox ls
    echo ""
    $MOCKER ps
    echo ""
    sudo $MOCKER run 0 ./busybox cat download
    echo ""
    $MOCKER ps
    echo ""
    sudo $MOCKER run 0 ./busybox ls
    echo ""
    $MOCKER ps
    echo ""

    clean
}

function test_rm() {
    echo -e "\n=== Testing rm ==="

    $MOCKER init $BUSYBOX_DIR
    echo ""

    sudo $MOCKER run 0 ./busybox ls
    sudo $MOCKER run 0 ./busybox ls
    sudo $MOCKER run 0 ./busybox ls
    echo ""

    $MOCKER ps
    echo ""

    $MOCKER rm 2
    $MOCKER rm 4
    echo ""

    $MOCKER ps
    echo ""

    clean
}


function test_logs() {
    echo -e "\n=== Testing logs ==="

    $MOCKER init $BUSYBOX_DIR
    echo ""

    sudo $MOCKER run 0 ./busybox ls
    echo "[cat src]"
    ls -1 $BUSYBOX_DIR
    echo "[cat log]"
    cat $VOLUMES_PATH/ps_2/.log
    echo ""

    sudo $MOCKER run 0 ./busybox cat download
    echo "[cat src] $(cat $BUSYBOX_DIR/download)"
    echo "[cat log] $(cat $VOLUMES_PATH/ps_3/.log)"
    echo ""

    clean
}

function test_commit() {
    echo -e "\n=== Testing commit ==="

    $MOCKER init $BUSYBOX_DIR
    echo "[ls  img dir] $(ls -a1 $VOLUMES_PATH/img_0 | tr '\n' ' ')"
    echo ""

    sudo $MOCKER run 0 ./busybox cat download
    echo ""
    $MOCKER commit 2 0
    echo "[ls  img dir] $(ls -a1 $VOLUMES_PATH/img_0 | tr '\n' ' ')"
    echo "[cat img cmd] $(cat $VOLUMES_PATH/img_0/.mocker_cmd)"
    echo ""

    sudo $MOCKER run 0 ./busybox ls
    echo ""
    $MOCKER commit 3 0
    echo "[ls  img dir] $(ls -a1 $VOLUMES_PATH/img_0 | tr '\n' ' ')"
    echo "[cat img cmd] $(cat $VOLUMES_PATH/img_0/.mocker_cmd)"
    echo ""

    clean
}


function test_exec() {
    echo -e "\n=== Testing exec ==="
    echo "NOT IMPLEMENTED"

    #$MOCKER exec

    clean
}


test_help

test_init
test_images
test_rmi

test_pull

test_run
test_ps
test_rm

test_logs
test_commit

test_exec
