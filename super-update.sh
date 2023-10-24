#!/bin/bash
apt update
apt dist-upgrade --download-only # Safety feature.
apt dist-upgrade
