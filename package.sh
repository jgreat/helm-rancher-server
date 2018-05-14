#!/bin/bash

current=$(pwd)

cd docs/charts

helm package ../../rancher
helm repo index ./

cd $current