#!/bin/bash


# ====================================================================
echo "kubectl exec app -- cat /data/out.txt"

kubectl exec app -- cat /data/out.txt