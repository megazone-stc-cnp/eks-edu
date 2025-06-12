#!/bin/bash

POD_ALIVE=2
PDB_NAME=my-pdb
# ======================================================================
echo "kubectl create poddisruptionbudget ${PDB_NAME} --selector=app=deploy-nginx --min-available=${POD_ALIVE}"
kubectl create poddisruptionbudget ${PDB_NAME} --selector=app=deploy-nginx --min-available=${POD_ALIVE}

echo ""
sh 04_get_pdb.sh
