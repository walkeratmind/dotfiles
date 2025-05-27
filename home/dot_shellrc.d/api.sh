#!/bin/bash

function request {
    echo "curl $1:"
    curl $1
}

function cryptoprice {
    # https://www.coindesk.com/coindesk-api
    curl api.coindesk.com/v1/bpi/currentprice.json | jq
}   
