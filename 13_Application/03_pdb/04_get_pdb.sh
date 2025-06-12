#!/bin/bash

PDB_NAME=my-pdb
# ======================================
echo "kubectl get pdb ${PDB_NAME}"
kubectl get pdb ${PDB_NAME}